// -----------------------------------------------------------------------------
//  TELA CONFIRMAR REFERENCIAMENTO (I2C)
// -----------------------------------------------------------------------------

// UI elements
Button botao_continuar_ref;

void setupRefI2C(){
 
  botao_continuar_ref = new Button(true, 337, 280, 350, 50, "Iniciar o referenciamento", azulEscuro, branco);
}

void desenhaRefI2C() {
  background(branco);
  
  if (logo != null) {
    image(logo, width - logo.width - 900, -40);
  }
  
  pipetagemRef = true; // para conferir se esta vindo do referenciamento ou de outra tela

  // Caixa de mensagem
  float caixaX    = (width - 800)/2;
  float caixaY    = (height - 200)/2 - 50;

  fill(brancoBege);
  rect(caixaX, caixaY, 800, 200, 16);

  // Texto central
  textSize(24);
  fill(azulEscuro);
  textAlign(CENTER, CENTER);
  text("Certifique-se de que nenhum\nobjeto possa colidir com a pipeta!",
       caixaX + 800 / 2, 230);

  // Botão "Continuar com referenciamento"
  botao_continuar_ref.draw();
  backButton.draw();

}

void mousePressedRefI2C() {
  if (botao_continuar_ref.isMouseOver()) {
   botao_continuar_ref.isPressed = true;
  }
  if (backButton.isMouseOver()){
   backButton.isPressed = true; 
  }
  
}

void mouseReleasedRefI2C() {
  if (botao_continuar_ref.isPressed) {
   botao_continuar_ref.isPressed = false;
   
   if (porta != null){
     porta.write("ZREF\r\n");
     porta.write("XREF\r\n");
   }
   else {
     println("porta inválida");
   }
   
   setupTelaPipetagem();
   telaReferenciarI2C   = false;
   telaPipetagem = true;
  }
  
  if(backButton.isPressed){
    backButton.isPressed = false;
    
   telaReferenciarI2C = false;
   telaInicio = true;
  }
 
}
