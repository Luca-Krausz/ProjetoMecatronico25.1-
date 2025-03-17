// ============================================================================
// File: ControlePipetagem.pde
// Description: This file contains the code for the "Controle de Pipetagem."
//              Also handles the logic to start/pause/stop pipetting.
// ============================================================================

// -----------------------------------------------------------------------------
//  TELA CONTROLE PIPETAGEM
// -----------------------------------------------------------------------------
//  -> desenhaTelaPipetagem()
//  -> mousePressedPipetagem()
// -----------------------------------------------------------------------------
// Global vars used might include:
//   boolean telaPipetagem, pipetagemAtiva, pipetagemPausada, etc.
//   int pontosColeta, pontosDispensa, tempoRestante
//   color azulEscuro, branco, brancoBege, azulClaro, cinzaMedio, ...
//   Functions: desenhaBotao(...), desenhaSecaoPontos(...), desenhaTriangulo(...)
// -----------------------------------------------------------------------------

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

  // "+ Ponto de coleta"
  color corMaisPonto = (pipetagemAtiva) ? cinzaMedio : azulClaro;
  desenhaBotao(80, 260, 140, 80, "+ Ponto de \ncoleta", corMaisPonto, branco);

  // Seção total de coleta
  desenhaSecaoPontos(250, 260, "Pontos totais de \ncoleta", pontosColeta);

  // "+ Ponto de dispensa"
  desenhaSecaoPontos(80, 350, "Pontos totais de \ndispensa", pontosDispensa);
  desenhaBotao(370, 350, 140, 80, "+ Ponto de \ndispensa", corMaisPonto, branco);

  // Botões Pausar / Parar
  color corPausa = (pipetagemAtiva && !pipetagemPausada) ? azulEscuro : cinzaMedio;
  desenhaBotao(620, 100, 140, 150, "|| \nPausa \npipetagem", corPausa, branco);

  color corPara = pipetagemAtiva ? azulEscuro : cinzaMedio;
  desenhaBotao(790, 100, 140, 150, "Parar \npipetagem", corPara, branco);

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

  // Botão INICIAR PIPETAGEM
  color corBotao = pipetagemAtiva ? cinzaMedio : azulEscuro;
  desenhaBotao(600, 380, 350, 120, "INICIAR \nPIPETAGEM", corBotao, branco);
  desenhaTriangulo(870, 440, 40, branco);
}

// Mouse handler for pipetagem
void mousePressedPipetagem() {
  // + Ponto de coleta
  if (!pipetagemAtiva && mouseX > 80 && mouseX < 220 && mouseY > 230 && mouseY < 310) {
    println("+ Ponto de coleta clicado!");
    pontosColeta++;
  }
  // + Ponto de dispensa
  else if (!pipetagemAtiva && mouseX > 370 && mouseX < 510 && mouseY > 320 && mouseY < 400) {
    println("+ Ponto de dispensa clicado!");
    pontosDispensa++;
  }
  // Iniciar pipetagem
  else if (!pipetagemAtiva && mouseX > 600 && mouseX < 950 && mouseY > 350 && mouseY < 500) {
    println("INICIAR PIPETAGEM clicado!");
    iniciarPipetagem(); // see below
  }
  // Pausa
  else if (pipetagemAtiva && mouseX > 600 && mouseX < 740 && mouseY > 50 && mouseY < 250) {
    println("PAUSA PIPETAGEM clicado!");
    pausarPipetagem(); // see below
  }
  // Parar
  else if (pipetagemAtiva && mouseX > 790 && mouseX < 930 && mouseY > 50 && mouseY < 250) {
    println("PARAR PIPETAGEM clicado!");
    pararPipetagem();  // see below
  }
  // "Pontos totais de coleta" -> vai para a tela de movimentação manual
  else if (mouseX > 250 && mouseX < 510 && mouseY > 260 && mouseY < 340) {
    println("Clicou em 'Pontos totais de coleta' - indo para telaPontosColeta.");
    telaPipetagem = false;
    setupTelaPontosColeta();
    telaPontosColeta = true;
  }
}

// Funções de controle
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
