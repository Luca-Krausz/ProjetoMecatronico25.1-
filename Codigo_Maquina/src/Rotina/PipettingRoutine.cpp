#include "PipettingRoutine.h"
#include <cstdio>
#include <sstream>
#include <algorithm>
#include <cctype>
#include <cmath>              // std::fabs
#include "mbed.h"


using namespace std::chrono_literals;

// Configura interrupções do botão de emergência no pino PC_13
extern InterruptIn emergBtn;

// Declara que a variável de emergência está definida em main.cpp
extern volatile bool emergencyActive;   // Indica emergência ativa
extern volatile bool referenciado;

EventFlags interpFlags;
constexpr uint32_t DONE_INTERP = 0x2;


//_________________________________________________________________________________________//
//_________________________________DEFININDO A CLASSE______________________________________//
PipettingRoutine::PipettingRoutine(Motor &mx, Motor &my)
    : motorX(&mx), motorY(&my)
{
}

//____________________________________________________________________________________________________//
//_________________________________EXTRAÇÃO DOS PONTOS DE PIPETAGEM___________________________________//

// parseDados: extrai pontos de pipetagem da string de entrada.
bool PipettingRoutine::parseDados(const std::string &entrada) {
    if (entrada.rfind("PIP", 0) != 0) {
        printf("Formato invalido, nao inicia com 'PIP'.\n");
        return false;
    }

    size_t inicio = entrada.find('[');
    size_t fim    = entrada.rfind(']');
    if (inicio == std::string::npos || fim == std::string::npos || fim <= inicio) {
        printf("Formato invalido de colchetes.\n");
        return false;
    }

    std::string conteudo = entrada.substr(inicio, fim - inicio + 1);
    if (conteudo.size() < 4 || conteudo.substr(0,2) != "[[" || conteudo.substr(conteudo.size()-2) != "]]" ) {
        printf("Formato de pipetagem invalido.\n");
        return false;
    }

    // Remove '[[' e ']]'
    std::string dados = conteudo.substr(2, conteudo.size() - 4);
    std::vector<std::string> listaPontos;
    size_t pos = 0;
    while ((pos = dados.find("],[")) != std::string::npos) {        // Possivel erro 
        listaPontos.push_back(dados.substr(0, pos));
        dados = dados.substr(pos + 3);
    }
    if (!dados.empty()) listaPontos.push_back(dados);

    for (const auto &pontoStr : listaPontos) {
        std::istringstream iss(pontoStr);
        std::string token;
        std::vector<float> valores;
        while (std::getline(iss, token, ',')) {
            token.erase(
                std::remove_if(token.begin(), token.end(), (int(*)(int))std::isspace),
                token.end()
            );
            if (!token.empty()) valores.push_back(std::stof(token));
        }
        if (valores.size() != 7) {
            printf("Numero incorreto de valores para um ponto.\n");
            return false;
        }
        PontoPipetagem ponto {
            valores[0], valores[1], valores[2],
            valores[3], valores[4], valores[5], valores[6]
        };
        pontos.push_back(ponto);
    }

    return !pontos.empty();
}


//______________________________________________________________________________________________//
//_________________________________HANDLERS DE EMERGÊNCIA______________________________________//
void handleEmergOn() {
    emergencyActive = true;
    referenciado    = false;
}

// Interrupção ao desativar emergência (borda de subida)
void handleEmergOff() {
    emergencyActive = false;
}


//_________________________________________________________________________________________//
//_________________________________lÓGICA DA PIPETAGEM_____________________________________//

