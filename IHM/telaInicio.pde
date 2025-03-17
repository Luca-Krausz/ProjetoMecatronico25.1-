// ============================================================================
// File: Inicio.pde
// Description: This file contains the code for the "Tela de Início" of the
//              Pipetadora Automática project.
//              It references some global variables that should be declared
//              in a common file (e.g., Globals.pde or Main.pde).
// ============================================================================

// -----------------------------------------------------------------------------
//  TELA INICIO
// -----------------------------------------------------------------------------
//  -> desenhaTelaInicio()   : Renders the 'Início' screen
//  -> mousePressedInicio()  : Handles clicks on the 'Início' screen
// -----------------------------------------------------------------------------
// The code below assumes you have global variables like:
//   boolean telaInicio, telaReferenciar, etc.
//   color azulEscuro, branco, brancoBege, etc.
//   int fontTitulo, fontSubtitulo, fontBotao
//   PImage logo
//   and a function: desenhaBotao(...)
// declared elsewhere (Globals.pde or a main PDE).
//
// If you want a fully self-contained file, you need to define them here,
// but typically in Processing we keep shared code in one PDE file
// which the other PDEs reference.
// -----------------------------------------------------------------------------

void desenhaTelaInicio() {
  // Left side (white background)
  fill(branco);
  rect(0, 0, 560, janelaAltura);

  textSize(fontTitulo);
  fill(azulEscuro);
  textAlign(LEFT, TOP);
  text("Bem vindo!", 80, 255);

  textSize(fontSubtitulo);
  fill(cinzaEscuro);
  text("Projeto Mecatrônico", 80, 305);

  // Right side (beige background)
  fill(brancoBege);
  rect(560, 0, 464, janelaAltura);

  // "Tutorial" button (example) on the left side
  desenhaBotao(80, 350, 120, 40, "Tutorial", brancoBege, azulEscuro);

  // Title on the right side
  textSize(28);
  fill(azulEscuro);
  textAlign(CENTER, TOP);
  text("Escolha o modo\nde operação", 560 + 464/2, 150);

  // Buttons (Manual, Automático, Histórico)
  float botaoLarg   = 200;
  float botaoAlt    = 40;
  float botaoEspaco = 15;
  float botaoX      = 560 + 464/2 - botaoLarg/2;
  float botaoY      = 250;

  desenhaBotao(botaoX, botaoY, botaoLarg, botaoAlt, "Manual", azulEscuro, branco);
  desenhaBotao(botaoX, botaoY + botaoAlt + botaoEspaco, botaoLarg, botaoAlt, "Automático", azulEscuro, branco);
  desenhaBotao(botaoX, botaoY + 2*(botaoAlt + botaoEspaco), botaoLarg, botaoAlt, "Histórico", azulEscuro, branco);

  // "Tutorial" again, if you want it duplicated
  desenhaBotao(80, 350, 120, 40, "Tutorial", brancoBege, azulEscuro);
}


void mousePressedInicio() {
  // "Tutorial" button (coords: 80,350, size: 120x40)
  if (mouseX > 80 && mouseX < 80 + 120 &&
    mouseY > 350 && mouseY < 350 + 40) {
    println("Botão TUTORIAL clicado!");
  }

  // Mode buttons (Manual, Automático, Histórico)
  float botaoLarg   = 200;
  float botaoAlt    = 40;
  float botaoEspaco = 15;
  float botaoX      = 560 + 464/2 - botaoLarg/2;
  float botaoY      = 250;

  // Manual
  if (mouseX > botaoX && mouseX < botaoX + botaoLarg &&
    mouseY > botaoY && mouseY < botaoY + botaoAlt) {
    println("Botão MANUAL clicado!");
    telaInicio      = false;
    telaReferenciar = true;  // For example, after "Início," you want to reference
    // before controlling pipetting
  }

  // Automático
  if (mouseX > botaoX && mouseX < botaoX + botaoLarg &&
    mouseY > botaoY + (botaoAlt + botaoEspaco) &&
    mouseY < botaoY + (botaoAlt + botaoEspaco) + botaoAlt) {
    println("Botão AUTOMÁTICO clicado!");
    // Not implemented yet
  }

  // Histórico
  if (mouseX > botaoX && mouseX < botaoX + botaoLarg &&
    mouseY > botaoY + 2*(botaoAlt + botaoEspaco) &&
    mouseY < botaoY + 2*(botaoAlt + botaoEspaco) + botaoAlt) {
    println("Botão HISTÓRICO clicado!");
    // Not implemented yet
  }
}
