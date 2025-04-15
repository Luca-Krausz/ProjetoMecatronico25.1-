// Globals.pde
import processing.serial.*;

// ------------------ GLOBAL VARIABLES ------------------

// Fonts
PFont fonteAtual;
PFont fonte1, fonte2, fonte3, fonte4;

// Colors
color azulEscuro  = color(12, 78, 140);
color branco      = color(255, 255, 255);
color brancoBege  = color(243, 243, 243);
color azulClaro   = color(0, 132, 255);
color cinzaEscuro = color(105, 105, 105);
color cinzaClaro  = color(211, 211, 211);
color cinzaMedio  = color(169, 169, 169);
color verdeBotao = color(0x00, 0xAA, 0x41);

// Window size
int janelaLargura = 1024;
int janelaAltura  = 600;

// Font sizes
int fontTitulo    = 50;
int fontSubtitulo = 17;
int fontBotao     = 20;

// Booleans of buttons
boolean telaInicio         = true;
boolean telaReferenciar    = false;
boolean telaPipetagem      = false;
boolean telaPontosColeta   = false;
boolean telaPontosDispensa = false;
boolean telaReferenciarI2C = false;
boolean pressedPontoColeta = false;
boolean pressedPontoDispensa = false;
boolean pressedIniciarPipetagem = false;
boolean pressedPausa = false;
boolean pressedParar = false;
boolean pressedPontosTotaisColeta = false;

// Variaveis globais
int pontosColeta   = 0;
int pontosDispensa = 0;
int tempoRestante  = 50;
boolean pipetagemAtiva   = false;
boolean pipetagemPausada = false;
boolean inicio_config = false;
int movSpeed       = 1;  // 1mm, 10mm, 30mm
String command = "";

int maxX = 665;
int minX = 0;
int maxY = 560;
int minY = 0;
int maxZ = 100;
int minZ = 0;

// Shapes for the directional pad
PShape dirPad;
PShape[] segments = new PShape[4];

// ArrayLists, etc.
ArrayList<String>  listaPontosManual        = new ArrayList<String>();
ArrayList<Boolean> listaPontosManualChecked = new ArrayList<Boolean>();

// Images / Shapes
PImage homeXY, homeZ, logo, trash, editpen, addicon, backIcon;
PShape iconeXY;

// Botão voltar 
Button backButton;

// Porta UART com Raspberry
Serial porta;


// ------------------ SETTINGS & SETUP ------------------
void settings() {
  size(janelaLargura, janelaAltura, P2D);
}

void setup() {
  // Load fonts
  fonte1 = createFont("InstrumentSans-Bold.ttf",    fontTitulo);
  fonte2 = createFont("InstrumentSans-Italic.ttf",  fontTitulo);
  fonte3 = createFont("InstrumentSans-SemiBold.ttf",fontTitulo);
  fonte4 = createFont("InstrumentSans-Regular.ttf", fontTitulo);
  fonteAtual = fonte1;
  textFont(fonteAtual);

  // Load images, shapes
  logo = loadImage("logo.png");
  if (logo != null) {
    logo.resize(150, 0);
  }
  iconeXY = loadShape("XY.svg");
  homeXY = loadImage("homeXY.png");
  homeZ = loadImage("homeZ.png");
  
  trash = loadImage("trash.png");
  trash.resize(50,0);
  
  editpen = loadImage("editpen.png");
  editpen.resize(50,0);
  
  addicon = loadImage("addicon.png");
  addicon.resize(50,0);
  
  backIcon = loadImage("backIcon.png");
  backIcon.resize(25,0);
  
  // Botão voltar
  backButton = new Button(false, width - 30, 35, 40, 40, backIcon, azulEscuro); // (square?, x, y, w, h, icon, bgColor)
    
  // Any array initializations
  inicializaListaPontosManual();

  // UART Comms
  porta = new Serial(this, "/dev/ttyAMA0", 9600);

  noStroke();
}

