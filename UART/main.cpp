#include "mbed.h"

// Configuração da interface serial (UART) - USBTX e USBRX são os pinos do USB virtual da Nucleo
Serial pc(USBTX, USBRX);

// Definição dos pinos de saída para as fases do motor de passo (ajuste conforme sua ligação)
DigitalOut faseA(D2);  // Exemplo: use o pino D2 para fase A
DigitalOut faseB(D3);  // Exemplo: use o pino D3 para fase B
DigitalOut faseC(D4);  // Exemplo: use o pino D4 para fase C
DigitalOut faseD(D5);  // Exemplo: use o pino D5 para fase D

int main() {
    pc.baud(9600);  // Configura a velocidade da serial (baud rate) para 9600 bps
    pc.printf("RDY\r\n");  // Indica que o sistema está pronto inicialmente (opcional)

    const float intervalo = 0.005f;        // Intervalo de tempo (em segundos) para mudança de fase
    const int passos_totais = 2000;        // Quantidade de meio-passos em 5 segundos (0,5s * 10 = 5s)
    const int CMD_MAX_LEN = 32;          // Tamanho máximo esperado para comandos
    char comando[CMD_MAX_LEN];           // Buffer para armazenar o comando recebido
    int idx = 0;                         // Índice de posição no buffer

    while (true) {
        // Verifica se há caractere recebido na serial
        if (pc.readable()) {
            char c = pc.getc();  // Lê um caractere da UART

            // Se for caractere de nova linha ou retorno de carro, processa o comando
            if (c == '\r' || c == '\n') {
                if (idx > 0) {  
                    comando[idx] = '\0';  // Termina a string do comando
                    idx = 0;              // Reinicia o índice para o próximo comando

                    // Verifica se o comando é "REF"
                    if (strcmp(comando, "REF") == 0) {
                        // Comando reconhecido: inicia sequência de referência
                        pc.printf("BZY\r\n");  // Indica que o sistema está ocupado
                        pc.printf("Referenciando...\r\n");
                        pc.printf("Ativando motor por 10 segundos...\r\n");

                        // Ativa o motor de passo nas fases A, B, C, D por 5 segundos (0,5s por fase)
                        for (int passo = 0; passo < passos_totais; passo++) {
                            int fase = passo % 4;
                            // Ajusta as saídas de acordo com a fase atual
                            faseA = (fase == 0) ? 1 : 0;
                            faseB = (fase == 1) ? 1 : 0;
                            faseC = (fase == 2) ? 1 : 0;
                            faseD = (fase == 3) ? 1 : 0;
                            wait(intervalo);  // Aguarda 0,5 segundo antes de avançar para a próxima fase
                        }

                        // Desliga todas as bobinas do motor após concluir os 5 segundos
                        faseA = 0;
                        faseB = 0;
                        faseC = 0;
                        faseD = 0;

                        // Mensagens de conclusão da referência
                        pc.printf("Eixos referenciados em (0,0,0)\r\n");
                        pc.printf("RDY\r\n");  // Sistema pronto para novos comandos
                    } else {
                        // Comando não reconhecido: exibe mensagem de erro com o texto recebido
                        pc.printf("Comando nao reconhecido: %s\r\n", comando);
                        // Opcional: manter ou redefinir RDY após comando desconhecido, conforme necessidade
                    }
                } else {
                    // Se idx == 0 e recebeu newline, é caractere extra (por exemplo, LF após CR). Ignora.
                }
            } else {
                // Se caractere não for newline, adiciona ao buffer do comando (se houver espaço)
                if (idx < CMD_MAX_LEN - 1) {
                    comando[idx++] = c;
                }
                // Se o comando for maior que o buffer, caracteres extras são ignorados (poderia tratar overflow aqui)
            }
        }
    }
}

    