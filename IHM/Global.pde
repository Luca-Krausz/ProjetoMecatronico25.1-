// Import all the libraries
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
color verdeBotao  = color(0x00, 0xAA, 0x41);

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
boolean telaEditaPontos = false;
boolean pressedPontoColeta = false;
boolean pressedPontoDispensa = false;
boolean pressedIniciarPipetagem = false;
boolean pressedPausa = false;
boolean pressedParar = false;
boolean pressedPontosTotaisColeta = false;

// Variaveis globais
int pontosColeta         = 0;
int pontosDispensa       = 0;
int tempoRestante        = 50; // EDITAR ESSA PARTE SEGUNDO FORMULA DE DESLOCAMENTO DA MAQUINA
boolean pipetagemAtiva   = false;
boolean pipetagemPausada = false;
boolean inicio_config    = false;
boolean xyLocked         = false;
boolean zLocked          = false;
int movSpeed             = 1;    // 1mm, 10mm, 30mm
int maxVisiblePoints     = 5;
int[] coordenadas = {0, 0, 0};         // X, Y, Z coordinates 
int[] coordenadasColeta = {0, 0, 0};    // X, Y, Z coordinates for Collecting Points
String[] precisionLabels = {"1mm", "10mm", "30mm"};  // Global precision labels
String command = "";

boolean coordsIguais(int[] a, int[] b) {
  return a[0] == b[0] && a[1] == b[1] && a[2] == b[2];
} // Conferencia caso haja pontos de coleta duplicados

// Booleans for buttons:
boolean scrollingUp    = false;
boolean scrollingDowm  = false;
int scrollOffset       = 0;
int scrollOffsetColeta       = 0;
int selectedPoint      = -1;
int pontoColetaSelecionadoIndex = -1;
int currentColetaIndex = 0;
boolean edicaoColetaEdit = false;
boolean pipetagemRef = false;

// For the scroll arrow buttons 
boolean hasItemsAbove = false;
boolean hasItemsBelow = false;

int maxX = 665;
int minX = 0;
int maxY = 560;
int minY = 0;
int maxZ = 100;
int minZ = 0;

// Shapes 
PShape dirPad;
PShape iconeXY;
PShape[] segments = new PShape[4];

// ArrayLists, etc.
ArrayList<String>  listaPontosManual        = new ArrayList<String>();
ArrayList<Boolean> listaPontosManualChecked = new ArrayList<Boolean>();
ArrayList<Ponto> listaPontosDispensa = new ArrayList<Ponto>();
ArrayList<Ponto> listaPontosColeta = new ArrayList<Ponto>();

// Lista de Ponto(s) que foram marcados para edição na tela de edição
ArrayList<Ponto> pontosEmEdicao = new ArrayList<Ponto>();


// Images / Shapes
PImage homeXY, homeZ, logo, trash, editpen, addicon, backIcon;


// Botões
Button backButton, lockXYButton, lockZButton, z_plus, z_minus, z_home, xy_home;

// Botão de Precisão
SegmentedButton precisionSelector;  // Using only the SegmentedButton for precision

// Mensagem de erro ao adicionar dispensa sem coleta ou coleta duplicada
String mensagemErroDispensa = "";
String mensagemErroColeta = "";

// Porta UART com Raspberry
Serial porta;

// Gera string agrupando dispensas por coleta (Uso para debug e ver se as coletas tao relacionando as dispensas corretas):
String gerarStringColetasDispensas() {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < listaPontosColeta.size(); i++) {
        Ponto coleta = listaPontosColeta.get(i);
        sb.append("coleta ").append(i + 1).append(": ");
        boolean primeiro = true;
        for (int j = 0; j < listaPontosDispensa.size(); j++) {
            Ponto disp = listaPontosDispensa.get(j);
            if (coordsIguais(disp.coordsColeta, coleta.coords)) {
                if (!primeiro) sb.append(", ");
                sb.append("dispensa ").append(j + 1);
                primeiro = false;
            }
        }
        if (i < listaPontosColeta.size() - 1) sb.append("\n");
    }
    return sb.toString();
}



// ------------------ SETTINGS & SETUP ------------------
void settings() {
  size(janelaLargura, janelaAltura, P2D);
}