// ------------------ MAIN DRAW ------------------
void draw() {
  background(branco);

  // Decide qual tela mostrar
  if (telaInicio) {
    if (!inicio_config){
     setupTelaInicio(); 
    }
    desenhaTelaInicio();
  }
  else if (telaReferenciar) {
    desenhaTelaReferenciar();
  }
  else if (telaReferenciarI2C) {
    desenhaRefI2C();
  }
  else if (telaPipetagem) {
    desenhaTelaPipetagem();
    
    // Example: pipetagem countdown
    if (pipetagemAtiva && !pipetagemPausada && tempoRestante > 0) {
      if (frameCount % 60 == 0) {
        tempoRestante--;
      }
    }
  }
  else if (telaPontosDispensa) {
    desenhaTelaPontosDispensa();
  }
  else {
    // fallback
    desenhaTelaPipetagem();
  }
}

// ------------------ MAIN MOUSEPRESSED ------------------
void mousePressed() {
  
  if (telaInicio) {
    mousePressedInicio();
  }
  else if (telaReferenciar) {
    mousePressedReferenciar();
  }
  else if (telaReferenciarI2C) {
    mousePressedRefI2C();
  }
  else if (telaPipetagem) {
    mousePressedPipetagem();
  }
  else if (telaPontosDispensa) {
    mousePressedTelaMovimentacaoManual();
  }
}

// ------------------ MAIN MOUSERELEASED ------------------
// Complement the press & release approach:
void mouseReleased() {
  // Colocar a tela para conseguir 
  if (telaPontosDispensa) {
    mouseReleasedTelaMovimentacaoManual();
  }
  else if (telaPipetagem) {
     mouseReleasedPipetagem(); 
  }
  else if (telaInicio) {
     mouseReleasedInicio();
  }
  else if (telaReferenciar) {
      mouseReleasedReferenciar();
  }
  else if (telaReferenciarI2C) {
     mouseReleasedRefI2C();
  }
}
//----------------------------------------------------------------------------------------
//                                      FUNÇÕES GLOBAIS 
//----------------------------------------------------------------------------------------
// 1. Simple button
void desenhaBotao(float x, float y, float w, float h,
                  String rotulo, color corFundo, color corTexto) {
  fill(corFundo);
  rect(x, y, w, h, 8);
  fill(corTexto);
  textSize(fontBotao);
  textAlign(CENTER, CENTER);
  text(rotulo, x + w/2, y + h/2);
}

// 2. Example initialization for manual points
void inicializaListaPontosManual() {
  listaPontosManual.clear();
  listaPontosManual.add("Ponto 01 - 3ml");
  listaPontosManual.add("Ponto 02 - 5ml");

  listaPontosManualChecked.clear();
  listaPontosManualChecked.add(true);
  listaPontosManualChecked.add(false);
}

// 3. 'Voltar' round button
void desenhaBotaoVoltar(float cx, float cy, float diameter) {
  fill(azulEscuro);
  noStroke();
  ellipse(cx, cy, diameter, diameter);
  fill(branco);
  float arrowSize = 8;
  triangle(cx - arrowSize/2, cy,
           cx + arrowSize/2, cy - arrowSize,
           cx + arrowSize/2, cy + arrowSize);
}

// 4. Classe "Botao precisao" 
class SegmentedButton {
  float x, y, w, h;
  String[] labels;
  color[] bgColors;
  color textColor;
  int selectedIndex = 0;  // which segment is currently active
  int pressedIndex  = -1; // which segment is being pressed, if any
  
