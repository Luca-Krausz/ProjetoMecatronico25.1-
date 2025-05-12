#ifndef PIPETTING_ROUTINE_H
#define PIPETTING_ROUTINE_H

//_________________________________________________________________________________________//
//_________________________________INCLUINDO BIBLIOTECAS___________________________________//
//_________________________________________________________________________________________//

#include "mbed.h"
#include "Movimentacao\Motor.h"
#include <string>
#include <vector>
#include <utility>

//_________________________________________________________________________________________//
//_________________________________ESTRUTURA DE DADOS______________________________________//
//_________________________________________________________________________________________//

// Estrutura que representa um ponto de pipetagem.
// Cada ponto tem o seguinte formato:
// [x_disp, y_disp, z_disp, qtd_coleta, x_colet, y_colet, z_colet]
struct PontoPipetagem {
    float x_disp;      // Coordenada X da dispensa
    float y_disp;      // Coordenada Y da dispensa
    float z_disp;      // Coordenada Z da dispensa (reservado para uso futuro)
    float qtd_coleta;  // Quantidade de ciclos de coleta (volume)
    float x_colet;     // Coordenada X da coleta
    float y_colet;     // Coordenada Y da coleta
    float z_colet;     // Coordenada Z da coleta (reservado para uso futuro)
};

//_________________________________________________________________________________________//
//______________________________DECLARAÇÃO DA CLASSE_______________________________________//
//_________________________________________________________________________________________//

/**
 * @brief Classe que gerencia a rotina de pipetagem.
 */
class PipettingRoutine {
public:
    /**
     * @brief Construtor que recebe referências aos motores dos eixos X e Y.
     * @param mx Referência ao motor X
     * @param my Referência ao motor Y
     */
    PipettingRoutine(Motor &mx, Motor &my);

    /**
     * @brief Analisa a string de entrada e preenche o vetor de pontos de pipetagem.
     * @param entrada String no formato PIP[[x_disp,y_disp,z_disp,qtd,x_colet,y_colet,z_colet],...]
     * @return true se o parsing foi bem-sucedido, false caso contrário.
     */
    bool parseDados(const std::string &entrada);

    /**
     * @brief Inicia a execução da rotina de pipetagem para todos os pontos.
     */
    void iniciarMovimento();

private:
    std::vector<PontoPipetagem> pontos;  // Lista de pontos extraídos
    Motor *motorX;                       // Ponteiro para motor X
    Motor *motorY;                       // Ponteiro para motor Y
};

void handleEmergOff();
void handleEmergOn();

#endif // PIPETTING_ROUTINE_H