void setup() {
  // Load fonts
  fonteAtual = createFont("InstrumentSans-Bold.ttf",    fontTitulo);
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
  
  addicon = loadImage("plus.png");
  addicon.resize(50,0);
  
  backIcon = loadImage("backIcon.png");
  backIcon.resize(25,0);
  
  // Back Button
  backButton = new Button(false, width - 30, 35, 40, 40, backIcon, azulEscuro); // (square?, x, y, w, h, icon, bgColor)
  
  // Initialize precision selector using the global precisionLabels array
  color[] precisionColors = {verdeBotao, verdeBotao, verdeBotao};
  precisionSelector = new SegmentedButton(100, 30, 300, 40, precisionLabels, precisionColors, azulEscuro);
  precisionSelector.selectedIndex = 0;

  // Draw the Buttons for the Z axis
  z_plus = new Button(true, 500, height - 490, 95, 95, "Z+", azulEscuro, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  z_minus = new Button(true, 500, height - 192, 95, 95, "Z-", azulEscuro, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  z_home = new Button(true, 500, height - 341, 95, 95, homeZ, azulEscuro); //(square?, x, y, w, h, icon, bgColor)

  // Draw the Button for the home XY
  xy_home = new Button(false, 250, 300, 100, 100, homeXY, azulEscuro);
  
  // Lock buttons
  lockXYButton = new Button(true, 120, height - 120, 120, 40, "Lock XY", cinzaMedio, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  lockZButton  = new Button(true, 260, height - 120, 120, 40, "Lock Z",  cinzaMedio, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  
  // Draw the direction pad (Buttons for XY axis)
  botao_direcional(250, 300, 150, 80);

  // UART Comms
  //println("Portas disponíveis:" + Serial.list());
  //porta = new Serial(this, "/dev/ttyAMA0", 9600);
  //porta = new Serial(this, "COM4", 9600);

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
    edicaoColetaEdit = false;
  }
  else if (telaPontosColeta) {
    desenhaTelaPontosColeta(); 
    edicaoColetaEdit = true;
  }
  else if (telaEditaPontos) {
    desenhaTelaEditaPontos(); 
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
  else if(telaPontosColeta) {
   mousePressedTelaPontosColeta(); 
  }
  else if(telaEditaPontos) {
   mousePressedTelaEditaPontos(); 
  }
}

// ------------------ MAIN MOUSERELEASED ------------------
// Complement the press & release approach:
void mouseReleased() {

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
  else if(telaPontosColeta){
   mouseReleasedTelaPontosColeta(); 
  }
  else if(telaEditaPontos){
   mouseReleasedTelaEditaPontos(); 
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


// 2. 'Voltar' round button
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



// 3. Classe "Botao precisao" 
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



// 4. Classe botao
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



// 6. Classe Ponto
class Ponto {
  String nome;
  int volume;
  int[] coords = {0, 0, 0};
  int[] coordsColeta = {0, 0, 0}; // Collection coords: x_coleta, y_coleta, z_coleta
  boolean selected = false;

  // Added xc, yc, zc parameters for collection coordinates
  Ponto(String n, int v, int x, int y, int z, int xc, int yc, int zc) {
    nome       = n;
    volume     = v;
    coords[0]  = x;
    coords[1]  = y;
    coords[2]  = z;
    coordsColeta[0] = xc;
    coordsColeta[1] = yc;
    coordsColeta[2] = zc;
  }

  // toString for Dispensa list display (Name + Volume)
  String toStringDispensa() {
    return nome + " - " + volume + "ml";
  }

  // toString for Coleta list display (Just Name)
  String toStringColeta() {
    return nome;
  }

  // Get primary coordinates as string
  String coordsToString() {
      return "( " + coords[0] + ", " + coords[1] + ", " + coords[2] + " )";
  }

  // Get associated Coleta coordinates as string (for potential display/debug)
   String coordsColetaToString() {
      return "( " + coordsColeta[0] + ", " + coordsColeta[1] + ", " + coordsColeta[2] + " )";
  }

// 3. Gera string agrupando dispensas por coleta, usando nomes editáveis
String gerarStringColetasDispensas() {
  StringBuilder sb = new StringBuilder();
  for (int i = 0; i < listaPontosColeta.size(); i++) {
    Ponto coleta = listaPontosColeta.get(i);
    sb.append(coleta.nome).append(": ");
    boolean primeiro = true;
    for (int j = 0; j < listaPontosDispensa.size(); j++) {
      Ponto disp = listaPontosDispensa.get(j);
      if (coordsIguais(disp.coordsColeta, coleta.coords)) {
        if (!primeiro) sb.append(", ");
        sb.append(disp.nome);
        primeiro = false;
      }
    }
    if (i < listaPontosColeta.size() - 1) sb.append("\n");
  }
  return sb.toString();
}

}




// 7. Funcao Desenha lista de Pontos Coleta

void drawPointsList(ArrayList<Ponto> list, int scrollOffset, boolean isColetaScreen) {
  
  int y = 0;
  
  if (isColetaScreen) {
      y = 150; 
    } else {
      y = 280; 
    }
    
  int startY = y;
  int itemH = 35;
  int listX = width - 340;
  int textMarginLeft = 10;
  int checkboxSize = 20;
  int checkboxMargin = 10;

  fill(azulEscuro);
  textSize(18);
  textAlign(LEFT, CENTER);

  // Determine visible range
  int startIndex = scrollOffset;
  int endIndex = min(list.size(), startIndex + maxVisiblePoints);

  // --- Scroll Indicators (Visual only, logic is handled outside) ---
  boolean hasAbove = scrollOffset > 0;
  boolean hasBelow = endIndex < list.size();

  if (hasAbove) {
    fill(cinzaMedio);
    textAlign(CENTER, CENTER);
    if (isColetaScreen) {
      text("^", width - 180, startY - 30);
    }
    else{
      text("^", width - 180, startY - 15);
    }
  }
  if (hasBelow) {
    fill(cinzaMedio);
    textAlign(CENTER, CENTER);
    if (isColetaScreen) {
      text("v", width - 170, startY + maxVisiblePoints * itemH);
    }
    else{
      text("v", width - 170, startY - 15 + maxVisiblePoints * itemH);
    }
  }


  // Loop through and draw visible points
  for (int i = startIndex; i < endIndex; i++) {
    Ponto ponto = list.get(i);
    int itemY = startY + (i - startIndex) * itemH;

    // Selection highlight
    if (ponto.selected) {
      fill(cinzaClaro);
      noStroke();
      rect(width - 330, itemY - 15, 225, 30, 5);
    }

    // --- Item Content ---
    float currentX = listX + checkboxMargin;

    // Checkbox
    stroke(azulEscuro);
    strokeWeight(1.5);
    fill(branco);
    rect(currentX, itemY - checkboxSize/2, checkboxSize, checkboxSize, 3);
    if (ponto.selected) {
      fill(azulEscuro);
      noStroke();
      rect(currentX + 4, itemY - (checkboxSize/2) + 4, checkboxSize - 8, checkboxSize - 8, 2);
    }
    noStroke();
    currentX += checkboxSize + textMarginLeft;

    // Point Name (Conditional display)
    fill(azulEscuro);
    textAlign(LEFT, CENTER);
    if (isColetaScreen) {
      text(ponto.toStringColeta(), currentX, itemY); // Just name for Coleta
    } else {
      text(ponto.toStringDispensa(), currentX, itemY); // Name + Volume for Dispensa
    }


  }
}


// 8. Funcao para adicionar um ponto na lista

void addNewPoint(ArrayList<Ponto> list, String baseName, boolean isColetaScreen, int[] currentCoords, int[] associatedCoordsColeta) {
  int nextPointNum = list.size() + 1;
  String pointName = baseName + " " + nf(nextPointNum, 2); // Format name (e.g., "Coleta 01", "Ponto 01")

  Ponto newPoint;
  if (isColetaScreen) {
    // For Coleta points: Volume is 0, associated Coleta coords are irrelevant (set to 0,0,0)
    newPoint = new Ponto(pointName, 0,
                         currentCoords[0], currentCoords[1], currentCoords[2],
                         0, 0, 0); // Own coords are current, Coleta coords N/A
    println("Added Collection Point: " + newPoint.nome + " " + newPoint.coordsToString());
  } else {
    // For Dispensa points: Use default volume (e.g., 3ml), store current coords as its own,
    // and store the passed associatedCoordsColeta.
    int defaultVolume = 3; // Or get from UI if needed
    if (associatedCoordsColeta == null) {
        println("ERROR: Cannot add Dispense point without associated Collection point coordinates!");
        return; // Do not add the point
    }
    newPoint = new Ponto(pointName, defaultVolume,
                         currentCoords[0], currentCoords[1], currentCoords[2],
                         associatedCoordsColeta[0], associatedCoordsColeta[1], associatedCoordsColeta[2]);
    //println("Added Dispense Point: " + newPoint.nome + " " + newPoint.coordsToString() + " -> Assoc. Coleta: " + newPoint.coordsColetaToString());
  }

  list.add(newPoint);
}




// 9. Funcao para apagar pontos na lista

int deleteSelectedPoints(ArrayList<Ponto> list, int scrollOffset, String baseName) {
  int deletedCount = 0;
  //int initialSize = listaPontos.size();

  // Iterate backwards when removing
  for (int i = list.size() - 1; i >= 0; i--) {
    if (list.get(i).selected) {
      println("Deleting: " + list.get(i).nome);
      list.remove(i);
      deletedCount++;
    }
  }

  if (deletedCount > 0) {
    // Re-number remaining points
    for (int i = 0; i < list.size(); i++) {
      String pointName = baseName + " " + nf(i + 1, 2);
      list.get(i).nome = pointName;
      // Keep existing volume/coords/associated coords
    }

    // Adjust scroll offset if the view is now past the end of the list
    int newScrollOffset = scrollOffset;
    if (newScrollOffset > 0 && newScrollOffset >= list.size() - maxVisiblePoints) {
      newScrollOffset = max(0, list.size() - maxVisiblePoints);
    }
    // Also handle case where items were deleted from view but not enough to scroll back fully
    if (scrollOffset > list.size() - maxVisiblePoints) {
         newScrollOffset = max(0, list.size() - maxVisiblePoints);
    }


    println(deletedCount + " point(s) deleted. New scroll offset: " + newScrollOffset);
    return newScrollOffset; // Return adjusted offset

  } else {
    println("No points selected for deletion.");
    return scrollOffset; // Return original offset if nothing changed
  }
  // Note: Update global counters (pontosColeta/pontosDispensa) AFTER calling this function.
}



// 10. Funcao para editar pontos na lista

void editSelectedPoints(ArrayList<Ponto> list, boolean isColetaScreen, int[] currentCoords, int[] associatedCoordsColeta) {
  ArrayList<Ponto> pointsToEdit = new ArrayList<Ponto>();
  for (Ponto p : list) {
    if (p.selected) {
      pointsToEdit.add(p);
    }
  }

  if (pointsToEdit.isEmpty()) {
    println("No points selected to edit.");
    return;
  }
  
  else {
    if (!isColetaScreen) {
      telaPontosDispensa = false;
      telaEditaPontos = true;
    }   
    else {
    telaPontosColeta = false;
    telaEditaPontos = true;
    }
  }
  
  println("Editing " + pointsToEdit.size() + " selected point(s)...");

  for (Ponto point : pointsToEdit) {
    // Always update the point's OWN coordinates to the current machine coordinates
    point.coords[0] = currentCoords[0];
    point.coords[1] = currentCoords[1];
    point.coords[2] = currentCoords[2];
    print("Updated " + point.nome + " coords to " + point.coordsToString());

    // If editing a Dispensa point, potentially update its associated Coleta point
    if (!isColetaScreen) {
      if (associatedCoordsColeta != null) {
        point.coordsColeta[0] = associatedCoordsColeta[0];
        point.coordsColeta[1] = associatedCoordsColeta[1];
        point.coordsColeta[2] = associatedCoordsColeta[2];
        print(" -> Associated Coleta: " + point.coordsColetaToString());
      } else {
         print(" -> Associated Coleta NOT updated (none selected).");
      }
    }
    println(); // Newline for next point message
  }
   println("Edit complete.");
   // Option B: Navigate to a dedicated editing screen would go here instead
}
