// Variables for "Coleta"

Button addButtonColeta, deleteButtonColeta, editButtonColeta, scrollDownButtonColeta, scrollUpButtonColeta;


// -----------------------------------------------------------------------------
// Setup function for 'TelaPontosColeta' - Initializes only screen-specific UI
// Called once from the main setup() in Globals.pde
// -----------------------------------------------------------------------------
void setupTelaPontosColeta() {

  addButtonColeta    = new Button(true, width - 327, height - 180, 80, 80, addicon,    azulEscuro); // (square?, x, y, w, h, icon, bgColor)
  editButtonColeta   = new Button(true, width - 227, height - 180, 80, 80, editpen,    azulEscuro); // (square?, x, y, w, h, icon, bgColor)
  deleteButtonColeta = new Button(true, width - 127, height - 180, 80, 80, trash,      azulEscuro); // (square?, x, y, w, h, icon, bgColor)

  scrollUpButtonColeta   = new Button(true, width - 100, height/2 - 150, 40, 40, "↑", azulEscuro, branco); // Adjusted X position slightly
  scrollDownButtonColeta = new Button(true, width - 100, height/2 + 10, 40, 40, "↓", azulEscuro, branco); // Adjusted X position slightly

}

// -----------------------------------------------------------------------------
//               Main draw function for 'TelaPontosColeta'
// -----------------------------------------------------------------------------
void desenhaTelaPontosColeta() {
  background(branco); // Clear background

  // 1) Draw the precision selector (Shared)
  precisionSelector.draw();

  // 2) Coordinates text (Shared - shows current machine position)
  fill(azulEscuro);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("X = " + coordenadas[0] + "  Y = " + coordenadas[1] + "  Z = " + coordenadas[2], 250, 123);

  // 3) Draw the direction pad shape (Shared)
  shape(dirPad);
  
  // 3.1) Draw the directional labels (+-X, +-Y) (Shared)
  fill(branco);
  textSize(20);
  textAlign(CENTER, CENTER);
  text("+Y", 362, 300); // Original label position
  text("-Y", 135, 300); // Original label position
  text("-X", 247, 186); // Original label position
  text("+X", 247, 414); // Original label position

  // 4) Draw the XY home button (Shared)
  xy_home.draw();

  // 5) Draw Lock XY / Lock Z buttons (Shared)
  lockXYButton.draw();
  lockZButton.draw();

  // 6) Draw backButton (Shared)
  backButton.draw();

  // 7) Draw Z control buttons (Shared)
  z_plus.draw();
  z_minus.draw();
  z_home.draw();

  // 8) Side panel background for 'Pontos adicionados'
  fill(brancoBege);
  rect(width - 340, 70, 300, height - 280, 8);

  fill(azulEscuro);
  textSize(18);
  textAlign(LEFT, CENTER);
  text("Pontos para Coleta", width - 310, 100);

  // 6) List of collection points
  drawPointsList(listaPontosColeta, scrollOffset, true); // Use the specific drawing function

  // Draw scroll buttons for the Coleta list
  scrollUpButtonColeta.draw();
  scrollDownButtonColeta.draw();

  // 7) Action buttons: add, edit, delete for Coleta points
  addButtonColeta.draw();
  editButtonColeta.draw();
  deleteButtonColeta.draw();
}

