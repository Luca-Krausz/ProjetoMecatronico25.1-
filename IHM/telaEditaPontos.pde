// -----------------------------------------------------------------------------
//  TELA EDITAR PONTOS COLETA E DISPENSA
// -----------------------------------------------------------------------------

// Variáveis da tela de edição
Ponto pontoEditado;

Button buttonSalvarEdit, buttonCancelarEdit, scrollRightButtonEdit, scrollLeftButtonEdit, scrollDownButtonEdit, scrollUpButtonEdit;

void setupTelaEditaPontos() {
 
  buttonSalvarEdit = new Button(true, 600, 500, 180, 50, "SALVAR", azulEscuro, branco);
  buttonCancelarEdit = new Button(true, 800, 500, 180, 50, "CANCELAR", cinzaClaro, branco);

  // Scroll Buttons
  scrollUpButtonEdit   = new Button(true, width - 630, height/2 - 180, 40, 40, "↑", azulEscuro, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  scrollDownButtonEdit = new Button(true, width - 630, height/2 + 120, 40, 40, "↓", azulEscuro, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  scrollLeftButtonEdit   = new Button(true, width - 400, height/2 + 100, 40, 40, "←", azulEscuro, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  scrollRightButtonEdit = new Button(true, width - 100, height/2 + 100, 40, 40, "→", azulEscuro, branco); // (square?, x, y, w, h, label, bgColor, textcolor)
  

}

void desenhaTelaEditaPontos() {
  background(branco);

  // --- Logo e Título (sem alterações) ---
  if (logo != null) {
    image(logo, width - logo.width - 900, -40);
  }
  textSize(fontTitulo - 15);
  fill(0);
  textAlign(CENTER);
  text("Editar ponto", 800, 100);

  // --- Subtítulos e campos de input (sem alterações) ---
  textSize(fontSubtitulo);
  fill(cinzaEscuro);
  textAlign(LEFT);
  text("Nome do Ponto:", 600, 160);
  text("Volume (mL):", 600, 260);
  if (edicaoColetaEdit) {
    text("Pontos de dispensa associados:", 600, 360);
  } else {
    text("Ponto de coleta correspondente:", 600, 360);
  }
  fill(branco);
  stroke(azulEscuro);
  rect(600, 170, 400, 35, 10);
  rect(600, 270, 400, 35, 10);
  noStroke();

  // --- Painel lateral: Pontos selecionados ---
  float panelX = width - 950, panelW = 380, panelY = 70, panelH = height - 150;
  fill(brancoBege);
  rect(panelX, panelY, panelW, panelH, 8);
  fill(azulEscuro);
  textSize(20);
  textAlign(LEFT, CENTER);
  text("Pontos Selecionados:", panelX + 20, panelY + 30);

  // Coletar pontos selecionados
  ArrayList<Ponto> sel = new ArrayList<Ponto>();
  if (edicaoColetaEdit) {
    for (Ponto p : listaPontosColeta) if (p.selected) sel.add(p);
  } else {
    for (Ponto p : listaPontosDispensa) if (p.selected) sel.add(p);
  }
  // Desenhar nomes (sem checkbox)  
  textSize(16);
  float y0 = panelY + 70, lineH = 25;
  fill(azulEscuro);
  for (int i = 0; i < sel.size(); i++) {
    text("- " + sel.get(i).nome, panelX + 20, y0 + i * lineH);
  }
  if (sel.isEmpty()) {
    fill(cinzaClaro);
    textSize(14);
    text("Nenhum selecionado", panelX + 20, panelY + 70);
  }

  // --- Painel inferior: associados/correspondentes ---
  float downX = width - 420, downY = 380, downW = 380, downH = 80;
  fill(brancoBege);
  rect(downX, downY, downW, downH, 8);

  textSize(14);
  textAlign(LEFT, CENTER);
  float tx0 = downX + 20, ty0 = downY + downH / 2;

  if (edicaoColetaEdit) {
    // Se vim de coleta → mostrar apenas as dispensas associadas
    ArrayList<Ponto> assoc = new ArrayList<Ponto>();
    for (Ponto c : listaPontosColeta) {
      if (c.selected) {
        for (Ponto d : listaPontosDispensa) {
          if (coordsIguais(d.coordsColeta, c.coords)) {
            assoc.add(d);
          }
        }
      }
    }
    if (assoc.isEmpty()) {
      fill(cinzaClaro);
      text("Nenhuma dispensa associada", tx0, ty0);
    } else {
      fill(azulEscuro);
      for (int i = 0; i < assoc.size(); i++) {
        text(assoc.get(i).nome,
             tx0 + (i % 4) * 90,               // até 4 colunas
             ty0 + (i / 4) * lineH);           // próxima linha se precisar
      }
    }
  } else {
    // Se vim de dispensa → mostrar todas as coletas, destacando as associadas
    for (int i = 0; i < listaPontosColeta.size(); i++) {
      Ponto c = listaPontosColeta.get(i);
      // verificar se alguma dispensa selecionada aponta para esta coleta
      boolean destaque = false;
      for (Ponto d : listaPontosDispensa) {
        if (d.selected && coordsIguais(d.coordsColeta, c.coords)) {
          destaque = true;
          break;
        }
      }
      fill(destaque ? azulEscuro : cinzaClaro);
      text(c.nome,
           tx0 + (i % 4) * 90,
           ty0 + (i / 4) * lineH);
    }
  }

  // --- Botões de navegação e ação (sem alterações) ---
  backButton.draw();
  buttonSalvarEdit.draw();
  buttonCancelarEdit.draw();
  scrollRightButtonEdit.draw();
  scrollLeftButtonEdit.draw();
  scrollDownButtonEdit.draw();
  scrollUpButtonEdit.draw();
}


void mousePressedTelaEditaPontos() {
  if (backButton.isMouseOver()) {
    telaEditaPontos = false;
    
    if (edicaoColetaEdit == true){
      telaPontosColeta = true;
    }
    else{
      telaPontosDispensa = true;
    }
    
    return;
  }
  if (buttonCancelarEdit != null && buttonCancelarEdit.isMouseOver()) {
    telaEditaPontos = false;
    telaPipetagem = true;
    return;
  }
  if (buttonSalvarEdit != null && buttonSalvarEdit.isMouseOver()) {
    pontoEditado.nome = inputNomeEdit;
    pontoEditado.volume = int(inputVolumeEdit);
    telaEditaPontos = false;
    telaPipetagem = true;
    return;
  }
}

void mouseReleasedTelaEditaPontos() {
  if (buttonSalvarEdit.isMouseOver()) {
  // AGORA que o usuário já salvou, você pode limpar:
  for (Ponto p : listaPontosColeta)  p.selected = false;
  for (Ponto p : listaPontosDispensa) p.selected = false;
  telaEditaPontos = false;
  telaPipetagem = true;
  return;
}

}
