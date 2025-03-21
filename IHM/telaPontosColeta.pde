// ============================================================================
// File: PontosColeta.pde
// Description: Screen for manually controlling the pipettor and marking points
//              to define coordinate + volume. No keyPressed is used now.
//              All user actions are handled by mouse press / release on a
//              7" touchscreen.
// ============================================================================

// -----------------------------------------------------------------------------
// Screen-specific data
// -----------------------------------------------------------------------------
int[] coordenadas = {0, 0, 0};    // X, Y, Z coordinates
ArrayList<PontoColeta> listaPontos = new ArrayList<PontoColeta>();

boolean scrollingUp    = false;
boolean scrollingDown  = false;
int scrollOffset       = 0;
int maxVisiblePoints   = 5;
int selectedPoint      = -1;

// Global lock states
boolean xyLocked = false;
boolean zLocked  = false;

// UI elements
Button addButton, deleteButton, editButton, lockXYButton, lockZButton;
SegmentedButton precisionSelector;  // Using only the SegmentedButton for precision
String[] precisionLabels = {"1mm", "10mm", "30mm"};  // Global precision labels

// Scroll arrow buttons
Button scrollUpButton, scrollDownButton;
boolean hasItemsAbove = false;
boolean hasItemsBelow = false;

// -----------------------------------------------------------------------------
// Classes for handling points & buttons
// -----------------------------------------------------------------------------
class PontoColeta {
  String nome;
  int volume;
  int[] coords = {0, 0, 0};
  boolean selected = false;
  
  PontoColeta(String n, int v, int x, int y, int z) {
    nome      = n;
    volume    = v;
    coords[0] = x;
    coords[1] = y;
    coords[2] = z;
  }
  
  String toString() {
    // e.g. 'Ponto 01 - 3ml' plus coordinates
    return nome + " - " + volume + "ml";
  }
}

class Button {
  float x, y, w, h;
  String label;
  color bgColor, textColor;
  PImage icon; // optional image for the button
  
  boolean isSelected = false; // toggles color if 'active'
  boolean isPressed  = false; // darkens color while pressed
  
  // Constructor for text-based buttons
  Button(float x, float y, float w, float h, 
         String label, color bgColor, color textColor) {
    this.x = x; 
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.bgColor = bgColor;
    this.textColor = textColor;
    this.icon = null; // no icon by default
  }
  
  // Constructor for icon-based buttons
  Button(float x, float y, float w, float h, 
         PImage icon, color bgColor) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.icon = icon;
    this.bgColor = bgColor;
    this.textColor = color(255); // default text color (unused if icon is present)
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
    rect(x, y, w, h, 8);
    
    if (icon != null) {
      // Center the icon inside the button
      float iconX = x + (w - icon.width) / 2;
      float iconY = y + (h - icon.height) / 2;
      image(icon, iconX, iconY);
    } else {
      fill(textColor);
      textSize(fontBotao);
      textAlign(CENTER, CENTER);
      text(label, x + w/2, y + h/2);
    }
  }
  
  boolean isMouseOver() {
    return (mouseX >= x && mouseX <= x + w && 
            mouseY >= y && mouseY <= y + h);
  }
}

// -----------------------------------------------------------------------------
// Build the directional pad (dirPad + segments are from Globals.pde).
// -----------------------------------------------------------------------------
void botao_direcional(float x, float y, float raioMaior, float raioMenor) {
  dirPad = createShape(GROUP);

  for (int i = 0; i < 4; i++) {
    segments[i] = createShape();
    segments[i].beginShape();
    segments[i].fill(azulEscuro);
    segments[i].stroke(255);
    segments[i].strokeWeight(10);

    float alpha_inicial = PI/4 + i * PI/2;
    float alpha_final   = 3*PI/4 + i * PI/2;

    for (float a = alpha_inicial; a <= alpha_final; a += 0.01) {
      float sx = x + cos(a)*raioMenor;
      float sy = y + sin(a)*raioMenor;
      segments[i].vertex(sx, sy);
    }
    for (float a = alpha_final; a >= alpha_inicial; a -= 0.01) {
      float sx = x + cos(a)*raioMaior;
      float sy = y + sin(a)*raioMaior;
      segments[i].vertex(sx, sy);
    }

    segments[i].endShape(CLOSE);
    dirPad.addChild(segments[i]);
  }
}

