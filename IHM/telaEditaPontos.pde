// ----------------------------
// telaEditaPontos.pde
// ----------------------------

// 1) Botões
Button buttonSalvarEdit, buttonCancelarEdit, scrollUpButtonEdit, scrollDownButtonEdit, scrollLeftButtonEdit, scrollRightButtonEdit;

// 2) Estado de edição
ArrayList<Ponto> listaEditavel = new ArrayList<Ponto>();
int editSelectedIndex = -1;
boolean focusNome = false, focusVolume = false;
String  inputNomeEdit   = "", inputVolumeEdit = "";
ArrayList<Ponto> listaAssociadas = new ArrayList<Ponto>();
int assocIndex = 0;
int  editScrollOffset = 0;
final int maxVisibleEdit = 10;

// ---------------------------------
// Captura de teclado 
// ---------------------------------
void keyTyped() {
  if (!telaEditaPontos) return;
  if (focusNome) {
    if (key == BACKSPACE && inputNomeEdit.length() > 0)
      inputNomeEdit = inputNomeEdit.substring(0, inputNomeEdit.length()-1);
    else if (key >= ' ' && key <= '~')
      inputNomeEdit += key;
  } else if (focusVolume) {
    if (key == BACKSPACE && inputVolumeEdit.length() > 0)
      inputVolumeEdit = inputVolumeEdit.substring(0, inputVolumeEdit.length()-1);
    else if (key >= '0' && key <= '9')
      inputVolumeEdit += key;
  }
}


// ------------------------------------------------------------------
// Setup da tela Edita Pontos dependendo se esta editando coleta ou dispensa
// ------------------------------------------------------------------
void setupTelaEditaPontos() {
  // Copia seleção que veio da tela anterior
  listaEditavel.clear();
  if (edicaoColetaEdit) {
    for (Ponto p : listaPontosColeta)
      if (p.selected) listaEditavel.add(p);
  } else {
    for (Ponto p : listaPontosDispensa)
      if (p.selected) listaEditavel.add(p);
  }
  
  // Se for edição de Dispensa, já aponta assocIndex para a coleta atualmente
  if (!edicaoColetaEdit && listaEditavel.size() > 0) {
    Ponto d = listaEditavel.get(0);  // só deveria haver 1 ou poucos selecionados
    for (int i = 0; i < listaPontosColeta.size(); i++) {
      if (coordsIguais(listaPontosColeta.get(i).coords, d.coordsColeta)) {
        assocIndex = i;
        break;
      }
    }
  }

  // Definindo variáveis para tornar mais fácil a edicao
  float px = width - 630, py = 80, pw = 40, ph = height - 150;
  float dx = width - 420, dy = 380, dw = 380, dh = 80;

  // Scroll vertical 
  scrollUpButtonEdit    = new Button(true, px, py, pw, 40, "↑", azulEscuro, branco);
  scrollDownButtonEdit  = new Button(true, px, py+ph-70, pw, 40, "↓", azulEscuro, branco);

  // Setas horizontais 
  scrollLeftButtonEdit  = new Button(true, dx+10,     dy+(dh-40)/2, 40, 40, "←", azulEscuro, branco);
  scrollRightButtonEdit = new Button(true, dx+dw-50,  dy+(dh-40)/2, 40, 40, "→", azulEscuro, branco);

  // Botões SALVAR / CANCELAR
  buttonSalvarEdit   = new Button(true, 600, 500, 180, 50, "SALVAR",  azulEscuro, branco);
  buttonCancelarEdit = new Button(true, 800, 500, 180, 50, "CANCELAR", cinzaClaro, branco);

  // Estado inicial da tela de editar os pontos
  editSelectedIndex = -1;
  inputNomeEdit     = "";
  inputVolumeEdit   = "";
  assocIndex        = 0;
  editScrollOffset  = 0;
  listaAssociadas.clear();
}

