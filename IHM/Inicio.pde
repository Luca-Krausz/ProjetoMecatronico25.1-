PFont fonteAtual;
PFont fonte1, fonte2, fonte3, fonte4; // Variáveis para diferentes fontes
int fonteSelecionada = 3; // Índice da fonte selecionada

PImage logo; // Variável para a imagem do logo
PShape iconeXY;

// ---------- CORES -----------
color azulEscuro  = color(0x0C, 0x4E, 0x8C); // #0C4E8C
color branco      = color(0xFF, 0xFF, 0xFF); // #FFFFFF
color brancoBege  = color(0xF3, 0xF3, 0xF3); // #F3F3F3
color azulClaro   = color(0x00, 0x84, 0xFF); // #0084FF
color cinzaEscuro = color(0x69, 0x69, 0x69); //
color cinzaAzul = color(0x32, 0x3C, 0x45);
color cinzaClaro  = color(0xD3, 0xD3, 0xD3);
color cinzaMedio  = color(0xA9, 0xA9, 0xA9);
color verdeSelecionado = color(0, 200, 0); // #00C800

// ---------- TAMANHO JANELA ----------
int janelaLargura = 1024;
int janelaAltura  = 600;

// ---------- DIMENSÕES DOS BLOCOS ----------
float blocoEsquerdoW = 560;
float blocoEsquerdoH = 600;
float blocoDireitoW  = 464;
float blocoDireitoH  = 600;

// ---------- POSIÇÕES DOS BLOCOS ----------
float blocoEsquerdoX = 0;
float blocoEsquerdoY = 0;

float blocoDireitoX  = blocoEsquerdoW;
float blocoDireitoY  = 0;

// ---------- TAMANHOS DE FONTE ----------
int fontTitulo    = 50;
int fontSubtitulo = 17;
int fontBotao     = 20;

boolean telaPrincipal = true;
boolean telaConfirmar  = false;
boolean telaPipetagem = false; // Nova tela de pipetagem
boolean telaMovimentacaoManual = false;

int pontosColeta   = 1;
int pontosDispensa = 1;
int tempoRestante  = 50;
boolean pipetagemAtiva   = false;
boolean pipetagemPausada = false;
boolean contagemAtiva    = false;
int estadoPipetagem      = 0;

boolean xyLocked   = false;  // se true, trava XY
boolean zLocked    = false;  // se true, trava Z
int movSpeed       = 1;      // 1mm, 10mm ou 30mm

boolean ponto01Checked = true; // checkbox "Ponto 01 - 3ml"
boolean ponto02Checked = false; // checkbox "Ponto 02 - 5ml"

ArrayList<String> listaPontosManual = new ArrayList<String>();
ArrayList<Boolean> listaPontosManualChecked = new ArrayList<Boolean>();

void settings() {
  size(janelaLargura, janelaAltura, P2D);
  pixelDensity(displayDensity());
  smooth(8);
}

void setup() {
  // Carrega múltiplas fontes da pasta "data"
  fonte1 = createFont("InstrumentSans-Bold.ttf", fontTitulo);
  fonte2 = createFont("InstrumentSans-Italic.ttf", fontTitulo);
  fonte3 = createFont("InstrumentSans-SemiBold.ttf", fontTitulo);
  fonte4 = createFont("InstrumentSans-Regular.ttf", fontTitulo);
  fonteAtual = fonte1; // Fonte inicial
  textFont(fonteAtual);
  noStroke();
  
  // Carrega o logo (certifique-se de que "logo.png" esteja na pasta "data")
  logo = loadImage("logo.png");
  logo.resize(150, 0);
  inicializaListaPontosManual();
  
  iconeXY = loadShape("XY.svg"); // Coloque "iconeXY.svg" na pasta data
}
void draw() {
  // Separa as telas de acordo com as variáveis booleanas
  if (telaPrincipal) {
    desenhaTelaPrincipal();
  } 
  else if (telaConfirmar) {
    desenhaTelaConfirmarReferenciamento();
  } 
  else if (telaMovimentacaoManual) {
    // --- Nova tela de Movimentação Manual ---
    desenhaTelaMovimentacaoManual();
  }
  else if (telaPipetagem) {
    // --- Tela de Pipetagem ---
    background(branco);
    // Desenha o logo no canto superior direito
    image(logo, logo.width + 750, -30);
    desenhaTelaPontos();
    
    // Atualiza o tempo de pipetagem se estiver ativo e não pausado
    if (pipetagemAtiva && !pipetagemPausada && tempoRestante > 0) {
      if (frameCount % 60 == 0) {
        tempoRestante--;
      }
    }
  } 
  else {
    // Se houver outra tela (por exemplo, de referenciamento)
    desenhaTelaReferenciar();
  }
}
  
