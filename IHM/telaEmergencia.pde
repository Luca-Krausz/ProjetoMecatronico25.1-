String comando = null;


void setupTelaEmergencia(){
  
}

void desenhaTelaEmergencia() {
  
  background(#FF0000);
  
  // Titulo 
  fill(branco);
  textSize(fontTitulo - 15);
  textAlign(CENTER, CENTER);
  text("ALERTA EMERGÊNCIA", 80, 140);
  
  // Subtitulo
  textSize(fontSubtitulo);
  fill(branco);
  text("Gire o botão para sair deste modo", 80, 200);
  /*fill(0);
  text("Histórico", 180, 200);*/
  
  
  // Loop para sair da tela de emergência
  while(true) {
  
    if (porta.available() > 0) {
        comando = porta.readStringUntil('\n');
        println(comando);
        if (comando.equals("EMERGOFF"))
        {
         telaEmergencia = false;
         telaInicio = true;
        } else {
         continue; 
        }
    } else {
        println("Erro: porta serial não inicializada");
    }
  
  }
}


void mousePressedTelaEmergencia(){
}

void mouseReleasedTelaEmergencia(){
}
