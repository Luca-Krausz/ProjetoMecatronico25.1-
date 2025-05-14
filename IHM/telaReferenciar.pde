Button botao_ref, botao_voltar_ref;

// dimensões dos botões 
float botaoX    = 390;
float botaoY1   = 250;
float botaoY2   = botaoY1 + 70;
  
void setupReferenciar(){
  
  botao_ref = new Button(true, botaoX, botaoY1, 250, 50, "Referenciar", azulEscuro, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  botao_voltar_ref = new Button(true, botaoX, botaoY2, 250, 50, "Voltar", azulEscuro, branco);

}


void desenhaTelaReferenciar() {
  background(branco);
  
  if (logo != null) {
    image(logo, width - logo.width - 900, -40);
  }

  // Caixa central
  float caixaLarg = 600;
  float caixaAlt  = 400;
  float caixaX    = (width - 600)/2;
  float caixaY    = (height - 400)/2;

  fill(brancoBege);
  rect(caixaX, caixaY, caixaLarg, caixaAlt, 16);

  // Texto
  textSize(24);
  fill(azulEscuro);
  textAlign(CENTER, CENTER);
  text("Referencie antes de começar", caixaX + caixaLarg / 2, caixaY + 100);
  
  // Botões
  botao_ref.draw();
  botao_voltar_ref.draw();
}

// -----------------------------------------------------------------------------
//                         Mouse Pressed Referenciar                
// -----------------------------------------------------------------------------
void mousePressedReferenciar() {

  // Botao "Referenciar"
  if (botao_ref.isMouseOver()) {
      botao_ref.isPressed = true;
      return;
      
      //telaReferenciar = false;
      //telaReferenciarI2C   = true;
    }
    // Botão "Voltar"
    else if (botao_voltar_ref.isMouseOver()) {
      botao_voltar_ref.isPressed = true;
    }
    
}

// -----------------------------------------------------------------------------
//                         Mouse Released Referenciar                
// -----------------------------------------------------------------------------
void mouseReleasedReferenciar(){
 
  // Botao "Referenciar"
  if (botao_ref.isPressed){
   botao_ref.isPressed = false;
   
   setupRefI2C();
   telaReferenciar = false;
   telaReferenciarI2C   = true;
  }
  
  else if (botao_voltar_ref.isPressed){
   botao_voltar_ref.isPressed = false;
   
   telaReferenciar = false;
   telaInicio      = true;
   telaReferenciarI2C   = false;
  }
  
  
}