void desenhaTelaPrincipal() {
  background(branco);
  fill(branco);
  rect(blocoEsquerdoX, blocoEsquerdoY, blocoEsquerdoW, blocoEsquerdoH);

  textSize(fontTitulo);
  fill(azulEscuro);
  textAlign(LEFT, TOP);
  text("Bem vindo!", blocoEsquerdoX + 80, blocoEsquerdoY + 255);

  textSize(fontSubtitulo);
  fill(cinzaEscuro);
  text("Projeto mecatrônico", blocoEsquerdoX + 80, blocoEsquerdoY + 230 + 75);

  fill(brancoBege);
  rect(blocoDireitoX, blocoDireitoY, blocoDireitoW, blocoDireitoH);
  
  // Botão "Tutorial" (desenhado duas vezes, conforme seu código original)
  desenhaBotao(80, 350, 120, 40, "Tutorial", brancoBege, azulEscuro);

  textSize(28);
  fill(azulEscuro);
  textAlign(CENTER, TOP);
  text("Escolha o modo\nde operação", blocoDireitoX + blocoDireitoW / 2, blocoDireitoY + 150);

  float botaoLarg = 200;
  float botaoAlt = 40;
  float botaoEspaco = 15;
  float botaoX = blocoDireitoX + blocoDireitoW / 2 - botaoLarg / 2;
  float botaoInicialY = 250;

  // Botoes
  desenhaBotao(botaoX, botaoInicialY, botaoLarg, botaoAlt, "Manual", azulEscuro, branco);
  desenhaBotao(botaoX, botaoInicialY + botaoAlt + botaoEspaco, botaoLarg, botaoAlt, "Automático", azulEscuro, branco);
  desenhaBotao(botaoX, botaoInicialY + 2*(botaoAlt + botaoEspaco), botaoLarg, botaoAlt, "Histórico", azulEscuro, branco);
  
  // Botão "Tutorial" novamente (mantido conforme seu código)
  desenhaBotao(80, 350, 120, 40, "Tutorial", brancoBege, azulEscuro);
}

void desenhaBotao(float x, float y, float w, float h, String rotulo, color corFundo, color corTexto) {
  fill(corFundo);
  rect(x, y, w, h, 8);
  fill(corTexto);
  textSize(fontBotao);
  textAlign(CENTER, CENTER);
  text(rotulo, x + w/2, y + h/2);
}

void keyPressed() {
  if (key == '1') fonteAtual = fonte1;
  if (key == '2') fonteAtual = fonte2;
  if (key == '3') fonteAtual = fonte3;
  if (key == '4') fonteAtual = fonte4;
  textFont(fonteAtual);
}

