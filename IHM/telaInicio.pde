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

// UI elements
Button  botao_tutorial, modo_manual, modo_automatico, modo_hist;

 // Definindo as características dos botões de "modo"

void setupTelaInicio() {
   if (inicio_config == false) {
   inicio_config = true;
   }
   
   botao_tutorial =  new Button(true, 80, 350, 120, 40, "Tutorial", brancoBege, azulEscuro);                                               // (square?, x, y, w, h, label, bgColor, textcolor)
   modo_manual =     new Button(true, 692, 250, 200, 40, "Manual", azulEscuro, branco);                                  // (square?, x, y, w, h, label, bgColor, textcolor)
   modo_automatico = new Button(true, 692, 305, 200, 40, "Automático", azulEscuro, branco);     // (square?, x, y, w, h, label, bgColor, textcolor)
   modo_hist =       new Button(true, 692, 360, 200, 40, "Histórico", azulEscuro, branco);  // (square?, x, y, w, h, label, bgColor, textcolor)
  
}


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

  // Title on the right side
  textSize(28);
  fill(azulEscuro);
  textAlign(CENTER, TOP);
  text("Escolha o modo\nde operação", 560 + 464/2, 150);
  
  // Draw the buttons
  botao_tutorial.draw();
  modo_manual.draw();
  modo_automatico.draw();
  modo_hist.draw();

}

//----------------------------------------------------------------------------------------
//                           'Mouse pressed' for tela inicio
//----------------------------------------------------------------------------------------
void mousePressedInicio() {
  // Tutorial
  if (botao_tutorial.isMouseOver()) {
    botao_tutorial.isPressed = true;
    println("ligou botao tut");
    
  }

  // Manual
  else if (modo_manual.isMouseOver()) {
    modo_manual.isPressed = true;
    
  }

  // Automático
  else if (modo_automatico.isMouseOver()) {
    modo_automatico.isPressed = true;
    
  }

  // Histórico
  else if (modo_hist.isMouseOver()) {
    modo_hist.isPressed = true;
    
  }
}

//----------------------------------------------------------------------------------------
//                           'Mouse released' for tela inicio
//----------------------------------------------------------------------------------------

void mouseReleasedInicio() {
  println(botao_tutorial.isPressed);
  if (botao_tutorial.isPressed) {
     botao_tutorial.isPressed = false;
     
     println("Botão TUTORIAL clicado!");
  }
  
  else if (modo_manual.isPressed) {
    modo_manual.isPressed = false;
    
    telaInicio      = false;
    telaReferenciar = true; 
    println("Botão MANUAL clicado!");
  }
  
  else if (modo_automatico.isPressed) {
    modo_automatico.isPressed = false; 
    
    println("Botão AUTOMÁTICO clicado!");
  }
  
  else if(modo_hist.isPressed) {
   modo_hist.isPressed = false;
   
   println("Botão HISTÓRICO clicado!");
  }
  
  
  
  
}
