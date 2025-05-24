// -----------------------------------------------------------------------------
//  TELA CONTROLE PIPETAGEM
// -----------------------------------------------------------------------------

// UI elements
Button AddColeta, AddDispensa, iniciaPip, pausaPip, pararPip;

void setupTelaPipetagem() {
  AddColeta = new Button(true, 80, 250, 140, 110, "+ Ponto de \ncoleta", azulEscuro, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  AddDispensa = new Button(true, 370, 390, 140, 110, "+ Ponto de \ndispensa", azulEscuro, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  
  iniciaPip = new Button(true, 600, 380, 350, 120, "INICIAR \nPIPETAGEM", canStart ? azulEscuro : cinzaEscuro, branco);
  
  // Initially, the pause and stop buttons are deactivated (as in the referenciamento screen).
  pausaPip = new Button(true, 620, 100, 140, 150, "|| \nPausa \npipetagem", cinzaClaro, branco);
  pararPip = new Button(true, 790, 100, 140, 150, "Parar \npipetagem", cinzaClaro, branco);
  
  if (pipetagemRef) {
    listaPontosColeta.clear();
    pontosColeta = 0;
    listaPontosDispensa.clear();
    pontosDispensa = 0;
    scrollOffset       = 0;
    scrollOffsetColeta = 0;
    selectedPoint      = -1;
    pontoColetaSelecionadoIndex = -1;
    currentColetaIndex = 0;
    pipetagemRef = false;
    coordenadas[0] = 0;
    coordenadas[1] = 0;
    coordenadas[2] = 0;
    canStart = false;
  }
}

void desenhaTelaPipetagem() {
  // Check if the pipetagem timer ran out. When the time is restarted,
  // the state returns to the initial (referenciamento) status and the pause/stop buttons remain deactivated.
  if (tempoRestante <= 0 && pipetagemAtiva) {
    pipetagemAtiva = false;
    pipetagemPausada = false;
    tempoRestante = 50;  // reset the timer
    iniciaPip = new Button(true, 600, 380, 350, 120, "INICIAR \nPIPETAGEM", azulEscuro, branco);
    pausaPip = new Button(true, 620, 100, 140, 150, "|| \nPausa \npipetagem", cinzaClaro, branco);
    pararPip = new Button(true, 790, 100, 140, 150, "Parar \npipetagem", cinzaClaro, branco);
  }
  
  if (logo != null) {
    image(logo, width - logo.width - 900, -40);
  }
  
  backButton.draw();
  
  // Verify if pipetagem can be started (needs at least one collection and one dispensa point)
  canStart = listaPontosColeta.size() > 0 && listaPontosDispensa.size() > 0;
  iniciaPip.bgColor = canStart && !pipetagemAtiva ? azulEscuro : cinzaEscuro;

  // Title
  fill(0);
  textSize(fontTitulo - 15);
  textAlign(LEFT, CENTER);
  text("Projeto Mecatrônico\nPipetadora automática", 80, 140);

  // Current mode
  textSize(fontSubtitulo);
  fill(cinzaEscuro);
  text("Modo atual:", 80, 200);
  fill(0);
  text("Manual", 180, 200);

  // Draw buttons
  AddColeta.draw();
  AddDispensa.draw();
  iniciaPip.draw();
  pausaPip.draw();
  pararPip.draw();

  // Collection points section
  desenhaSecaoPontos(250, 250, "Pontos totais de \ncoleta", listaPontosColeta.size());

  // Dispensa points section
  desenhaSecaoPontos(80, 390, "Pontos totais de \ndispensa", listaPontosDispensa.size());

  // Box for remaining time
  fill(branco);
  stroke(canStart ? azulEscuro : cinzaEscuro);
  strokeWeight(3);
  rect(600, 280, 350, 80, 20);
  noStroke();

  fill(canStart ? azulEscuro : cinzaEscuro);
  textSize(fontSubtitulo + 5);
  text("Tempo restante \npara pipetagem", 700, 320);

  fill(azulEscuro);
  textSize(fontSubtitulo);
  text(canStart ? tempoRestante + " s" : "-", 900, 320);
}

//----------------------------------------------------------------------------------------
// 'Mouse pressed' for pipetagem screen 
//----------------------------------------------------------------------------------------
void mousePressedPipetagem() {
  if (backButton != null && backButton.isMouseOver()) {
    backButton.isPressed = true;
    return;
  }
  
  if (AddColeta.isMouseOver()) {
    AddColeta.isPressed = true;
    return;
  }
  else if (AddDispensa.isMouseOver()) {
    AddDispensa.isPressed = true;
    return;
  }
  else if (iniciaPip.isMouseOver() && canStart) {
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
// 'Mouse released' for pipetagem screen 
//----------------------------------------------------------------------------------------
void mouseReleasedPipetagem() {
  if (iniciaPip.isPressed) {
    pipetagemAtiva = true;
    pipetagemPausada = false;
    
    // When starting pipetagem, activate the stop button
    pararPip = new Button(true, 790, 100, 140, 150, "Parar \npipetagem", azulEscuro, branco);
    // The pause button remains deactivated until explicitly needed
    pausaPip = new Button(true, 620, 100, 140, 150, "|| \nPausa \npipetagem", azulEscuro, branco);
    iniciaPip = new Button(true, 600, 380, 350, 120, "INICIAR \nPIPETAGEM", cinzaClaro, branco);
    
    // Send command via UART/I2C to the Nucleo boards
    String comando = gerarStringFormatoFinal();
    if (porta != null) {
      porta.write("REF\r");
      porta.write(comando);
      println(comando);
    } else {
      println("Erro: porta serial não inicializada");
    }
  }
  
  if (backButton.isPressed && backButton != null) {
    backButton.isPressed = false;
    
    // Reset state and timer (returns to the initial state so that you can define new points)
    pipetagemAtiva = false;
    pipetagemPausada = false;
    tempoRestante = 50;
    pararPip = new Button(true, 790, 100, 140, 150, "Parar \npipetagem", cinzaClaro, branco);
    pausaPip = new Button(true, 620, 100, 140, 150, "|| \nPausa \npipetagem", cinzaClaro, branco);
    iniciaPip = new Button(true, 600, 380, 350, 120, "INICIAR \nPIPETAGEM", azulEscuro, branco);
    
    telaPipetagem = false;
    telaReferenciar = true;
  }
  
  if (AddColeta.isPressed) {
    AddColeta.isPressed = false;
    setupTelaPontosColeta();
    telaPipetagem = false;
    telaPontosColeta = true;
  }
  else if (AddDispensa.isPressed) {
    AddDispensa.isPressed = false;
    setupTelaPontosDispensa();
    telaPipetagem = false;
    telaPontosDispensa = true;
  }
  else if (pausaPip.isPressed) {
    // When pausing, disable pipetagem and set pause/stop buttons to the deactivated state.
    pipetagemAtiva = false;
    pipetagemPausada = true;
    pararPip = new Button(true, 790, 100, 140, 150, "Parar \npipetagem", cinzaClaro, branco);
    pausaPip = new Button(true, 620, 100, 140, 150, "|| \nPausa \npipetagem", cinzaClaro, branco);
    iniciaPip = new Button(true, 600, 380, 350, 120, "INICIAR \nPIPETAGEM", azulEscuro, branco);
  }
  else if (pararPip.isPressed) {
    // When stopping, reset the state and timer and allow new pipetagem start.
    pararPip.isPressed = false;
    pipetagemAtiva = false;
    pipetagemPausada = false;
    tempoRestante = 50;
    pararPip = new Button(true, 790, 100, 140, 150, "Parar \npipetagem", cinzaClaro, branco);
    pausaPip = new Button(true, 620, 100, 140, 150, "|| \nPausa \npipetagem", cinzaClaro, branco);
    iniciaPip = new Button(true, 600, 380, 350, 120, "INICIAR \nPIPETAGEM", azulEscuro, branco);
  }
}

//----------------------------------------------------------------------------------------
// Control functions
//----------------------------------------------------------------------------------------
void iniciarPipetagem() {
  pipetagemAtiva   = true;
  pipetagemPausada = false;
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

void desenhaSecaoPontos(float x, float y, String titulo, int quantidade) {
  fill(brancoBege);
  rect(x, y, 250, 110, 12);
  fill(cinzaEscuro);
  textSize(20);
  textAlign(LEFT, CENTER);
  text(titulo, x + 15, y + 50);

  fill(azulEscuro);
  ellipse(x + 220, y + 50, 40, 40);
  fill(branco);
  textAlign(CENTER, CENTER);
  textSize(20);
  text(quantidade, x + 220, y + 50);
}