// -----------------------------------------------------------------------------
//                             MOUSE PRESSED
// -----------------------------------------------------------------------------
void mousePressedTelaPontosColeta() {
  // --- Check SHARED UI Elements First ---
  // Order matters: check specific small buttons before larger areas like dirPad

  // 1) Back Button
  if (backButton != null && backButton.isMouseOver()) {
    backButton.isPressed = true;
    return; // Handled
  }

  // 2) Lock Buttons
  if (lockXYButton.isMouseOver()) {
    lockXYButton.isPressed = true;
    return; // Handled
  }
  if (lockZButton.isMouseOver()) {
    lockZButton.isPressed = true;
    return; // Handled
  }

  // 3) Z Axis Buttons
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

   // 4) XY Home Button (Center of DirPad)
  if (xy_home.isMouseOver()){
     xy_home.isPressed = true;
     return;
  }

  // 5) Direction pad segments

  // Check precision selector
  precisionSelector.mousePressed();
  
  for (int i = 0; i < 4; i++) {
    if (segments[i] != null && segments[i].contains(mouseX, mouseY)) { // Added null check
      segments[i].setFill(cinzaMedio);
      return;
    }

  }
  
  // Center circle (original logic based on distance)
  if (dist(mouseX, mouseY, 250, 300) < 50) { // Using radius from botao_direcional inner circle (80/2=40, slightly larger area 50)
     if (xy_home.isMouseOver()) { // Check if over the actual button bounds
         xy_home.isPressed = true;
     }
     return; // Return as in original logic if center area clicked
  }

  // 6) Scroll Buttons (Coleta List)
  if (scrollUpButtonColeta.isMouseOver()) {
    scrollUpButtonColeta.isPressed = true;
    return;
  }
  if (scrollDownButtonColeta.isMouseOver()) {
    scrollDownButtonColeta.isPressed = true;
    return;
  }
  
  // 6) Points list checkboxes
  int startY   = 150;
  int itemH    = 35;
  int endIndex = min(listaPontosColeta.size(), scrollOffset + maxVisiblePoints);
  for (int i = scrollOffset; i < endIndex; i++) {
    int y = startY + (i - scrollOffset)*itemH;
    // Original checkbox click area
    if (mouseX >= width - 320 && mouseX <= width - 300 &&
        mouseY >= y - 10 && mouseY <= y + 10) {
      listaPontosColeta.get(i).selected = !listaPontosColeta.get(i).selected;
      return;
    }
  }

  // 9) Action Buttons (Coleta: Add, Edit, Delete)
  if (addButtonColeta.isMouseOver()) {
    addButtonColeta.isPressed = true;
    pontosColeta++; // Original logic increments here
    return;
  }
  if (editButtonColeta.isMouseOver()) {
    editButtonColeta.isPressed = true;
    return;
  }
  if (deleteButtonColeta.isMouseOver()) {
    deleteButtonColeta.isPressed = true;
    return;
  }

  // If no UI element was pressed, potentially handle background press?
}


// -----------------------------------------------------------------------------
//                             MOUSE RELEASED
// -----------------------------------------------------------------------------
void mouseReleasedTelaPontosColeta() {

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

  // 3) Z Axis Buttons
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

  // 4) Button Home for X & Y axis
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

  // 5) Scroll up/down (Coleta List)
  if (scrollUpButtonColeta.isPressed) {
    if (scrollUpButtonColeta.isMouseOver() && scrollOffset > 0) { // Original condition
      scrollOffset--;
    }
    scrollUpButtonColeta.isPressed = false;
  }
  if (scrollDownButtonColeta.isPressed) {
    if (scrollDownButtonColeta.isMouseOver() &&
        scrollOffset < listaPontosColeta.size() - maxVisiblePoints) { // Original condition
      scrollOffset++;
    }
    scrollDownButtonColeta.isPressed = false;
  }

  // 6) Action buttons: add, edit, delete (Coleta List)
    
    if (addButtonColeta.isPressed){
       addButtonColeta.isPressed = false;
      
      addNewPoint(listaPontosColeta, "Coletas", true, coordenadas, null);
      pontosColeta = listaPontosColeta.size();
    }
    
    if (deleteButtonColeta.isPressed){
       deleteButtonColeta.isPressed = false;
       
       deleteSelectedPoints(listaPontosColeta, scrollOffset, "Coletas");
       pontosColeta = listaPontosColeta.size();
    }
    
    if (editButtonColeta.isPressed){
      editButtonColeta.isPressed = false; 
      
      editSelectedPoints(listaPontosColeta, true, coordenadas, null);
       // troca de tela
       // setupEditarPonto();
       // telaPontosColeta = false;
       // telaEditarPonto = true;
       
    }

  
  // 7) Back Button 
  if (backButton.isPressed && backButton != null){
   backButton.isPressed = false;
   
   telaPontosColeta = false;
   telaPipetagem = true;
  }
}
