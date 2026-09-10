/* 
Squelette réalisé par mon professeur :

  class Menu {
  Menu() {
  }
  
  void drawIt() {
  } 
}
*/

class Menu { 
  Game _game; 
  boolean _visible;

  String[] _items = { "Reprendre", "Recommencer",  "Sauvegarder","Charger", "Meilleur score", "Quitter"};

  int _selected = 0; 

  Menu(Game g) {
    _game = g;
    _visible = false;
  }

  boolean isVisible() {
    return _visible;
  }

  void show() {
    _visible = true;
  }

  void hide() {
    _visible = false;
  }

  void drawIt() {
    if (!_visible) return; 

    noStroke();
    fill(0, 0, 0, 180);
    rectMode(CORNER); 
    rect(0, 0, width, height); 

    // panneau central
    float w = width * 0.4; 
    float h = height * 0.5;
    float x = (width - w) / 2.0; 
    float y = (height - h) / 2.0;  

    fill(0, 0, 60);
    stroke(255);
    strokeWeight(2);
    rect(x, y, w, h, 20);

    textAlign(CENTER, TOP);
    textSize(24);
    fill(255);
    text("MENU PAUSE", width/2, y + 20);

    textSize(18);
    float itemY = y + 70;
    for (int i = 0; i < _items.length; i++) {
      
      if (i == _selected) {
        fill(255, 255, 0);
      } 
      else {
        fill(255);
      }
      
      text(_items[i], width/2, itemY); 
      itemY +=30;
    }

    fill(200);
    textSize(14);
    text("Meilleur score : " + _game.getHighScore(), width/2, y + h - 30);
  }

  void handleKey(int k) {
    if (!_visible) return;

    // pour naviguer avec les flèches
    if (keyCode == UP) {
      _selected--;
      
      if (_selected < 0) _selected = _items.length - 1; 
    } 
    else if (keyCode == DOWN) {
      _selected++;
      if (_selected >= _items.length) _selected = 0;
    } 
    else if (k == ENTER || k == RETURN) {
      activateCurrentItem(); 
    }
  }

  void activateCurrentItem() {
    switch(_selected) {
      
    case 0:
      hide();
      break;
    case 1: 
      _game.restartLevel();
      hide();
      break ;
    case 2:  
      _game.saveGame("save.txt");
      break;
    case 3:
      _game.loadGame("save.txt");
      hide();
      break;
    case 4: 
      _game.showHighScoreScreen();
      break;
    case 5: 
      exit();
      break;
    }
  }
}