// iniciarMovimento: executa o ciclo de pipetagem para cada ponto.
void PipettingRoutine::iniciarMovimento() {
    
    emergBtn.mode(PullUp);

    emergBtn.fall(handleEmergOn);
    emergBtn.rise(handleEmergOff); 


    //____________________________________________________________________________________________//
    //_________________________VERIFICANDO PONTOS VAZIOS E EMERGÊNCIA_____________________________//
    if (pontos.empty()) {
        printf("Nao ha pontos de pipetagem.\n");
        return;
    }


    if (emergencyActive) {
        printf("Emergencia ativada, abortando pipetagem.\n");
        return;
    }

    //_________________________________________________________________________________________//
    //_________________________________REFERENCIANDO A MÁQUINA___________________________________//
    printf("Zerando a maquina...\n");

    /*
    motorX->Ref();
    if (emergencyActive) {
        printf("Emergencia ativada, abortando pipetagem.\n");                                                                                   //Mudar aqui
        return;
    }
    */
    
    motorY->Ref();
    if (emergencyActive) {
        printf("Emergencia ativada, abortando pipetagem.\n");                                                                                   //Mudar aqui
        return;
    }
    
    

    //_________________________________________________________//
    //___________________ZERANDO PONTOS _______________________//
    float posX = 0.0f, posY = 0.0f;



    //______________________________________________________________//
    //___________________FOR PARA CADA PONTO _______________________//
    for (size_t i = 0; i < pontos.size(); ++i) {
        const auto &pt = pontos[i];


        //_____________________________________________________________________________________________//
        //___________________REPETIÇÃO PARA ATENDER A QUANTIDADE DE ML DESEJADO _______________________//
        int ciclos = int(pt.qtd_coleta);
        for (int c = 0; c < ciclos && !emergencyActive; ++c) {

            printf("emergencyActive? %d\r\n", emergencyActive);

            /*printf("Incicio do ciclo do ponto %zu", i+1);
            printf("e ml %zu.\n", c+1);
            printf("\n");*/

            //______________________________________________________________________________//
            //___________________MOVIMENTAÇÃO PARA O PONTO DE COLETA _______________________//
            //printf("Coletando o liquido\n\n");
            float dX = pt.x_colet - posX;
            float dY = pt.y_colet - posY;
            /*printf("Delta em X para coleta %f \n", dX);
            printf("Delta em Y para coleta %f \n", dY);*/

            //_________________________________________________________//
            //______________MOVIMENTAÇÃO DOS EIXOS X E Y ________________//
            if ( dX != 0.0f || dY != 0.0f) {
                printf("Movendo eixos para coleta\n");
                Motor::moveInterpolado(motorX, motorY,int(dX), dX>0.0?'A':'H', int(dY), dY>0.0?'A':'H');
                posX = pt.x_colet;
                posY = pt.y_colet;
            }

            //_____________________________________________//
            //____________COLETANDO O LIQUIDO _____________//
            printf("Coleta do liquido...\n");
            ThisThread::sleep_for(3000ms);
            //printf("Ponto %d: Posicao de coleta atingida.\n", int(i+1));
            if (emergencyActive) 
            {
                printf("Emergencia");
                break;
            }
            



            //________________________________________________________________________________//
            //___________________MOVIMENTAÇÃO PARA O PONTO DE DISPENSA _______________________//
            float dX2 = pt.x_disp - posX;
            float dY2 = pt.y_disp - posY;
            /*printf("Delta em X para dispensa %f \n", dX2);
            printf("Delta em Y para dispensa %f \n", dY2);*/


            //___________________________________________________________//
            //______________MOVIMENTAÇÃO DOS EIXOS X E Y ________________//
            if (std::fabs(dX2) > 0 || std::fabs(dY2) > 0) {
                printf("Movendo eixos para dispensa\n");
                Motor::moveInterpolado(motorX, motorY, int(dX2), dX2>0.0?'A':'H', int(dY2), dY2>0.0?'A':'H');
                posX = pt.x_disp;
                posY = pt.y_disp;
            }

            //_____________________________________________//
            //____________DISPENSA DO LÍQUIDO _____________//
            printf("Dispensa do liquido...\n");
            ThisThread::sleep_for(3000ms);
            //printf("Ponto %d: Posicao de dispensa atingida.\n", int(i+1));
            if (emergencyActive) 
            {
                printf("Emergencia");
                break;
            }

            /*printf("ml %zu.", c+1);
            printf("adicionado ao ponto %zu.\n", i+1);*/
        }
    }

    float DX3 = 3 - posX;
    float DY3 = 120 - posY;
    Motor::moveInterpolado(motorX, motorY, int(DX3), DX3>0.0?'A':'H', int(DY3), DY3>0.0?'A':'H');
    printf("\nTodos os ciclos de pipetagem foram processados.\n");
}