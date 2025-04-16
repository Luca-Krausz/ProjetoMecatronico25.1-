// Original global variables

// UI elements
Button addButtonDispensa, deleteButtonDispensa, editButtonDispensa, scrollUpButtonDispensa, scrollDownButtonDispensa;

// -----------------------------------------------------------------------------
// Build the directional pad (dirPad + segments are from Globals.pde).
// -----------------------------------------------------------------------------
// Original function - No changes
void botao_direcional(float x, float y, float raioMaior, float raioMenor) {
  dirPad = createShape(GROUP);

  for (int i = 0; i < 4; i++) {
    segments[i] = createShape();
    segments[i].beginShape();
    segments[i].fill(azulEscuro);
    segments[i].stroke(255);
    segments[i].strokeWeight(10); // Original stroke weight

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
// The setup function for 'PontosDispensa'
// -----------------------------------------------------------------------------
// Original function - No changes
void setupTelaPontosDispensa() {
  // Create UI elements (positions approximate)
  addButtonDispensa    = new Button(true, width - 327, height - 180, 80, 80, addicon,  azulEscuro); // (square?, x, y, w, h, icon, bgColor)
  editButtonDispensa   = new Button(true, width - 227, height - 180, 80, 80, editpen,  azulEscuro); // (square?, x, y, w, h, icon, bgColor)
  deleteButtonDispensa = new Button(true, width -  127, height - 180, 80, 80, trash,  azulEscuro); // (square?, x, y, w, h, icon, bgColor)

  // Scroll Buttons
  scrollUpButtonDispensa   = new Button(true, width - 100, height/2 - 150, 40, 40, "↑", azulEscuro, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  scrollDownButtonDispensa = new Button(true, width - 100, height/2 + 10, 40, 40, "↓", azulEscuro, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  

}

// -----------------------------------------------------------------------------
// The main draw function for 'PontosDispensa'
// -----------------------------------------------------------------------------

void desenhaTelaPontosDispensa() {
  background(branco);

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
  text("+Y", 362, 300); // Original label position
  text("-Y", 135, 300); // Original label position
  text("-X", 247, 186); // Original label position
  text("+X", 247, 414); // Original label position

  // 4) Draw the button home for axis x & y
  xy_home.draw();

  // 5) Side panel for 'Pontos adicionados'
  fill(brancoBege);
  rect(width - 340, 70, 300, height - 280, 8);

  fill(azulEscuro);
  textSize(18);
  textAlign(LEFT, CENTER);
  text("Pontos para Dispensa", width - 310, 100);

  // 6) List of points
  drawPointsList(listaPontosDispensa, scrollOffset, false);

  // Always show the scroll buttons
  scrollUpButtonDispensa.draw();
  scrollDownButtonDispensa.draw();

  // 7) Action buttons: add, edit, delete
  addButtonDispensa.draw();
  editButtonDispensa.draw();
  deleteButtonDispensa.draw();

  // 8) Draw Lock XY / Lock Z buttons
  lockXYButton.draw();
  lockZButton.draw();

  // 9) Draw backButton
  backButton.draw(); 

  // 10) Draw Z buttons
  z_plus.draw();
  z_minus.draw();
  z_home.draw();
  
  // 11) Draw the side panel 
    drawPointsList(listaPontosDispensa, scrollOffset, false);

}


// -----------------------------------------------------------------------------
//                                MOUSE PRESSED
// -----------------------------------------------------------------------------

void mousePressedTelaMovimentacaoManual() {
  // 1) Check if clicked on back button
  if (backButton != null && backButton.isMouseOver()) { // Added null check for safety
    backButton.isPressed = true;
    return;
  }

  // Check precision selector
  precisionSelector.mousePressed();

  // 2) Direction pad segments
  for (int i = 0; i < 4; i++) {
    if (segments[i] != null && segments[i].contains(mouseX, mouseY)) { // Added null check
      segments[i].setFill(cinzaMedio);
      return;
    }
  }

  // 3) Center circle (original logic based on distance)
  if (dist(mouseX, mouseY, 250, 300) < 50) { // Using radius from botao_direcional inner circle (80/2=40, slightly larger area 50)
     if (xy_home.isMouseOver()) { // Check if over the actual button bounds
         xy_home.isPressed = true;
     }
     return; // Return as in original logic if center area clicked
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
  if (scrollUpButtonDispensa.isMouseOver()) {
    scrollUpButtonDispensa.isPressed = true;
    return;
  }
  if (scrollDownButtonDispensa.isMouseOver()) {
    scrollDownButtonDispensa.isPressed = true;
    return;
  }

  // 6) Points list checkboxes
  int startY   = 150;
  int itemH    = 40;
  int endIndex = min(listaPontosDispensa.size(), scrollOffset + maxVisiblePoints);
  for (int i = scrollOffset; i < endIndex; i++) {
    int y = startY + (i - scrollOffset)*itemH;
    // Original checkbox click area
    if (mouseX >= width - 320 && mouseX <= width - 300 &&
        mouseY >= y - 10 && mouseY <= y + 10) {
      listaPontosDispensa.get(i).selected = !listaPontosDispensa.get(i).selected;
      return;
    }
  }

  // 7) Action buttons: add, edit, delete
  if (addButtonDispensa.isMouseOver()) {
    addButtonDispensa.isPressed = true;
    pontosDispensa++; // Original logic increments here
    return;
  }
  if (editButtonDispensa.isMouseOver()) {
    editButtonDispensa.isPressed = true;
    return;
  }
  if (deleteButtonDispensa.isMouseOver()) {
    deleteButtonDispensa.isPressed = true;
    return;
  }

  // 8) Button for the Z axis
  if (z_plus.isMouseOver()) {
    z_plus.isPressed = true;
   return;
  }
  if (z_minus.isMouseOver()){
     z_minus.isPressed = true;
    return;
  }
  if (z_home.isMouseOver()){
    z_home.isPressed = true;
   return;
  }

  // 9) Button home for X & Y axis
  if (xy_home.isMouseOver()){
   xy_home.isPressed = true;
   return;
  }

}


// -----------------------------------------------------------------------------
//                                MOUSE RELEASED
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
    if (segments[i] != null) { 
        segments[i].setFill(azulEscuro); 
        if (segments[i].contains(mouseX, mouseY) && !xyLocked) { 
          switch (i) {
            case 0: // Up
              command = "+X" + String.valueOf(movSpeed + "\r");
              coordenadas[0] += movSpeed;
              coordenadas[0] = constrain(coordenadas[0], minX, maxX); 
              if (porta != null) {
                porta.write(command);
              }
              else {
                println("porta inválida"); 
              }
              break;
            case 1: // Right 
              command = "+Y" + String.valueOf(movSpeed) + "\r";
              coordenadas[1] -= movSpeed;
              coordenadas[1] = constrain(coordenadas[1], minY, maxY); 
              if (porta != null) {
                porta.write(command);
              }
              else {
                println("porta inválida"); 
              }
              break;
            case 2: // Down
              command = "-X" + String.valueOf(movSpeed) + "\r";
              coordenadas[0] -= movSpeed;
              coordenadas[0] = constrain(coordenadas[0], minX, maxX);
              if (porta != null) {
                porta.write(command);
              }
              else {
                println("porta inválida"); 
              }
              break;
            case 3: // Left
              command = "-Y" + String.valueOf(movSpeed) + "\r";
              coordenadas[1] += movSpeed;
              coordenadas[1] = constrain(coordenadas[1], minY, maxY);
              if (porta != null) {
                porta.write(command);
              }
              else {
                println("porta inválida"); 
              }
              break;
          }
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
  if (scrollUpButtonDispensa.isPressed) {
    if (scrollUpButtonDispensa.isMouseOver() && scrollOffset > 0) { // Original condition
      scrollOffset--;
    }
    scrollUpButtonDispensa.isPressed = false;
  }
  if (scrollDownButtonDispensa.isPressed) {
    if (scrollDownButtonDispensa.isMouseOver() &&
        scrollOffset < listaPontosDispensa.size() - maxVisiblePoints) { // Original condition
      scrollOffset++;
    }
    scrollDownButtonDispensa.isPressed = false;
  }

  // 4) Action buttons: add, edit, delete
  if (addButtonDispensa.isPressed) {
    addButtonDispensa.isPressed = false;
      
    addNewPoint(listaPontosDispensa, "Dispensa", false, coordenadas, coordenadasColeta); 
  }
  if (editButtonDispensa.isPressed) {
    editButtonDispensa.isPressed = false;
    
    editSelectedPoints(listaPontosDispensa, false, coordenadas, coordenadasColeta); 
  }
  if (deleteButtonDispensa.isPressed) {
    deleteButtonDispensa.isPressed = false;
    
    deleteSelectedPoints(listaPontosDispensa, scrollOffset, "Dispensa");   
  }

  // 5) Back Button
  if (backButton != null && backButton.isPressed){ 
    backButton.isPressed = false; 

       telaPontosDispensa = false;
       telaPipetagem = true;
    // }
  }

  // 6) Button for Z axis
  if (z_plus.isPressed){
    z_plus.isPressed = false; // Reset state first

    if (!zLocked){
      command = "+Z" + String.valueOf(movSpeed) + "\r";
      if (porta != null) {
        porta.write(command);
     }
     else {
        println("porta inválida"); 
     }
      coordenadas[2] += movSpeed;
      coordenadas[2] = constrain(coordenadas[2], minZ, maxZ); // Set the limits for the Z axis
    }
  }
  if (z_minus.isPressed) {
   z_minus.isPressed = false; // Reset state first

   if (!zLocked){
     command = "-Z" + String.valueOf(movSpeed) + "\r";
     if (porta != null) {
        porta.write(command);
     }
     else {
        println("porta inválida"); 
     }
     coordenadas[2] -= movSpeed;
     coordenadas[2] = constrain(coordenadas[2], minZ, maxZ);
     }
  }
  if (z_home.isPressed){
   z_home.isPressed = false; // Reset state first
   // Original logic doesn't check isMouseOver on release
   if (!zLocked){
     command = "ZH\r";
     if (porta != null) {
        porta.write(command);
     }
     else {
        println("porta inválida"); 
     }
     coordenadas[2] = 0;
     //coordenadas[2] = constrain(coordenadas[2], minZ, maxZ); (Original comment)
   }
  }

  // 7) Button Home for X & Y axis
  if (xy_home.isPressed){
   xy_home.isPressed = false; // Reset state first
   // Original logic doesn't check isMouseOver on release
   if (!xyLocked){
     command = "XYH\r";
     if (porta != null) {
        porta.write(command);
     }
     else {
        println("porta inválida"); 
     }
     coordenadas[0] = 0;
     coordenadas[1] = 0;
   }
  }

}


// -----------------------------------------------------------------------------
// Adding, deleting, and editing points
// -----------------------------------------------------------------------------

    // addNewPoint(listaPontosDispensa, "Dispensa", false, coordenadas, coordenadasColeta);      ArrayList<Ponto> list, String baseName, boolean isColetaScreen, int[] currentCoords, int[] associatedCoordsColeta
    // deleteSelectedPoints(listaPontosDispensa, scrollOffset, "Dispensa");                      ArrayList<Ponto> list, int scrollOffset, String baseName
    // editSelectedPoints(listaPontosDispensa, false, coordenadas, coordenadasColeta);            ArrayList<Ponto> list, boolean isColetaScreen, int[] currentCoords, int[] associatedCoordsColeta


// -----------------------------------------------------------------------------
// Generate the final list of lists: [[x1,y1,z1,qt1,x_coleta,y_coleta,z_coleta], ...]
// -----------------------------------------------------------------------------
ArrayList<int[]> gerarListaFormatoFinal() {
  
  ArrayList<int[]> listaFinal = new ArrayList<int[]>();

  for (Ponto ponto : listaPontosDispensa) {
    int[] item = new int[7]; // Create an array to hold the 7 values

    item[0] = ponto.coords[0];       // x1 (dispense)
    item[1] = ponto.coords[1];       // y1 (dispense)
    item[2] = ponto.coords[2];       // z1 (dispense)
    item[3] = ponto.volume;          // qt1
    item[4] = ponto.coordsColeta[0]; // x_coleta
    item[5] = ponto.coordsColeta[1]; // y_coleta
    item[6] = ponto.coordsColeta[2]; // z_coleta
   
   listaFinal.add(item);
   
  }
  
  
  return listaFinal;
}

String gerarStringFormatoFinal() {
  // Get the data in the structured list format first
  ArrayList<int[]> dataList = gerarListaFormatoFinal();

  // Handle the case where the list is empty
  if (dataList.isEmpty()) {
    return "PIP []"; // Return empty brackets string
  }

  // Use StringBuilder for efficient string building
  StringBuilder sb = new StringBuilder();
  sb.append("PIP ["); // Start with the opening bracket

  // Loop through the list of int arrays
  for (int i = 0; i < dataList.size(); i++) {
    int[] item = dataList.get(i); // Get the current inner array

    // If it's not the first item, add a comma separator
    if (i > 0) {
      sb.append(",");
    }

    // Append the string representation of the inner array
    // java.util.Arrays.toString() creates format like "[1, 2, 3]"
    sb.append(java.util.Arrays.toString(item));
  }

  sb.append("]"); // Add the closing bracket

  return sb.toString(); // Return the final formatted string

}
