#ifndef MOTOR_H
#define MOTOR_H

#include "mbed.h"

/**
 * @class Motor
 * @brief Controla um motor de passo via driver (STEP, DIR, EN) e rotina de interpolação.
 */
class Motor {
public:
    /**
     * @brief Construtor do motor.
     * @param stepPino Pino de pulso (STEP) do driver.
     * @param dirPino  Pino de direção (DIR) do driver.
     * @param enPino   Pino de enable (ativo baixo) do driver.
     * @param eixoChar Identificador de eixo ('X' ou 'Y').
     * @param FDC1     Pino de fim de curso fase 1.
     * @param FDC2     Pino de fim de curso fase 2.
     */
    Motor(PinName stepPino,
          PinName dirPino,
          PinName enPino,
          char    eixoChar,
          PinName FDC1,
          PinName FDC2);

    /**
     * @brief Gera pulso no STEP do driver com delay.
     * @param delay_us Intervalo em microssegundos entre transições.
     */
    void Clock(int delay_us);

    /**
     * @brief Referencia o eixo usando o sensor de fim de curso.
     */
    void Ref();

    /**
     * @brief Move o motor uma distância em mm com perfil de aceleração.
     * @param distancia     Distância em milímetros.
     * @param dir           'A' para avanço, 'H' para retorno.
     * @param useFixed      Se true, aplica fixedDelay_us em todo o trajeto.
     * @param fixedDelay_us Delay fixo em microssegundos.
     */
    void Move_mm_acelerado(int  distancia,
                           char dir,
                           bool useFixed,
                           int  fixedDelay_us);

    /**
     * @brief Executa interpolação simultânea de dois eixos via threads.
     * @param mX     Ponteiro para motor eixo X.
     * @param mY     Ponteiro para motor eixo Y.
     * @param deltaX Deslocamento no eixo X (mm).
     * @param dirX   Direção no X ('A'/'H').
     * @param deltaY Deslocamento no eixo Y (mm).
     * @param dirY   Direção no Y ('A'/'H').
     */
    static void moveInterpolado(Motor* mX,
                                Motor* mY,
                                int    deltaX,
                                char   dirX,
                                int    deltaY,
                                char   dirY);

private:
    DigitalOut stepPin;    ///< Pino STEP do driver
    DigitalOut dirPin;     ///< Pino DIR do driver
    DigitalOut enPin;      ///< Pino EN do driver
    DigitalIn  fimDeCurso_1;///< Sensor de fim de curso fase 1
    DigitalIn  fimDeCurso_2;///< Sensor de fim de curso fase 2
    char       eixo;       ///< Identificador de eixo
};

#endif // MOTOR_H