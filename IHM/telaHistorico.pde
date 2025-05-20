void setupTelaHistorico(){
  
}


void desenhaTelaHistorico() {
  backButton.draw();
  
  // Titulo 
  fill(0);
  textSize(fontTitulo - 15);
  textAlign(LEFT, CENTER);
  text("Projeto Mecatrônico\nPipetadora automática", 80, 140);
  
  // Subtitulo
  textSize(fontSubtitulo);
  fill(cinzaEscuro);
  text("Modo atual:", 80, 200);
  fill(0);
  text("Histórico", 180, 200);
}

void mousePressedTelaHistorico(){
}

void mouseReleasedTelaHistorico(){
}