// -----------------------------------------------------------------------------
// The setup function for 'PontosColeta'
// -----------------------------------------------------------------------------
void setupTelaPontosColeta() {
  // Create UI elements (positions approximate)
  addButton    = new Button(width - 327, height - 180, 80, 80, addicon,  azulEscuro);
  editButton   = new Button(width - 227, height - 180, 80, 80, editpen,  azulEscuro);
  deleteButton = new Button(width -  127, height - 180, 80, 80, trash,  azulEscuro);
  
  // Lock buttons
  lockXYButton = new Button(120, height - 120, 120, 40, "Lock XY", cinzaMedio, branco);
  lockZButton  = new Button(260, height - 120, 120, 40, "Lock Z",  cinzaMedio, branco);
  
  scrollUpButton   = new Button(width - 100, height/2 - 150, 40, 40, "↑", azulEscuro, branco);
  scrollDownButton = new Button(width - 100, height/2 + 10, 40, 40, "↓", azulEscuro, branco);
  
  // Initialize precision selector using the global precisionLabels array
  color[] precisionColors = {verdeBotao, verdeBotao, verdeBotao};
  precisionSelector = new SegmentedButton(100, 30, 300, 40, precisionLabels, precisionColors, azulEscuro);
  precisionSelector.selectedIndex = 0;
  
  // Build the direction pad
  botao_direcional(250, 300, 150, 80);
}

// -----------------------------------------------------------------------------
// The main draw function for 'PontosColeta'
// -----------------------------------------------------------------------------
void desenhaTelaPontosColeta() {
  background(branco); 
  
  // 'Voltar' button (top-left). This uses a global function from Globals
  desenhaBotaoVoltar(width - 30, 25, 40);
  
  // 1) Draw the precision selector
  precisionSelector.draw();
  
  // 2) Coordinates text
  fill(azulEscuro);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("X = " + coordenadas[0] + "  Y = " + coordenadas[1] + "  Z = " + coordenadas[2], 250, 123);
  
  // 3) Draw the direction pad shape
  shape(dirPad);
  
  // 3.1) Draw the directional labels (+-X, +-Y)
  fill(branco);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("+X", 362, 300);
  text("-X", 135, 300);
  text("+Y", 247, 186);
  text("-Y", 247, 414);
  
  // 4) Center circle with placeholder icon
  fill(azulEscuro);
  ellipse(250, 300, 100, 100);
  fill(branco);
  image(homeXY, 132, 235);
  
  // 5) Side panel for 'Pontos adicionados'
  fill(brancoBege);
  rect(width - 340, 70, 300, height - 280, 8);
  
  fill(azulEscuro);
  textSize(18);
  textAlign(LEFT, CENTER);
  text("Pontos de Dispensa", width - 310, 100);
  
  // 6) List of points
  drawPointsList();
  
  // Always show the scroll buttons
  scrollUpButton.draw();
  scrollDownButton.draw();
  
  // 7) Action buttons: add, edit, delete
  addButton.draw();
  editButton.draw();
  deleteButton.draw();
  
  // 8) Draw Lock XY / Lock Z buttons
  lockXYButton.draw();
  lockZButton.draw();
}

