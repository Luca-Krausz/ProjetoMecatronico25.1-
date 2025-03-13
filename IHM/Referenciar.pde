void desenhaTelaReferenciar() {
  background(branco);
  
  // Caixa central
  float caixaLarg = 600;
  float caixaAlt = 400;
  float caixaX = (width - caixaLarg) / 2;
  float caixaY = (height - caixaAlt) / 2;
  
  fill(brancoBege);
  rect(caixaX, caixaY, caixaLarg, caixaAlt, 16);
  
  // Texto
  textSize(24);
  fill(azulEscuro);
  textAlign(CENTER, CENTER);
  text("Referencie antes de começar", caixaX + caixaLarg / 2, caixaY + 100);
  
  // Botões
  float botaoLarg = 250;
  float botaoAlt = 50;
  float botaoX = caixaX + (caixaLarg - botaoLarg) / 2;
  float botaoY1 = caixaY + 150;
  float botaoY2 = caixaY + 220;
  
  desenhaBotao(botaoX, botaoY1, botaoLarg, botaoAlt, "Referenciar", azulClaro, branco);
  desenhaBotao(botaoX, botaoY2, botaoLarg, botaoAlt, "Voltar", azulClaro, branco);
}

void desenhaTelaInicio() {
  background(branco);
  // Adicionar aqui elementos da tela inicial se necessário
}

void checarCliqueTelaReferenciar() {
  // Mesmas coordenadas usadas em desenhaTelaReferenciar()
  float caixaLarg = 600;
  float caixaAlt = 400;
  float caixaX = (width - caixaLarg) / 2;
  float caixaY = (height - caixaAlt) / 2;
  
  float botaoLarg = 250;
  float botaoAlt = 50;
  float botaoX = caixaX + (caixaLarg - botaoLarg) / 2;
  float botaoY1 = caixaY + 150; // "Referenciar"
  float botaoY2 = caixaY + 220; // "Voltar"

  // Se clicou na área horizontal do botão
  if (mouseX > botaoX && mouseX < botaoX + botaoLarg) {
    // Botão "Referenciar" -> vai para telaConfirmar
    if (mouseY > botaoY1 && mouseY < botaoY1 + botaoAlt) {
      println("Referenciar clicado!");
      telaConfirmar = true; // Ativa a telaConfirmar
    }
    // Botão "Voltar" -> volta pra telaPrincipal
    else if (mouseY > botaoY2 && mouseY < botaoY2 + botaoAlt) {
      println("Voltar clicado!");
      telaPrincipal = true;  // Volta para a telaPrincipal
      // E se quiser desativar a telaConfirmar caso estivesse ativa
      telaConfirmar = false;
    }
  }
}