// ---------------------------------
// Desenha a tela de edição
// ---------------------------------
void desenhaTelaEditaPontos() {
  background(branco);
  if (logo != null) image(logo, width - logo.width - 900, -40);

  // Título e campos de input
  textSize(fontTitulo-15); fill(0); textAlign(CENTER);
  text("Editar ponto", 800, 100);

  textSize(fontSubtitulo); fill(cinzaEscuro); textAlign(LEFT);
  text("Nome do Ponto:", 600, 160);
  text("Volume (mL):",    600, 260);
  if (edicaoColetaEdit) text("Pontos de dispensa associados:", 600, 360);
  else                  text("Ponto de coleta correspondente:", 600, 360);

  // Caixa de texto
  fill(branco); stroke(azulEscuro);
  rect(600, 170, 400, 35, 10);
  rect(600, 270, 400, 35, 10);
  noStroke();
  fill(azulEscuro); textSize(16); textAlign(LEFT, CENTER);
  text(inputNomeEdit,   610, 170+35/2);
  text(inputVolumeEdit, 610, 270+35/2);

  // — Painel lateral —
  float px=width-950, py=70, pw=380, ph=height-150;
  fill(brancoBege);
  rect(px, py, pw, ph, 8);
  fill(azulEscuro); textSize(20); textAlign(LEFT, CENTER);
  text("Pontos Selecionados:", px+20, py+30);

  // Scroll vertical
  scrollUpButtonEdit.draw();
  scrollDownButtonEdit.draw();

  // Lista de pontos
  textSize(16);
  float itemY=py+70, itemH=35;
  int start = editScrollOffset;
  int end   = min(listaEditavel.size(), start + maxVisibleEdit);
  for (int i=start; i<end; i++) {
    Ponto p = listaEditavel.get(i);
    float y = itemY + (i-start)*itemH;

    // check button
    stroke(azulEscuro); noFill();
    rect(px+10, y-10, 20, 20, 3);
    noStroke();
    if (i == editSelectedIndex) {
      fill(azulEscuro);
      rect(px+12, y-8, 16, 16, 2);
    }

    // Pontos
    fill(azulEscuro); textAlign(LEFT, CENTER);
    text(p.nome, px+40, y);
  }
  if (listaEditavel.isEmpty()) {
    fill(cinzaClaro); textSize(14);
    text("Nenhum selecionado", px+80, py+70);
  }

  // Painel inferior (Associações)
  float dx=width-420, dy=380, dw=380, dh=80;
  fill(brancoBege); rect(dx, dy, dw, dh, 8);

  // monta listaAssociadas
  listaAssociadas.clear();
  if (edicaoColetaEdit && editSelectedIndex>=0) {
    Ponto sel = listaEditavel.get(editSelectedIndex);
    for (Ponto d : listaPontosDispensa)
      if (coordsIguais(d.coordsColeta, sel.coords)) listaAssociadas.add(d);
  } else if (!edicaoColetaEdit) {
    listaAssociadas.addAll(listaPontosColeta);
  }

  textSize(14); textAlign(LEFT, CENTER);
  if (listaAssociadas.isEmpty()) {
    fill(cinzaClaro);
    if (edicaoColetaEdit) text("Nenhuma dispensa associada", dx+85, dy+dh/2);
    else                  text("Nenhuma coleta disponível",   dx+85, dy+dh/2);
  } 
  else {
    assocIndex = constrain(assocIndex, 0, listaAssociadas.size()-1);
    fill(azulEscuro);
    rect(((2*dx+dw)/2)-((textWidth(listaAssociadas.get(assocIndex).nome)+ 50)/2), dy + 5, textWidth(listaAssociadas.get(assocIndex).nome)+ 50, dh - 10, 10);
    
    fill(branco);
    text(listaAssociadas.get(assocIndex).nome, ((2*dx+dw)/2)-((textWidth(listaAssociadas.get(assocIndex).nome))/2), dy+dh/2);
  }

  // setas horizontais
  scrollLeftButtonEdit.draw();
  scrollRightButtonEdit.draw();

  // botões SALVAR/CANCELAR/VOLTAR
  buttonSalvarEdit.draw();
  buttonCancelarEdit.draw();
  backButton.draw();
}

