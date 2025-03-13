void inicializaListaPontosManual() {
  listaPontosManual.clear();
  listaPontosManual.add("Ponto 01 - 3ml");
  listaPontosManual.add("Ponto 02 - 5ml");
  
  listaPontosManualChecked.clear();
  listaPontosManualChecked.add(true);  // Exemplo: primeiro ponto marcado
  listaPontosManualChecked.add(false); // segundo ponto desmarcado
}

void desenhaTelaMovimentacaoManual() {
  background(branco);

  // Exemplo: botão de voltar (canto sup. direito)
  desenhaBotaoVoltar(width - 50, 50, 40);

  // Texto "Modo atual: Manual"
  fill(cinzaEscuro);
  textSize(17);
  textAlign(LEFT, CENTER);
  text("Modo atual: Manual", 50, height - 30);

  // --------------------------------------------------
  // Botões segmentados (1mm, 10mm, 30mm)
  // --------------------------------------------------
  float segX = 50;
  float segY = 50;
  float segW = 300;
  float segH = 40;
  desenhaSegmentedControl(segX, segY, segW, segH);

  // Exemplo: queremos posicionar o centro do SVG em (300, 250)
  float centerX = 300;
  float centerY = 250;

  // Vamos supor que o SVG tenha ~200x200 px (por exemplo).
  // Ajuste de escala se precisar que fique maior ou menor.
  // Exemplo: queremos um "raio" ~120 px => diâmetro ~240 px.
  // Se o SVG original tiver 200 px de diâmetro, vamos escalar para 1.2
  float alvoRaio = 120;  // "raio" visual
  float svgDiametroOriginal = iconeXY.width; // assumindo movXY é mais ou menos quadrado
  float escala = (alvoRaio * 2) / svgDiametroOriginal; // (240 / 200 = 1.2, por ex.)

  pushMatrix();
    translate(centerX, centerY);
    scale(escala);
    // Centraliza o shape no (0,0)
    shapeMode(CENTER);
    shape(iconeXY, 0, 0);
  popMatrix();

  // --------------------------------------------------
  // Botões Lock XY e Lock Z
  // --------------------------------------------------
  float lockBtnW = 100;
  float lockBtnH = 40;
  float lockBtnX = centerX - lockBtnW - 20;
  float lockBtnY = centerY + 120;
  desenhaBotaoLock(lockBtnX, lockBtnY, lockBtnW, lockBtnH, "Lock XY", xyLocked);

  float lockBtnX2 = centerX + 20;
  desenhaBotaoLock(lockBtnX2, lockBtnY, lockBtnW, lockBtnH, "Lock Z", zLocked);

  // --------------------------------------------------
  // Painel "Pontos adicionados" à direita
  // --------------------------------------------------
  float painelX = 650;
  float painelY = 70;
  float painelW = 300;
  float painelH = 200;

  fill(brancoBege);
  noStroke();
  rect(painelX, painelY, painelW, painelH, 12);

  fill(azulEscuro);
  textSize(18);
  textAlign(LEFT, TOP);
  text("Pontos adicionados", painelX + 20, painelY + 15);

  float listStartY = painelY + 60;
  float lineHeight = 30;
  float spacing    = 8;
  float checkboxSize = 20;

  for (int i = 0; i < listaPontosManual.size(); i++) {
    float itemY = listStartY + i*(lineHeight + spacing);
    desenhaCheckbox(painelX + 20, itemY, checkboxSize, listaPontosManualChecked.get(i));
    fill(azulEscuro);
    textSize(16);
    textAlign(LEFT, CENTER);
    text(listaPontosManual.get(i), painelX + 20 + checkboxSize + 10, itemY + checkboxSize/2);
  }

  // Scrollbar simbólica
  float scrollbarX = painelX + painelW - 15;
  float scrollbarY = painelY + 40;
  float scrollbarH = painelH - 60; 
  fill(cinzaClaro);
  rect(scrollbarX, scrollbarY, 4, scrollbarH, 2);

  // Botões "Adicionar ponto" e "Apagar ponto"
  float btnAddX = painelX + 10;
  float btnAddY = painelY + painelH + 20;
  float btnAddW = 180;
  float btnAddH = 40;
  desenhaBotaoComIcone(btnAddX, btnAddY, btnAddW, btnAddH, "+", "Adicionar ponto de coleta");

  float btnDelX = btnAddX + btnAddW + 10;
  float btnDelY = btnAddY;
  float btnDelW = 100;
  float btnDelH = 40;
  desenhaBotaoComIcone(btnDelX, btnDelY, btnDelW, btnDelH, "🗑", "Apagar");
}
void desenhaSegmentedControl(float x, float y, float w, float h) {
  float segLarg = w / 3;
  float raio = h / 2;

  // Segmento 1: 1mm
  boolean sel1 = (movSpeed == 1);
  if (sel1) {
    stroke(0, 255, 0);
    strokeWeight(3);
    fill(0, 200, 0);
  } else {
    noStroke();
    fill(azulEscuro);
  }
  rect(x, y, segLarg, h, raio, 0, 0, raio);
  fill(branco);
  textSize(16);
  textAlign(CENTER, CENTER);
  text("1mm", x + segLarg/2, y + h/2);

  // Segmento 2: 10mm
  boolean sel2 = (movSpeed == 10);
  if (sel2) {
    stroke(0, 255, 0);
    strokeWeight(3);
    fill(0, 200, 0);
  } else {
    noStroke();
    fill(azulEscuro);
  }
  rect(x + segLarg, y, segLarg, h);
  fill(branco);
  text("10mm", x + segLarg + segLarg/2, y + h/2);

  // Segmento 3: 30mm
  boolean sel3 = (movSpeed == 30);
  if (sel3) {
    stroke(0, 255, 0);
    strokeWeight(3);
    fill(0, 200, 0);
  } else {
    noStroke();
    fill(azulEscuro);
  }
  rect(x + 2*segLarg, y, segLarg, h, 0, raio, raio, 0);
  fill(branco);
  text("30mm", x + 2*segLarg + segLarg/2, y + h/2);
}