// Função que trata os cliques na tela principal
void mousePressed_1() {
  // Verifica o clique no botão "Tutorial" (coordenadas: 80,350, 120x40)
  if (mouseX > 80 && mouseX < 80 + 120 &&
      mouseY > 350 && mouseY < 350 + 40) {
    println("Botão TUTORIAL clicado!");
  }
  
  float botaoLarg = 200;
  float botaoAlt  = 40;
  float botaoEspaco = 15;
  float botaoX = blocoDireitoX + blocoDireitoW / 2 - botaoLarg / 2;
  float botaoInicialY = 250;
  
  // Botão "Manual": troca de tela
  if (mouseX > botaoX && mouseX < botaoX + botaoLarg &&
      mouseY > botaoInicialY && mouseY < botaoInicialY + botaoAlt) {
    println("Botão MANUAL clicado!");
    telaPrincipal = false;
    redraw();
  }
  
  // Botão "Automático": apenas exibe mensagem no terminal
  if (mouseX > botaoX && mouseX < botaoX + botaoLarg &&
      mouseY > botaoInicialY + (botaoAlt + botaoEspaco) &&
      mouseY < botaoInicialY + (botaoAlt + botaoEspaco) + botaoAlt) {
    println("Botão AUTOMÁTICO clicado!");
  }
  
  // Botão "Histórico": apenas exibe mensagem no terminal
  if (mouseX > botaoX && mouseX < botaoX + botaoLarg &&
      mouseY > botaoInicialY + 2*(botaoAlt + botaoEspaco) &&
      mouseY < botaoInicialY + 2*(botaoAlt + botaoEspaco) + botaoAlt) {
    println("Botão HISTÓRICO clicado!");
  }
}

void checarCliqueInicio() {
  float botaoLarg = 250;
  float botaoAlt = 48;
  float botaoX = blocoDireitoX + blocoDireitoW / 2 - botaoLarg / 2;
  float botaoY = 250;

  if (mouseX > botaoX && mouseX < botaoX + botaoLarg && mouseY > botaoY && mouseY < botaoY + botaoAlt) {
    telaPrincipal = false;
    redraw();
  }
}

// Função unificada de mousePressed: chama a lógica da tela principal ou de Referenciar
void mousePressed() {
  if (telaPipetagem) {
    mousePressedPipetagem();
  }
  else if (telaPrincipal && !telaConfirmar) {
    mousePressed_1();
  } 
  else if (telaConfirmar) {
    checarCliqueTelaConfirmar();
  } 
  else if (telaMovimentacaoManual) {
    mousePressedTelaMovimentacaoManual();
  }
  else {
    checarCliqueTelaReferenciar();
  }
}

void desenhaCaixaTexto(float x, float y, float w, float h, 
                       String titulo, String valor) {
  fill(brancoBege);
  rect(x, y, w, h, 8);
  fill(azulEscuro);
  textSize(14);
  textAlign(LEFT, TOP);
  text(titulo, x + 10, y + 8);
  
  // Valor no canto direito
  textAlign(RIGHT, BOTTOM);
  textSize(20);
  text(valor, x + w - 10, y + h - 8);
}

void desenhaBoxEsquerda(float x, float y, float w, float h, 
                        String titulo, String valor) {
  // Fundo (cinza claro)
  fill(brancoBege); // #F3F3F3
  noStroke();
  rect(x, y, w, h, 8);

  // Título (ex: "Ponto de coleta") alinhado à esquerda
  fill(azulEscuro);
  textSize(14);
  textAlign(LEFT, CENTER);
  text(titulo, x + 15, y + h/2);

  // Bolinha azul com o "valor" (ex: "+", "1", "4")
  float r = 15; // raio
  float cx = x + w - r - 15; // um pouco afastado da borda
  float cy = y + h/2;
  fill(azulClaro); // #0084FF
  ellipse(cx, cy, 2*r, 2*r);

  fill(branco);
  textSize(16);
  textAlign(CENTER, CENTER);
  text(valor, cx, cy);
}

void desenhaIconButton(float x, float y, float w, float h,
                       String rotulo, String icone) {
  // Fundo azul escuro
  fill(azulEscuro); // #0C4E8C
  noStroke();
  rect(x, y, w, h, 8);

  // Ícone (ex: "||", "■") na parte de cima
  fill(branco);
  textSize(20);
  textAlign(CENTER, CENTER);
  text(icone, x + w/2, y + h/2 - 10);

  // Rotulo (ex: "Pausa pipetagem") na parte de baixo
  textSize(12);
  text(rotulo, x + w/2, y + h/2 + 12);
}