// ---------------------------------
// mousePressed na tela de edição
// ---------------------------------
void mousePressedTelaEditaPontos() {
  // re-declara variaveis que serao utilizadas
  float px=width-950, py=70;
  float itemY=py+70, itemH=35;

  // Foco nos campos de texto
  if (mouseX >= 600 && mouseX <= 1000 && mouseY >= 170 && mouseY <= 205) {
    focusNome = true;
    focusVolume = false;
    return;
  }
  if (mouseX >= 600 && mouseX <= 1000 && mouseY >= 270 && mouseY <= 305) {
    focusNome = false;
    focusVolume = true;
    return;
  }


  // scroll vertical
  if (scrollUpButtonEdit.isMouseOver()) {
    scrollUpButtonEdit.isPressed=true; return;
  }
  if (scrollDownButtonEdit.isMouseOver()) {
    scrollDownButtonEdit.isPressed=true; return;
  }

  // seleção lateral
  int start=editScrollOffset, end=min(listaEditavel.size(), start+maxVisibleEdit);
  for (int i=start; i<end; i++) {
    float y = itemY + (i-start)*itemH;
    // clique no quadrado
    if (mouseX>=px+10 && mouseX<=px+30 &&
        mouseY>=y-10 && mouseY<=y+10) {
      editSelectedIndex=i;
      Ponto s = listaEditavel.get(i);
      inputNomeEdit   = s.nome;
      inputVolumeEdit = str(s.volume);
      assocIndex      = 0;
      return;
    }
  }

  // scroll horizontal
  if (scrollLeftButtonEdit.isMouseOver()) {
    scrollLeftButtonEdit.isPressed=true; return;
  }
  if (scrollRightButtonEdit.isMouseOver()) {
    scrollRightButtonEdit.isPressed=true; return;
  }

  // SALVAR
  if (buttonSalvarEdit.isMouseOver() && editSelectedIndex>=0) {
    Ponto s = listaEditavel.get(editSelectedIndex);
    s.nome   = inputNomeEdit;
    s.volume = int(inputVolumeEdit);
    if (!edicaoColetaEdit && !listaAssociadas.isEmpty()) {
      Ponto c = listaAssociadas.get(assocIndex);
      s.coordsColeta = c.coords.clone();
    }
    // limpa flags originais **apenas agora**
    for (Ponto p : listaPontosColeta)    p.selected = false;
    for (Ponto p : listaPontosDispensa) p.selected = false;
    // Limpa somente a seleção local e campos, não troca de tela
    editSelectedIndex = -1;
    inputNomeEdit     = "";
    inputVolumeEdit   = "";
    assocIndex        = 0;
    focusNome         = false;
    focusVolume       = false;
    
    return;
  }

  // CANCELAR
  if (buttonCancelarEdit.isMouseOver()) {
    // Limpa somente a seleção local e campos, não troca de tela
    editSelectedIndex = -1;
    inputNomeEdit     = "";
    inputVolumeEdit   = "";
    assocIndex        = 0;
    focusNome         = false;
    focusVolume       = false;
    return;
  }


  // VOLTAR
  if (backButton.isMouseOver()) {
    telaEditaPontos = false;
    if (edicaoColetaEdit) telaPontosColeta = true;
    else                  telaPontosDispensa = true;
    return;
  }
}

// ---------------------------------
// mouseReleased na tela de edição
// ---------------------------------
void mouseReleasedTelaEditaPontos() {
  if (scrollUpButtonEdit.isPressed) {
    if (editScrollOffset>0) editScrollOffset--;
    scrollUpButtonEdit.isPressed=false;
  }
  if (scrollDownButtonEdit.isPressed) {
    if (editScrollOffset<listaEditavel.size()-maxVisibleEdit)
      editScrollOffset++;
    scrollDownButtonEdit.isPressed=false;
  }
  if (scrollLeftButtonEdit.isPressed) {
    assocIndex--;
    scrollLeftButtonEdit.isPressed=false;
  }
  if (scrollRightButtonEdit.isPressed) {
    assocIndex++;
    scrollRightButtonEdit.isPressed=false;
  }
}
