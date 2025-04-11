// -----------------------------------------------------------------------------
//  TELA CONTROLE PIPETAGEM
// -----------------------------------------------------------------------------

// UI elements
Button AddColeta, AddDispensa, iniciaPip, pausaPip, pararPip;

void setupTelaPipetagem() {
  // "+ Ponto de coleta"
  //color corMaisPonto = (pipetagemAtiva) ? cinzaMedio : azulClaro;
  AddColeta = new Button(true, 80, 260, 140, 80, "+ Ponto de \ncoleta", azulClaro, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  AddDispensa = new Button(true, 370, 350, 140, 80, "+ Ponto de \ndispensa", azulClaro, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  
  iniciaPip = new Button(true, 600, 380, 350, 120, "INICIAR \nPIPETAGEM", azulEscuro, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  desenhaTriangulo(870, 440, 40, branco);
  
  pausaPip = new Button(true, 620, 100, 140, 150, "|| \nPausa \npipetagem", cinzaClaro, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  pararPip = new Button(true, 790, 100, 140, 150, "Parar \npipetagem", cinzaClaro, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
}


void desenhaTelaPipetagem() {
  // Ex: exibe um logo no topo direito, se existente
  if (logo != null) {
    image(logo, width - logo.width - -30, -30);
  }

  // Título
  fill(0);
  textSize(fontTitulo - 15);
  textAlign(LEFT, CENTER);
  text("Projeto Mecatrônico\nPipetadora automática", 80, 140);

  // Modo atual
  textSize(fontSubtitulo);
  fill(cinzaEscuro);
  text("Modo atual:", 80, 200);
  fill(0);
  text("manual", 180, 200);

  // Desenha botao
  AddColeta.draw();
  AddDispensa.draw();
  iniciaPip.draw();
  pausaPip.draw();
  pararPip.draw();

  // Seção total de coleta
  desenhaSecaoPontos(250, 260, "Pontos totais de \ncoleta", pontosColeta);

  // "+ Ponto de dispensa"
  desenhaSecaoPontos(80, 350, "Pontos totais de \ndispensa", pontosDispensa);

  // Caixa para tempo restante
  fill(branco);
  stroke(azulEscuro);
  strokeWeight(3);
  rect(600, 280, 350, 80, 20);
  noStroke();

  fill(azulEscuro);
  textSize(fontSubtitulo + 5);
  text("Tempo restante \npara pipetagem", 700, 320);

  fill(azulEscuro);
  textSize(fontSubtitulo);
  text(tempoRestante + " s", 900, 320);

}

//----------------------------------------------------------------------------------------
//                           'Mouse pressed' for tela pipetagem 
//----------------------------------------------------------------------------------------
void mousePressedPipetagem() {
  if (AddColeta.isMouseOver()) {
    AddColeta.isPressed = true;
    return;
  }
  else if (AddDispensa.isMouseOver()) {
    AddDispensa.isPressed = true;
    return;
  }
  else if (iniciaPip.isMouseOver()) {
    iniciaPip.isPressed = true;
    return;
  }
  else if (pausaPip.isMouseOver() && pipetagemAtiva) {
    pausaPip.isPressed = true;
    return;
  }
  else if (pararPip.isMouseOver() && (pipetagemAtiva || pipetagemPausada)) {
    pararPip.isPressed = true;
    return;
  }
  else if (mouseX > 250 && mouseX < 510 && mouseY > 260 && mouseY < 340) {
    pressedPontosTotaisColeta = true;
  }
}

//----------------------------------------------------------------------------------------
//                           'Mouse released' for tela pipetagem 
//----------------------------------------------------------------------------------------
void mouseReleasedPipetagem() {
  if (AddColeta.isPressed) {
    AddColeta.isPressed = false;
    
    //setupTelaPontosColeta(); //Inicializa o setup da prox. tela 
    
    // Mudança de telas
    //telaPipetagem = false;
    //telaPontosColeta = true;
  }
  
  else if(AddDispensa.isPressed){
    AddDispensa.isPressed = false;
    
    
    // Mudança de telas
    setupTelaPontosDispensa();
    telaPipetagem = false;
    telaPontosDispensa = true;
  }
  
  else if(iniciaPip.isPressed) {
     pipetagemAtiva = true;
     pipetagemPausada = false;
     
     pararPip = new Button(true, 790, 100, 140, 150, "Parar \npipetagem", azulEscuro, branco);
     pausaPip = new Button(true, 620, 100, 140, 150, "|| \nPausa \npipetagem", azulEscuro, branco);
     iniciaPip = new Button(true, 600, 380, 350, 120, "INICIAR \nPIPETAGEM", cinzaClaro, branco);  

  }
  
  else if(pausaPip.isPressed){
      pipetagemAtiva = false;
      pipetagemPausada = true;
     
     pararPip = new Button(true, 790, 100, 140, 150, "Parar \npipetagem", azulEscuro, branco);
     pausaPip = new Button(true, 620, 100, 140, 150, "|| \nPausa \npipetagem", cinzaClaro, branco);
     iniciaPip = new Button(true, 600, 380, 350, 120, "INICIAR \nPIPETAGEM", azulEscuro, branco);       

  }
  
  else if (pararPip.isPressed){
    pararPip.isPressed = false;
    
    pipetagemAtiva = false;
    pipetagemPausada = false;
    tempoRestante = 50;
    
    pararPip = new Button(true, 790, 100, 140, 150, "Parar \npipetagem", cinzaClaro, branco);
    pausaPip = new Button(true, 620, 100, 140, 150, "|| \nPausa \npipetagem", cinzaClaro, branco);
    iniciaPip = new Button(true, 600, 380, 350, 120, "INICIAR \nPIPETAGEM", azulEscuro, branco);     
    println("Parar pipetadora");
  }
  
}
//----------------------------------------------------------------------------------------
//                                 Funções de controle
//----------------------------------------------------------------------------------------
void iniciarPipetagem() {
  pipetagemAtiva   = true;
  pipetagemPausada = false;
  println("Função iniciarPipetagem() executada.");
}

void pausarPipetagem() {
  pipetagemPausada = !pipetagemPausada;
  println("Função pausarPipetagem() executada.");
}

void pararPipetagem() {
  pipetagemAtiva   = false;
  pipetagemPausada = false;
  tempoRestante    = 50;
  println("Função pararPipetagem() executada.");
}

// For convenience, an example "desenhaSecaoPontos()" from your code:
void desenhaSecaoPontos(float x, float y, String titulo, int quantidade) {
  fill(brancoBege);
  rect(x, y, 260, 80, 12);
  fill(cinzaEscuro);
  textSize(20);
  textAlign(LEFT, CENTER);
  text(titulo, x + 15, y + 40);

  fill(azulClaro);
  ellipse(x + 220, y + 40, 40, 40);
  fill(branco);
  textAlign(CENTER, CENTER);
  textSize(20);
  text(quantidade, x + 220, y + 40);
}

// And a small helper for the triangle (the "play" icon):
void desenhaTriangulo(float x, float y, float tamanho, color cor) {
  fill(cor);
  noStroke();
  triangle(x, y - tamanho/2, x, y + tamanho/2, x + tamanho, y);
}
