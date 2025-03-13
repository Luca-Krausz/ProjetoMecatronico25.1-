void desenhaTelaPontos() {
  // Título
  fill(0);
  textSize(fontTitulo - 15);
  textAlign(LEFT, CENTER);
  text("Projeto Mecatrônico\nPipetadora automática", 80, 140);
  
  // Modo Atual
  textSize(fontSubtitulo);
  fill(cinzaEscuro);
  text("Modo atual:", 80, 200);
  fill(0);
  text("manual", 180, 200);
  
  // Seção de pontos de coleta
  color corMaisPonto = (pipetagemAtiva) ? cinzaMedio : azulClaro;
  desenhaBotao(80, 260, 140, 80, "+ Ponto de \ncoleta", corMaisPonto, branco);
  desenhaSecaoPontos(250, 260, "Pontos totais de \ncoleta", pontosColeta);
  
  // Seção de pontos de dispensa
  desenhaSecaoPontos(80, 350, "Pontos totais de \ndispensa", pontosDispensa);
  desenhaBotao(370, 350, 140, 80, "+ Ponto de \ndispensa", corMaisPonto, branco);
  
  // Botões de controle
  color corPausa = (pipetagemAtiva && !pipetagemPausada) ? azulEscuro : cinzaMedio;
  desenhaBotao(620, 100, 140, 150, "|| \nPausa \npipetagem", corPausa, branco);
  
  color corPara = pipetagemAtiva ? azulEscuro : cinzaMedio;
  desenhaBotao(790, 100, 140, 150, "Parar \npipetagem", corPara, branco);
  
  // Tempo restante para pipetagem
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
  
  color corBotao = pipetagemAtiva ? cinzaMedio : azulEscuro;
  desenhaBotao(600, 380, 350, 120, "INICIAR \nPIPETAGEM", corBotao, branco);
  desenhaTriangulo(870, 440, 40, branco);
}

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

void desenhaTriangulo(float x, float y, float tamanho, color cor) {
  fill(cor);
  noStroke();
  triangle(x, y - tamanho/2, x, y + tamanho/2, x + tamanho, y);
}

void iniciarPipetagem() {
  pipetagemAtiva = true;
  pipetagemPausada = false;
  println("Função iniciarPipetagem() executada.");
}

void pausarPipetagem() {
  pipetagemPausada = !pipetagemPausada;
  println("Função pausarPipetagem() executada.");
}

void pararPipetagem() {
  pipetagemAtiva = false;
  pipetagemPausada = false;
  tempoRestante = 50;
  println("Função pararPipetagem() executada.");
}

void mousePressedPipetagem() {
  // + Ponto de coleta
  if (mouseX > 80 && mouseX < 220 && mouseY > 230 && mouseY < 310 && !pipetagemAtiva) {
    println("+ Ponto de coleta clicado!");
    pontosColeta++;
  }
  // + Ponto de dispensa
  else if (mouseX > 370 && mouseX < 510 && mouseY > 320 && mouseY < 400 && !pipetagemAtiva) {
    println("+ Ponto de dispensa clicado!");
    pontosDispensa++;
  }
  // Iniciar pipetagem
  else if (mouseX > 600 && mouseX < 1070 && mouseY > 350 && mouseY < 470 && !pipetagemAtiva) {
    println("INICIAR PIPETAGEM clicado!");
    iniciarPipetagem();
  }
  // Pausa
  else if (mouseX > 600 && mouseX < 740 && mouseY > 50 && mouseY < 200 && pipetagemAtiva) {
    println("PAUSA PIPETAGEM clicado!");
    pausarPipetagem();
  }
  // Parar
  else if (mouseX > 810 && mouseX < 950 && mouseY > 50 && mouseY < 200 && pipetagemAtiva) {
    println("PARAR PIPETAGEM clicado!");
    pararPipetagem();
  }
  // === Clique na área de "Pontos totais de coleta" (250,260) (260,80) ===
  else if (mouseX > 250 && mouseX < 250 + 260 &&
           mouseY > 260 && mouseY < 260 + 80) {
    println("Clicou em 'Pontos totais de coleta' - indo para telaMovimentacaoManual.");
    telaPipetagem          = false;
    telaMovimentacaoManual = true;
  }
}
