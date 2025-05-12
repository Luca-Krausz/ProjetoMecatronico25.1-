//_________________________________________________________________________________________//
//_________________________________INCLUINDO BIBLIOTECAS___________________________________//
//_________________________________________________________________________________________//

#include "mbed.h"
#include "Movimentacao\Motor.h"
#include "UART\Uart_rasp.h"
#include "Rotina\PipettingRoutine.h"
#include <string>
#include <cstring>

using namespace std::chrono_literals;

//_________________________________________________________________________________________//
//__________________________DEFINIÇÃO DE PINOS E VARIÁVEIS GLOBAIS_________________________//
//_________________________________________________________________________________________//

#define MAXIMUM_BUFFER_SIZE 100

// Flags de sistema
volatile bool referenciado    = false;   // Indica que REF foi executado
volatile bool emergencyActive = false;   // Indica que emergência foi ativada

// Definindo o Botão de Emergência
InterruptIn emergBtn(PC_13);

// Motores dos eixos
Motor motorX(D11, D12, D14, 'X', A5, A4);
Motor motorY(D3,  D4,  D5,  'Y', D8, D9);

// Rotina de pipetagem
PipettingRoutine pipetting(motorX, motorY);

// Porta serial principal
static BufferedSerial porta_serial(D10, D2, 9600);
Leitor_UART      rasp(porta_serial);



//_________________________________________________________________________________________//
//__________________________________________MAIN___________________________________________//
//_________________________________________________________________________________________//

int main() {
    // Configurando a Porta Serial
    porta_serial.set_baud(9600);

    porta_serial.set_format(8, BufferedSerial::None, 1);

    char   buffer[MAXIMUM_BUFFER_SIZE] = {0};
    //size_t idx                         = 0;

    // Loop principal: processamento de comandos UART
    while (true) {
        //printf("%d\r\n", emergencyActive);
        ThisThread::sleep_for(3000ms);

        if (rasp.getLine(buffer, sizeof(buffer))){
            if (buffer[0] == 'R' && buffer[1] == 'E' && buffer[2] == 'F') {
                if (emergencyActive) {
                    printf("Emergência ativa. REF cancelado.\r\n");
                    
                } else {
                    motorY.Ref();                                                                                   //Mudar aqui
                    //motorX.Ref();
                    referenciado = true;
                }
            }

            // ROTINA DE PIPETAGEM
            else if(buffer[0] == 'P' && buffer[1] == 'I' && buffer[2] == 'P') {
                if (!referenciado || emergencyActive) {
                    printf("Sistema não pronto. Execute REF e desative emergência.\r\n");
                } else {
                    std::string data(buffer);
                    if (pipetting.parseDados(data)) {
                        pipetting.iniciarMovimento();
                    } else {
                        printf("Erro no parse de dados de pipetagem.\r\n");
                    }
                }
            }

            // MOVIMENTAÇÃO DOS EIXOS +X/-X e +Y/-Y
            else if ((buffer[0] == '+' || buffer[0] == '-') &&
                     (buffer[1] == 'X' || buffer[1] == 'Y')) {
                //if (!referenciado || emergencyActive) {
                
                    printf("Entrou");

                if (emergencyActive) {
                    porta_serial.write("Emergencia Ativado\r\n", 20);
                } 
                
                else if (!emergencyActive){
                    char axis = buffer[1];
                    int  dist = atoi(buffer + 2);
                    char dir  = (buffer[0] == '+') ? 'A' : 'H';
                    if (axis == 'X') {
                        // Movimenta eixo X
                        motorX.Move_mm_acelerado(dist, dir, false, 0);
                    } else {
                        // Movimenta eixo Y
                        motorY.Move_mm_acelerado(dist, dir, false, 0);
                    }
                } else {
                    printf("Error!");
                    
                    porta_serial.write("Echo\r\n", 5);
                }

            }

            // COMANDO NÃO RECONHECIDO
            else {
                printf("Comando nao reconhecido: %s\r\n", buffer);
            }
            ThisThread::sleep_for(1ms);
         }
        }
    }