void desenhaCaixaComIcone(float x, float y, float w, float h,
                          String icone, String rotulo,
                          boolean iconeNaEsquerda) {
  // Fundo branco
  fill(branco);
  noStroke();
  rect(x, y, w, h, 8);

  // Círculo azulClaro (#0084FF) com o ícone dentro
  float r = 14;
  float cx, cy = y + h/2;
  if (iconeNaEsquerda) {
    cx = x + r + 10; // bolinha perto da esquerda
  } else {
    cx = x + w - r - 10; // bolinha perto da direita
  }
  fill(azulClaro);
  ellipse(cx, cy, 2*r, 2*r);

  // Ícone dentro da bolinha (ex: "+", "1", "4")
  fill(branco);
  textSize(16);
  textAlign(CENTER, CENTER);
  text(icone, cx, cy);

  // Texto do rotulo (ex: "Ponto de coleta")
  fill(azulEscuro);
  textSize(14);
  textAlign(LEFT, CENTER);

  // Se o ícone está na esquerda, o texto fica um pouco à direita
  // Se o ícone está na direita, o texto fica na esquerda
  if (iconeNaEsquerda) {
    text(rotulo, cx + r + 8, cy); 
  } else {
    textAlign(RIGHT, CENTER);
    text(rotulo, cx - r - 8, cy);
  }
}

void desenhaCaixaAzulComTexto(float x, float y, float w, float h,
                              String icone, String texto) {
  // Fundo azulClaro (#0084FF)
  fill(azulClaro);
  noStroke();
  rect(x, y, w, h, 8);

  // Ícone (ex: "+") e texto (ex: "Ponto de coleta"), ambos brancos
  fill(branco);
  textSize(16);
  textAlign(LEFT, CENTER);

  float margin = 15;
  // Desenha o ícone
  text(icone, x + margin, y + h/2);

  // Desenha o texto logo após o ícone
  float gap = textWidth(icone) + 10; 
  text(texto, x + margin + gap, y + h/2);
}

void desenhaCaixaCinzaComNumero(float x, float y, float w, float h,
                                String rotulo, String numero) {
  // Fundo brancoBege
  fill(brancoBege);
  noStroke();
  rect(x, y, w, h, 8);

  // Texto do rótulo, cor azulEscuro
  fill(azulEscuro);
  textSize(16);
  textAlign(LEFT, CENTER);
  text(rotulo, x + 15, y + h/2);

  // Definindo o raio do quarto de círculo
  float r = 20;
  // Posiciona o arco no canto superior esquerdo da área direita da caixa:
  // Agora, para espelhar, posicionamos o centro no canto superior esquerdo
  // dentro de uma área com margem à esquerda.
  float cx = x + 15 + r; // deslocado a partir da margem esquerda
  float cy = y + r + 5;  // ajuste vertical para centralização – experimente
  
  // Desenha um arco (modo PIE) representando um quarto de círculo.
  // Para o canto superior esquerdo, o arco vai do 0 até HALF_PI.
  fill(azulClaro);
  arc(cx, cy, 2*r, 2*r, 0, HALF_PI, PIE);

  // Número centralizado dentro do arco:
  fill(branco);
  textSize(16);
  textAlign(CENTER, CENTER);
  text(numero, cx, cy);
}

void desenhaBotaoIcone(float x, float y, float w, float h,
                       String icone, String texto) {
  // Fundo azulEscuro (#0C4E8C)
  fill(azulEscuro);
  noStroke();
  rect(x, y, w, h, 8);

  // Ícone na parte de cima
  fill(branco);
  textSize(20);
  textAlign(CENTER, CENTER);
  text(icone, x + w/2, y + h/2 - 10);

  // Texto na parte de baixo
  textSize(12);
  text(texto, x + w/2, y + h/2 + 12);
}