// -----------------------------------------------------------------------------
// Draw the list of points in side panel
// -----------------------------------------------------------------------------
void drawPointsList() {
  int startY     = 150;
  int itemHeight = 40;
  
  fill(azulEscuro);
  textSize(12);
  textAlign(LEFT, CENTER);
  
  int endIndex = min(listaPontos.size(), scrollOffset + maxVisiblePoints);
  
  hasItemsAbove = scrollOffset > 0;
  hasItemsBelow = endIndex < listaPontos.size();
  
  if (hasItemsAbove) {
    fill(azulEscuro);
    textSize(20);
    textAlign(CENTER, CENTER);
    text("^", width - 170, 130);
    textSize(12);
  }
  if (hasItemsBelow) {
    fill(azulEscuro);
    textSize(15);
    textAlign(CENTER, CENTER);
    text("v", width - 170, startY + maxVisiblePoints * itemHeight);
    textSize(12);
  }
  
  for (int i = scrollOffset; i < endIndex; i++) {
    PontoColeta ponto = listaPontos.get(i);
    int y = startY + (i - scrollOffset)*itemHeight;
    
    if (ponto.selected) {
      fill(cinzaClaro);
      rect(width - 310, y - 15, 250, 30, 5);
    }
    
    // Checkbox
    fill(branco);
    stroke(azulEscuro);
    rect(width - 300, y - 10, 20, 20, 3);
    if (ponto.selected) {
      fill(azulEscuro);
      rect(width - 295, y - 5, 10, 10, 2);
    }
    
    // Text label and coordinates
    fill(azulEscuro);
    noStroke();
    textAlign(LEFT, CENTER);
    text(ponto.toString(), width - 270, y);
    text("( " + ponto.coords[0] + ", " + ponto.coords[1] + ", " + ponto.coords[2] + " )", 
         width - 180, y);
  }
}

// -----------------------------------------------------------------------------
// MOUSE PRESSED logic (called from global mousePressed() if telaPontosColeta==true)
// -----------------------------------------------------------------------------
void mousePressedTelaMovimentacaoManual() {
  // 0) Check if clicked on back button
  if (dist(mouseX, mouseY, width - 50, 50) < 20) {
    telaPontosColeta = false;
    telaPipetagem = true;
    return;
  }
  
  // Check precision selector
  precisionSelector.mousePressed();
  
  // 1) Back button (Voltar)
  if (dist(mouseX, mouseY, width - 30, 25) < 20) {
    telaPontosColeta = false;
    telaPipetagem    = true;
    return;
  }
  
  // 2) Direction pad segments
  for (int i = 0; i < 4; i++) {
    if (segments[i].contains(mouseX, mouseY)) {
      segments[i].setFill(cinzaMedio);
      return;
    }
  }
  
  // 3) Center circle
  if (dist(mouseX, mouseY, 180, 300) < 30) {
    return;
  }
  
  // 4) Lock buttons: if a lock button is touched, mark it as pressed.
  if (lockXYButton.isMouseOver()) {
    lockXYButton.isPressed = true;
    return;
  }
  if (lockZButton.isMouseOver()) {
    lockZButton.isPressed = true;
    return;
  }
  
  // 5) Scroll buttons
  if (scrollUpButton.isMouseOver()) {
    scrollUpButton.isPressed = true;
    return;
  }
  if (scrollDownButton.isMouseOver()) {
    scrollDownButton.isPressed = true;
    return;
  }
  
  // 6) Points list checkboxes
  int startY   = 150;
  int itemH    = 40;
  int endIndex = min(listaPontos.size(), scrollOffset + maxVisiblePoints);
  for (int i = scrollOffset; i < endIndex; i++) {
    int y = startY + (i - scrollOffset)*itemH;
    if (mouseX >= width - 300 && mouseX <= width - 280 &&
        mouseY >= y - 10 && mouseY <= y + 10) {
      listaPontos.get(i).selected = !listaPontos.get(i).selected;
      return;
    }
  }
  
  // 7) Action buttons: add, edit, delete
  if (addButton.isMouseOver()) {
    addButton.isPressed = true;
    return;
  }
  if (editButton.isMouseOver()) {
    editButton.isPressed = true;
    return;
  }
  if (deleteButton.isMouseOver()) {
    deleteButton.isPressed = true;
    return;
  }
}

