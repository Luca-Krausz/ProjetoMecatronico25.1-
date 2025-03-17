// ============================================================================
// File: Referenciar.pde
// Description: This file contains the code for the "Tela de Referenciar."
//              It draws a box prompting the user to reference the machine
//              and handles clicks for "Referenciar" and "Voltar."
// ============================================================================

// -----------------------------------------------------------------------------
//  TELA REFERENCIAR
// -----------------------------------------------------------------------------
//  -> desenhaTelaReferenciar() : Renders the Referenciar screen
//  -> checarCliqueTelaReferenciar() : Handles clicks on this screen
// -----------------------------------------------------------------------------
// Assumes global variables like:
//   boolean telaReferenciar, telaConfirmar, telaInicio, etc.
//   color azulEscuro, branco, brancoBege, azulClaro, ...
//   int fontTitulo, fontSubtitulo, fontBotao
//   and a function: desenhaBotao(...)
// -----------------------------------------------------------------------------

void desenhaTelaReferenciar() {
  background(branco);

  // Caixa central
  float caixaLarg = 600;
  float caixaAlt  = 400;
  float caixaX    = (width - caixaLarg)/2;
  float caixaY    = (height - caixaAlt)/2;

  fill(brancoBege);
  rect(caixaX, caixaY, caixaLarg, caixaAlt, 16);

  // Texto
  textSize(24);
  fill(azulEscuro);
  textAlign(CENTER, CENTER);
  text("Referencie antes de começar", caixaX + caixaLarg / 2, caixaY + 100);

  // Botões
  float botaoLarg = 250;
  float botaoAlt  = 50;
  float botaoX    = caixaX + (caixaLarg - botaoLarg) / 2;
  float botaoY1   = caixaY + 150;
  float botaoY2   = caixaY + 220;

  desenhaBotao(botaoX, botaoY1, botaoLarg, botaoAlt, "Referenciar", azulClaro, branco);
  desenhaBotao(botaoX, botaoY2, botaoLarg, botaoAlt, "Voltar",       azulClaro, branco);
}


void checarCliqueTelaReferenciar() {
  // Coordenadas iguais às usadas em desenhaTelaReferenciar()
  float caixaLarg = 600;
  float caixaAlt  = 400;
  float caixaX    = (width - caixaLarg)/2;
  float caixaY    = (height - caixaAlt)/2;

  float botaoLarg = 250;
  float botaoAlt  = 50;
  float botaoX    = caixaX + (caixaLarg - botaoLarg)/2;
  float botaoY1   = caixaY + 150; // "Referenciar"
  float botaoY2   = caixaY + 220; // "Voltar"

  // Se clicou na área horizontal do botão
  if (mouseX > botaoX && mouseX < botaoX + botaoLarg) {
    // Botão "Referenciar"
    if (mouseY > botaoY1 && mouseY < botaoY1 + botaoAlt) {
      println("Referenciar clicado!");
      // Por exemplo: sai desta tela e vai para a Tela de Confirmação
      telaReferenciar = false;
      telaConfirmar   = true;
    }
    // Botão "Voltar"
    else if (mouseY > botaoY2 && mouseY < botaoY2 + botaoAlt) {
      println("Voltar clicado!");
      // Volta à Tela Inicio
      telaReferenciar = false;
      telaInicio      = true;
      telaConfirmar   = false;
    }
  }
}