void desenhaBotaoMov(float x, float y, float w, float h, String rotulo) {
  fill(azulEscuro);
  noStroke();
  rect(x, y, w, h, 10);
  fill(branco);
  textSize(16);
  textAlign(CENTER, CENTER);
  text(rotulo, x + w/2, y + h/2);
}

void desenhaBotaoLock(float x, float y, float w, float h, String rotulo, boolean locked) {
  fill(locked ? cinzaMedio : azulEscuro);
  noStroke();
  rect(x, y, w, h, 8);
  fill(branco);
  textSize(14);
  textAlign(CENTER, CENTER);
  text(rotulo, x + w/2, y + h/2);
}

void desenhaCheckbox(float x, float y, float size, boolean checked) {
  fill(branco);
  rect(x, y, size, size);

  stroke(cinzaEscuro);
  strokeWeight(1);
  noFill();
  rect(x, y, size, size);
  noStroke();

  if (checked) {
    stroke(azulEscuro);
    strokeWeight(3);
    line(x + 4, y + size/2, x + size/2, y + size - 4);
    line(x + size/2, y + size - 4, x + size - 4, y + 4);
    noStroke();
  }
}

void desenhaBotaoComIcone(float x, float y, float w, float h, String icone, String texto) {
  fill(azulEscuro);
  noStroke();
  rect(x, y, w, h, 8);

  fill(branco);
  textSize(14);
  textAlign(LEFT, CENTER);

  float pad = 10;
  float iconeWidth = textWidth(icone);
  
  text(icone, x + pad, y + h/2);
  text(texto, x + pad + iconeWidth + 8, y + h/2);
}

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