// -----------------------------------------------------------------------------
// MOUSE RELEASED logic (called from global mouseReleased() if telaPontosColeta==true)
// -----------------------------------------------------------------------------
void mouseReleasedTelaMovimentacaoManual() {
  // 0) Handle precision selector
  int prevSelectedIndex = precisionSelector.selectedIndex;
  precisionSelector.mouseReleased();
  
  if (prevSelectedIndex != precisionSelector.selectedIndex) {
    movSpeed = Integer.parseInt(precisionLabels[precisionSelector.selectedIndex].replaceAll("[^0-9]", ""));
  }
  
  // 1) Directional pad: reset color and move if not locked
  for (int i = 0; i < 4; i++) {
    segments[i].setFill(azulEscuro);
    if (segments[i].contains(mouseX, mouseY) && !xyLocked) {
      switch (i) {
        case 0: // Up
          coordenadas[1] -= movSpeed;
          break;
        case 1: // Right
          coordenadas[0] -= movSpeed;
          break;
        case 2: // Down
          coordenadas[1] += movSpeed;
          break;
        case 3: // Left
          coordenadas[0] += movSpeed;
          break;
      }
    }
  }
  
  // 2) Lock XY / Z buttons: Toggle lock state if button was pressed.
  if (lockXYButton.isPressed) {
    xyLocked = !xyLocked;
    lockXYButton.isSelected = xyLocked;
    lockXYButton.isPressed = false;
  }
  if (lockZButton.isPressed) {
    zLocked = !zLocked;
    lockZButton.isSelected = zLocked;
    lockZButton.isPressed = false;
  }
  
  // 3) Scroll up/down
  if (scrollUpButton.isPressed) {
    if (scrollUpButton.isMouseOver() && scrollOffset > 0) {
      scrollOffset--;
    }
    scrollUpButton.isPressed = false;
  }
  if (scrollDownButton.isPressed) {
    if (scrollDownButton.isMouseOver() && 
        scrollOffset < listaPontos.size() - maxVisiblePoints) {
      scrollOffset++;
    }
    scrollDownButton.isPressed = false;
  }
  
  // 4) Action buttons: add, edit, delete
  if (addButton.isPressed) {
    if (addButton.isMouseOver()) {
      addNewPoint();
    }
    addButton.isPressed = false;
  }
  if (editButton.isPressed) {
    if (editButton.isMouseOver()) {
      editSelectedPoints();
    }
    editButton.isPressed = false;
  }
  if (deleteButton.isPressed) {
    if (deleteButton.isMouseOver()) {
      deleteSelectedPoints();
    }
    deleteButton.isPressed = false;
  }
}

// -----------------------------------------------------------------------------
// Adding, deleting, and editing points
// -----------------------------------------------------------------------------
void addNewPoint() {
  int nextPointNum = listaPontos.size() + 1;
  String pointName = "Ponto " + (nextPointNum < 10 ? "0" + nextPointNum : nextPointNum);
  PontoColeta pc = new PontoColeta(pointName, 3, coordenadas[0], coordenadas[1], coordenadas[2]);
  listaPontos.add(pc);
}

void deleteSelectedPoints() {
  for (int i = listaPontos.size() - 1; i >= 0; i--) {
    if (listaPontos.get(i).selected) {
      listaPontos.remove(i);
    }
  }
  
  for (int i = 0; i < listaPontos.size(); i++) {
    String pointName = "Ponto " + ((i+1 < 10) ? ("0" + (i+1)) : (i+1));
    listaPontos.get(i).nome = pointName;
  }
  
  if (scrollOffset > 0 && listaPontos.size() <= maxVisiblePoints) {
    scrollOffset = 0;
  }
  else if (scrollOffset > 0 && scrollOffset >= listaPontos.size() - maxVisiblePoints) {
    scrollOffset = max(0, listaPontos.size() - maxVisiblePoints);
  }
}

void editSelectedPoints() {
  ArrayList<String> selectedPoints = new ArrayList<String>();
  for (PontoColeta p : listaPontos) {
    if (p.selected) {
      selectedPoints.add(p.toString());
    }
  }
  println("Editing points: " + selectedPoints);
  // Optionally switch screens:
  // telaPontosColeta = false;
  // telaEditarPontos = true;
}
