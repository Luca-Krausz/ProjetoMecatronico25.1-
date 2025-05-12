#include "Motor.h"
#include "UART\Uart_rasp.h"
#include "mbed.h"
#include "rtos.h"
#include <cmath>
#include <cstdio>
#include "rtos.h"



//_________________________________________________________________________________________//
//_______________________________DECLARAÇÃO DE SERIAL_______________________________________//
//_________________________________________________________________________________________//

static BufferedSerial porta_serial(D10, D2, 9600);  // Porta serial interna
extern volatile bool emergencyActive;                // Definida em main.cpp
extern volatile bool referenciado;                // Definida em main.cpp

//_________________________________________________________________________________________//
//________________________________________THREADS____________________________________________//
//_________________________________________________________________________________________//

/**
 * @struct ThreadParams
 * @brief Parâmetros para execução de Move_mm_acelerado em thread.
 */
struct ThreadParams {
    Motor* motor;       ///< Motor a movimentar
    int    dist;        ///< Distância em mm
    char   dir;         ///< Direção ('A'/'H')
    bool   useFixed;    ///< Se true, usa fixedDelay
    int    fixedDelay;  ///< Delay fixo (µs)
};

/**
 * @brief Função de thread que move um eixo e finaliza.
 * @param arg Ponteiro para ThreadParams.
 */
/*static void threadMove(const void* arg) {
    auto p = static_cast<const ThreadParams*>(arg);
    p->motor->Move_mm_acelerado(p->dist, p->dir, p->useFixed, p->fixedDelay);
    delete p;
}*/

//-----------------------------------------------------------------------------
// Construtor
//-----------------------------------------------------------------------------//
Motor::Motor(PinName stepPino, PinName dirPino, PinName enPino,
             char eixoChar, PinName FDC1, PinName FDC2)
    : stepPin(stepPino),
      dirPin(dirPino),
      enPin(enPino),
      fimDeCurso_1(FDC1),
      fimDeCurso_2(FDC2),
      eixo(eixoChar)
{
    enPin = 1; // desabilita driver
}

//_________________________________________________________________________________________//
//___________________________________Clock Function_________________________________________//
//_________________________________________________________________________________________//


void Motor::Clock(int delay_us) {
    stepPin = 1;
    wait_us(delay_us);
    stepPin = 0;
    wait_us(delay_us);
}

//_________________________________________________________________________________________//
//___________________________________Referenciamento________________________________________//
//_________________________________________________________________________________________//

void Motor::Ref() {
    const int refDelay    = 2000;
    const int maxDistance = 1000;
    const int sair_fim_curso = 3;
    enPin = 0;
    // Move até fim de curso anti-horário
    Move_mm_acelerado(maxDistance, 'H', false, refDelay);
    // Move até fim de curso horário
    Move_mm_acelerado(sair_fim_curso, 'A', false, refDelay);
    enPin = 1;
}

//_________________________________________________________________________________________//
//___________________________Movimentação com Aceleração____________________________________//
//_________________________________________________________________________________________//
void Motor::Move_mm_acelerado(int distancia, char dir, bool useFixed, int fixedDelay_us) {
    const float minAccel = 3.0f;
    const float accel_mm = 2.0f;
    const int   initDly  = 1200;
    const int   maxDly   = 180;

    //float passo = (eixo == 'X') ? 0.015f : 0.025f;
    float passo = (eixo == 'X') ? 0.0075f : 0.0125f; // Mudança para meio passo
    int total   = int(distancia / passo + 0.5f);
    if (total <= 0) return;

    enPin  = 0;
    dirPin = (dir == 'A') ? 1 : 0;

    // Função que verifica o fim de curso correto para o sentido
    auto checkEndstop = [&]() {
        if (dir == 'H' && fimDeCurso_1.read() == 0) return true;
        if (dir == 'A' && fimDeCurso_2.read() == 0) return true;
        return false;
    };

    if (useFixed) {
        for (int i = 0; i < total; ++i) {
            if (emergencyActive || checkEndstop() || !referenciado) break;
            //if (emergencyActive || checkEndstop()) break;
            Clock(fixedDelay_us);
        }
    } else if (distancia < minAccel) {
        for (int i = 0; i < total; ++i) {
            if (emergencyActive || checkEndstop() || !referenciado) break;
            //if (emergencyActive || checkEndstop()) break;
            Clock(initDly);
        }
    } else {
        int ramp = int(accel_mm / passo + 0.5f);
        ramp     = (ramp > total) ? total : ramp;
        for (int i = 0; i < ramp; ++i) {
            if (emergencyActive || checkEndstop() || !referenciado) break;
            //if (emergencyActive || checkEndstop()) break;
            float t = float(i) / float(ramp);
            int   d = initDly - int(t * (initDly - maxDly));
            Clock(d);
        }
        for (int i = ramp; i < total; ++i) {
            if (emergencyActive || checkEndstop() || !referenciado) break;
            //if (emergencyActive || checkEndstop()) break;
            Clock(maxDly);
        }
    }

    enPin = 1;
}


//_________________________________________________________________________________________//
//_____________________________Movimentação Interpolada_____________________________________//
//_________________________________________________________________________________________//
void Motor::moveInterpolado(Motor* mX, Motor* mY, int deltaX, char dirX, int deltaY, char dirY) {
    // Cálculo de passos e delays
    //const float stepX = 0.015f;
    const float stepX = 0.0075f;
    //const float stepY = 0.025f;
    const float stepY = 0.0125f;
    int passosX = int(std::abs(deltaX) / stepX + 0.5f);
    int passosY = int(std::abs(deltaY) / stepY + 0.5f);
    bool xPrimary = (passosX > passosY);

    const float accel_mm = 2.0f;
    const int   initDly  = 1200;
    const int   maxDly   = 180;
    int mainSteps = xPrimary ? passosX : passosY;
    int rampSteps = int(accel_mm / (xPrimary ? stepX : stepY) + 0.5f);
    rampSteps     = (rampSteps > mainSteps) ? mainSteps : rampSteps;
    int constSteps = mainSteps - rampSteps;

    uint32_t timeRamp = 0;
    for (int i = 0; i < rampSteps; ++i) {
        float t = float(i) / float(rampSteps);
        int   d = initDly - int(t * (initDly - maxDly));
        timeRamp += 2u * d;
    }
    uint32_t timeConst   = uint32_t(constSteps) * 2u * maxDly;
    uint32_t Tprim       = timeRamp + timeConst;
    int      fixedDelay = int(Tprim / (2.0f * (xPrimary ? passosY : passosX)));

    /*printf("Na movimentacao interpolada a direcao de X sera: %c \n", dirX);
    printf("Na movimentacao interpolada o delta de X sera: %i \n", deltaX);
    printf("Na movimentacao interpolada a direcao de Y sera: %c \n", dirY);
    printf("Na movimentacao interpolada o delta de X sera: %i \n", deltaY);
    printf("\n");*/

    // Movimento do eixo primário
    if (xPrimary) {
        mX->Move_mm_acelerado(std::abs(deltaX), dirX, false, 0);                                                                                   //Mudar aqui
        //printf("Entrou no Xprimario \n");
        //mY->Move_mm_acelerado(std::abs(deltaY), dirY, true, fixedDelay);                                                                                   //Mudar aqui
    } else {
        mX->Move_mm_acelerado(std::abs(deltaX), dirX, true, fixedDelay);                                                                                   //Mudar aqui
        //printf("Entrou no X \n");
        //mY->Move_mm_acelerado(std::abs(deltaY), dirY, false, 0);                                                                                   //Mudar aqui
    } 
}