void mousePressedTelaMovimentacaoManual() {
  // 1) Segmented Control (1mm, 10mm, 30mm)
  float segX = 50;
  float segY = 50;
  float segW = 300;
  float segH = 40;
  float segLarg = segW / 3;

  // Segmento 1 (1mm)
  if (mouseX > segX && mouseX < segX + segLarg &&
      mouseY > segY && mouseY < segY + segH) {
    movSpeed = 1;
    println("Movimentação selecionada: 1mm");
    return;
  }
  // Segmento 2 (10mm)
  if (mouseX > segX + segLarg && mouseX < segX + 2*segLarg &&
      mouseY > segY && mouseY < segY + segH) {
    movSpeed = 10;
    println("Movimentação selecionada: 10mm");
    return;
  }
  // Segmento 3 (30mm)
  if (mouseX > segX + 2*segLarg && mouseX < segX + 3*segLarg &&
      mouseY > segY && mouseY < segY + segH) {
    movSpeed = 30;
    println("Movimentação selecionada: 30mm");
    return;
  }

  // 2) Botões de movimentação (X±, Y±, Z±)
  float centerX = 300;
  float centerY = 250;
  float btnSize = 60;
  float gap = 10;

  // Y+
  if (dentroRet(centerX - btnSize/2, centerY - (btnSize + gap) - btnSize, btnSize, btnSize)) {
    println("Y+ clicado!");
    return;
  }
  // Y-
  if (dentroRet(centerX - btnSize/2, centerY + (btnSize + gap), btnSize, btnSize)) {
    println("Y- clicado!");
    return;
  }
  // X-
  if (dentroRet(centerX - (btnSize + gap) - btnSize, centerY - btnSize/2, btnSize, btnSize)) {
    println("X- clicado!");
    return;
  }
  // X+
  if (dentroRet(centerX + (btnSize + gap), centerY - btnSize/2, btnSize, btnSize)) {
    println("X+ clicado!");
    return;
  }
  // Z+
  float zBtnX = centerX + 150;
  float zBtnY = centerY - btnSize - gap;
  if (dentroRet(zBtnX, zBtnY, btnSize, btnSize)) {
    println("Z+ clicado!");
    return;
  }
  // Z-
  if (dentroRet(zBtnX, zBtnY + btnSize + gap, btnSize, btnSize)) {
    println("Z- clicado!");
    return;
  }

  // 3) Ícone SVG (botão central XY)
  // Vamos usar um círculo para a detecção
  float centerBtnRadius = btnSize/2;
  float distXY = dist(mouseX, mouseY, centerX, centerY);
  if (distXY <= centerBtnRadius) {
    println("Ícone XY (SVG) clicado!");
    // Aqui você pode chamar alguma função, etc.
    return;
  }

  // 4) Botões Lock XY / Lock Z
  float lockBtnW = 100;
  float lockBtnH = 40;
  float lockBtnX = centerX - lockBtnW - 20;
  float lockBtnY = centerY + 120;
  if (dentroRet(lockBtnX, lockBtnY, lockBtnW, lockBtnH)) {
    xyLocked = !xyLocked;
    println("Lock XY clicado! xyLocked=" + xyLocked);
    return;
  }
  float lockBtnX2 = centerX + 20;
  if (dentroRet(lockBtnX2, lockBtnY, lockBtnW, lockBtnH)) {
    zLocked = !zLocked;
    println("Lock Z clicado! zLocked=" + zLocked);
    return;
  }

  // 5) Botão de voltar (canto superior direito)
  if (dist(mouseX, mouseY, width - 50, 50) < 20) {
    println("Botão Voltar clicado! Voltando à tela principal...");
    telaMovimentacaoManual = false;
    telaPrincipal = true;
    return;
  }

  // 6) Checkboxes no painel
  float painelX = 650;
  float painelY = 70;
  float painelH = 200;
  float listStartY = painelY + 60;
  float lineHeight = 30;
  float spacing    = 8;
  float checkboxSize = 20;
  for (int i = 0; i < listaPontosManual.size(); i++) {
    float itemY = listStartY + i*(lineHeight + spacing);
    if (dentroRet(painelX + 20, itemY, checkboxSize, checkboxSize)) {
      boolean atual = listaPontosManualChecked.get(i);
      listaPontosManualChecked.set(i, !atual);
      println("Checkbox do " + listaPontosManual.get(i) + " -> " + !atual);
      return;
    }
  }

  // 7) Botões "Adicionar ponto" e "Apagar ponto"
  float painelW = 300;
  float btnAddX = painelX + 10;
  float btnAddY = painelY + painelH + 20;
  float btnAddW = 180;
  float btnAddH = 40;
  if (dentroRet(btnAddX, btnAddY, btnAddW, btnAddH)) {
    int novoIndex = listaPontosManual.size() + 1;
    listaPontosManual.add("Ponto " + nf(novoIndex, 2) + " - " + (2*novoIndex) + "ml");
    listaPontosManualChecked.add(false);
    println("Adicionado novo ponto: Ponto " + nf(novoIndex, 2));
    return;
  }
  float btnDelX = btnAddX + btnAddW + 10;
  float btnDelY = btnAddY;
  float btnDelW = 100;
  float btnDelH = 40;
  if (dentroRet(btnDelX, btnDelY, btnDelW, btnDelH)) {
    for (int i = listaPontosManual.size()-1; i >= 0; i--) {
      if (listaPontosManualChecked.get(i)) {
        println("Removendo ponto: " + listaPontosManual.get(i));
        listaPontosManual.remove(i);
        listaPontosManualChecked.remove(i);
      }
    }
    return;
  }
}


// ---------------------------------------------------------------------
//      FUNÇÃO AUXILIAR PARA VERIFICAR CLIQUE EM RETÂNGULO
// ---------------------------------------------------------------------
boolean dentroRet(float rx, float ry, float rw, float rh) {
  return (mouseX >= rx && mouseX <= rx + rw &&
          mouseY >= ry && mouseY <= ry + rh);
}