  SegmentedButton(float x, float y, float w, float h, 
                  String[] labels, color[] bgColors, color textColor) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.labels = labels;
    this.bgColors = bgColors;
    this.textColor = textColor;
  }
  
  void draw() {
    float segmentWidth = w / labels.length;
    
    // Outer rectangle as a border (optional style)
    stroke(azulEscuro);
    strokeWeight(2);
    fill(azulEscuro);
    rect(x, y, w, h, h/2);  // Using h/2 to get a pill shape
    noStroke();
    
    // Draw each segment
    for (int i = 0; i < labels.length; i++) {
      color currentBg = azulEscuro; // default
      if (i == selectedIndex && i < bgColors.length) {
        currentBg = bgColors[i];
      }
      // Darken if pressed
      if (i == pressedIndex) {
        currentBg = lerpColor(currentBg, color(0), 0.2);
      }
      
      fill(currentBg);
      float segX = x + i * segmentWidth;
      
      // Round corners depending on position
      if (labels.length == 1) {
        // Only one segment
        rect(segX, y, segmentWidth, h, h/2);
      } 
      else if (i == 0) {
        // Left end
        rect(segX, y, segmentWidth, h, h/2, 0, 0, h/2);
      } 
      else if (i == labels.length - 1) {
        // Right end
        rect(segX, y, segmentWidth, h, 0, h/2, h/2, 0);
      } 
      else {
        // Middle
        rect(segX, y, segmentWidth, h);
      }
      
      // Segment label
      fill(branco);
      textSize(fontBotao);
      textAlign(CENTER, CENTER);
      text(labels[i], segX + segmentWidth/2, y + h/2);
    }
  }
  
  // Check which segment (if any) was clicked
  int getClickedSegment() {
    float segmentWidth = w / labels.length;
    if (mouseX >= x && mouseX <= x + w &&
        mouseY >= y && mouseY <= y + h) {
      // which segment?
      int index = int((mouseX - x) / segmentWidth);
      // clamp it just in case
      return constrain(index, 0, labels.length - 1);
    }
    return -1;
  }
  
  // Called from mousePressed (outside this class)
  void mousePressed() {
    pressedIndex = getClickedSegment();
  }
  
  // Called from mouseReleased
  void mouseReleased() {
    int clicked = getClickedSegment();
    if (clicked == pressedIndex && clicked >= 0) {
      // Update selected index
      selectedIndex = clicked;
      
      // Convert label to an integer.
      // e.g. '1mm', '10mm', '30mm'.
      // This removes all non-digits so spaces or extra chars don't break it.
      String numericPart = labels[selectedIndex].replaceAll("\\D+", "");
      if (numericPart.length() > 0) {
        movSpeed = Integer.parseInt(numericPart);
      }
      println("SegmentedButton -> selectedIndex=" + selectedIndex 
              + ", label=" + labels[selectedIndex] + ", movSpeed=" + movSpeed);
    }
    pressedIndex = -1;
  }
}

// 5. Classe botao
class Button {
  float x, y, w, h;
  String label;
  color bgColor, textColor;
  PImage icon; // optional image for the button
  
  boolean isSelected = false; // toggles color if 'active'
  boolean isPressed  = false; // darkens color while pressed
  
  boolean square;
  
  // Constructor for text-based buttons
  Button(boolean square, float x, float y, float w, float h,  // (square?, x, y, w, h, label, bgColor, textcolor)
         String label, color bgColor, color textColor) {
    this.x = x; 
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.bgColor = bgColor;
    this.textColor = textColor;
    this.square = square;
    this.icon = null; // no icon by default
  }
  
  // Constructor for icon-based buttons
  Button(boolean square, float x, float y, float w, float h, // (square?, x, y, w, h, icon, bgColor)
         PImage icon, color bgColor) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.icon = icon;
    this.bgColor = bgColor;
    this.textColor = color(255); // default text color (unused if icon is present)
    this.square = square;
    this.label = "";
  }
  
void draw() {
  color currentBg = bgColor;
  if (isPressed) {
    currentBg = cinzaEscuro; // darken if pressed
  }
  else if (isSelected) {
    currentBg = azulClaro;  // highlight if selected
  }
  
  fill(currentBg);
  if (square) {
    rect(x, y, w, h, 8);
    
    // Centraliza icone para o retangulo
    if (icon != null) {
      float iconX = x + (w - icon.width) / 2;
      float iconY = y + (h - icon.height) / 2;
      image(icon, iconX, iconY);
    } else {
      fill(textColor);
      textSize(fontBotao);
      textAlign(CENTER, CENTER);
      text(label, x + w/2, y + h/2);
    }
  } else {
    // Centraliza icone em elipses
    ellipse(x, y, w, h);
    
    if (icon != null) {
      float iconX = x - icon.width / 2;
      float iconY = y - icon.height / 2;
      image(icon, iconX, iconY);
    } else {
      fill(textColor);
      textSize(fontBotao);
      textAlign(CENTER, CENTER);
      text(label, x, y);
    }
  }
}
  
boolean isMouseOver() {
  if (square) {
    return (mouseX >= x && mouseX <= x + w && 
            mouseY >= y && mouseY <= y + h);
  } else {
    float dx = mouseX - x;
    float dy = mouseY - y;
    
    float a = w/2;
    float b = h/2;
    return ((dx*dx)/(a*a) + (dy*dy)/(b*b)) <= 1;
    }
  }
}
