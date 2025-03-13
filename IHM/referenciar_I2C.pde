void desenhaTelaConfirmarReferenciamento() {
  background(branco);
  
  // Caixa (cinza claro) para mensagem
  float caixaLarg = 800;
  float caixaAlt  = 200;
  float caixaX = (width - caixaLarg) / 2;
  float caixaY = (height - caixaAlt) / 2 - 50; // Um pouco acima do centro
  
  fill(brancoBege);
  rect(caixaX, caixaY, caixaLarg, caixaAlt, 16);

  // Texto central
  textSize(24);
  fill(azulEscuro);
  textAlign(CENTER, CENTER);
  text("Certifique-se de que nenhum\nobjeto possa colidir com a pipeta",
       caixaX + caixaLarg / 2, caixaY + caixaAlt / 2);

  // Botão "Continuar com referenciamento"
  float botaoLarg = 350;
  float botaoAlt  = 50;
  float botaoX = (width - botaoLarg) / 2;
  float botaoY = caixaY + caixaAlt + 40;
  
  desenhaBotao(botaoX, botaoY, botaoLarg, botaoAlt, 
               "Continuar com referenciamento", azulClaro, branco);
}

void checarCliqueTelaConfirmar() {
  float caixaLarg = 800;
  float caixaAlt  = 200;
  float caixaX = (width - caixaLarg) / 2;
  float caixaY = (height - caixaAlt) / 2 - 50;
  
  float botaoLarg = 350;
  float botaoAlt  = 50;
  float botaoX = (width - botaoLarg) / 2;
  float botaoY = caixaY + caixaAlt + 40;
  
  if (mouseX > botaoX && mouseX < botaoX + botaoLarg &&
      mouseY > botaoY && mouseY < botaoY + botaoAlt) {
    println("Continuar com referenciamento clicado!");
    telaConfirmar = false;
    telaPipetagem = true; // ou qualquer outra lógica
  }
}
