/*
Squelette réalisé par mon professeur :

class Game 
{
  Board _board;
  Hero _hero;
  
  String _levelName;
  
  Game() {
    _board = null;
    _hero = null;
  }
  
  void update() {
  }
  
  void drawIt() {
  }
  
  void handleKey(int k) {
  }
}
*/


class Game {
  Board _board;
  Hero _hero;
  
  ArrayList <Ghost> _ghosts;  
 
  String _levelName;

  int _score;
  int _lives;
  boolean _gameOver;

  boolean _extraLifeGiven; //evite multi-vies à chaque frame

  // tableau des 5 meilleurs scores
  String[] _topNames;
  int[] _topScores;
  int _highScore;

  boolean _showHighScoreScreen;

  Menu _menu;

  // Mode super en mangant une Super-Pac-Gomme
  int _frightenedTimer;
  int _ghostsEatenInFrightened;    // ça stock le nombre de fantômes mangés

  // Bonus
  boolean _bonusActive;
  int _bonusCellX, _bonusCellY;
  int _bonusTimer;
  int _bonusCooldown;

  // Sorti  des fantômes
  int _ghostReleaseTimer;

  // Saisie du nom du joueur pour un nouveau top 5
  boolean _awaitingName;
  String _nameInput;
  int _pendingRank;

  Game() {
    initFromLevelFile("levels/level1.txt");
    loadHighScores();
    _highScore = _topScores[0];

    _menu = new Menu(this);
    _showHighScoreScreen = false;

    _menu.show();
  }

  void initFromLevelFile(String filename) {
    String[] lines = loadStrings(filename);
    if (lines == null || lines.length < 2) {
      println("Erreur : impossible de charger " + filename);
      exit();
    }

    int nbCellsX = lines[1].length();
    int nbCellsY = lines.length - 1; 
 
    int boardWidth = nbCellsX * CELL_SIZE;
    int boardHeight = nbCellsY * CELL_SIZE;
 
    PVector pos = new PVector((width - boardWidth) / 2.0, (height - boardHeight) / 2.0);

    _board = new Board(pos, nbCellsX, nbCellsY, CELL_SIZE); 
    _board.loadFromLines(lines, 0);
    _levelName = _board.getLevelTitle();

    _score = 0;
    _lives = INITIAL_LIVES;
    _gameOver = false;

    _extraLifeGiven = false;

    _frightenedTimer=0;
    _ghostsEatenInFrightened=0;

    resetBonusState();
    _ghostReleaseTimer = 0;

    _awaitingName = false;
    _nameInput = "";
    _pendingRank = -1;

    // héros
    PVector startCell = _board.getHeroStartCell();
    _hero = new Hero(_board, int(startCell.x), int(startCell.y), CELL_SIZE * 0.8);

    createGhostsInHouse();
  }

  void resetHero() {
    PVector startCell = _board.getHeroStartCell();
    _hero = new Hero(_board, int(startCell.x), int(startCell.y), CELL_SIZE * 0.8);

    // les fantômes reviennent dans la maison à chaque perte de vie
    createGhostsInHouse();
    _frightenedTimer = 0;
    _ghostsEatenInFrightened = 0;
  }

  void loseLife() {
    _lives--;
    _frightenedTimer = 0;
    _ghostsEatenInFrightened = 0;
    setAllGhostsFrightened(false);

    if (_lives <= 0) {
      handleGameOver();
    } else {
      resetHero();
    }
  }


  void createGhostsInHouse() {
    _ghosts = new ArrayList<Ghost>();

    int midX = _board.getNbCellsX() / 2;
    int midY = _board.getNbCellsY() / 2;

    // Positions pour la maison des fantômes
    int[][] offsets = {
      {  0,  0 },
      { -1,  0 },
      {  1,  0 },
      {  0,  1 }
    };

    color[] colors = {
      color(255, 0, 0),
      color(255, 184, 255), 
      color(0, 255, 255),
      color(255, 165, 0)  
    };

    ArrayList <PVector> spawnCells = new ArrayList <PVector>();

    // 1) On fait autour du centre
    for (int i = 0; i < offsets.length; i++) { 
      int cx = midX + offsets[i][0];
      int cy = midY + offsets[i][1]; 
      
      if (!_board.isWall(cx, cy)) { 
        spawnCells.add(new PVector(cx, cy));
      } 
    }

    // 2) Compléter au cas où en cherchant des cases libres proche du centre
    int needed = 4 - spawnCells.size();
    if (needed > 0) {
      for (int radius = 1; radius < max(_board.getNbCellsX(), _board.getNbCellsY()) && needed > 0; radius++) {
        for (int y = 0; y < _board.getNbCellsY() && needed > 0; y++) {
          for (int x = 0; x < _board.getNbCellsX() && needed > 0; x++) {
            if (_board.isWall(x, y)) continue;

            if (x == int(_board.getHeroStartCell().x) && y == int(_board.getHeroStartCell().y)) continue;
            int d = abs(x - midX) + abs(y - midY);
            
            if (d == radius) {
              boolean already = false;
              for (PVector p : spawnCells) {
                if (int(p.x) == x && int(p.y) == y) {
                  already = true;
                  break;
                }
              }
              
              if (!already) {
                spawnCells.add(new PVector(x, y));
                needed--;
              }
            }
          }
        }
      }
    }

    int idxColor = 0;
    for (int i = 0; i < 4 && i < spawnCells.size(); i++) {
      PVector c = spawnCells.get(i);
      Ghost g = new Ghost(_board, int(c.x), int(c.y), CELL_SIZE * 0.8, colors[idxColor]);
      g.setInHouse(true);
      _ghosts.add(g);
      idxColor = (idxColor + 1) % colors.length;
    }

    _ghostReleaseTimer = 0;
  }

  void setAllGhostsFrightened(boolean frightened) {
    if (_ghosts == null) return ;
    for (Ghost g : _ghosts) {
      g.setFrightened(frightened);
    }
  } 

  boolean allGhostsReleased() {
    if (_ghosts == null) return true;
    for (Ghost g : _ghosts) {
      if (g.isInHouse()) return false;
    }
    return true;
  }

  void updateGhostRelease() {
    if (_ghosts == null) return;
    if (allGhostsReleased()) return;

    _ghostReleaseTimer++;
    if (_ghostReleaseTimer >= GHOST_RELEASE_INTERVAL) {
      _ghostReleaseTimer = 0;
      for (Ghost g : _ghosts) { // On libère le prochain fantôme 
        if (g.isInHouse()) {
          g.setInHouse(false);
          break;
        }
      }
    }
  }

   // Gestion du Top 5
  void loadHighScores() {
    _topNames = new String[5];
    _topScores = new int[5]; 

    for (int i = 0; i < 5; i++) {
      _topNames[i] = "---";
      _topScores[i] = 0; 
    }

    String[] lines = null;
    try {
      lines = loadStrings("highscores.txt");
    }  
    catch (Exception e) {
      lines = null;
    } 

    if (lines == null) return ;

    int n = min(5, lines.length);
    for (int i = 0; i < n; i++) {
      String[] parts = split(lines[i], ';');
      
      if (parts.length == 2) {
        _topNames[i] = parts[0];
        _topScores[i] = int(trim(parts[1]));
      }
    }
  }

  void saveHighScores() {
    String[] lines = new String[5];
    for (int i = 0; i < 5; i++) { 
      lines[i] = _topNames[i] +";"+ _topScores[i];
    }
    saveStrings("highscores.txt", lines);
  }

  int getHighScore() {
    return _topScores[0]; 
  }

  // Renvoie la position pour savoir où le score s'insère et il renvoie -1 si il fait pas partie du top 5
  int getRankForScore(int s) {
    for (int i = 0; i < 5; i++) {
      if (s > _topScores[i]) { 
        return i;
      } 
    }
    return -1;
  } 

  void insertHighScore(int rank, String name, int score) {
    for (int i = 4; i > rank; i--) {
      _topNames[i] = _topNames[i - 1]; 
      _topScores[i] = _topScores[i - 1];
    }
    _topNames[rank] = name;
    _topScores[rank] = score; 

    saveHighScores();
    _highScore = _topScores[0] ;
  }

  void showHighScoreScreen() {
    _showHighScoreScreen = true;
  }

  void hideHighScoreScreen() {
    _showHighScoreScreen = false;
  }

  void handleGameOver() { // fin de partie
    _gameOver= true;

    int rank = getRankForScore(_score);
    if (rank != -1) {
      _awaitingName = true;
      _pendingRank = rank;
      _nameInput = ""; 
    } 
    else {
      _highScore = _topScores[0]; 
    }
  }

  void handleNameInput(int k) {
    if (k == ENTER || k == RETURN) {
      String name = _nameInput.trim();
      if (name.length() == 0) {
        name = "PLAYER";
      }
      insertHighScore(_pendingRank, name, _score);
      _awaitingName = false;
      _pendingRank = -1;
      return;
    }

    if (k == BACKSPACE || k == 8) { // le 8 c'est le retour en arrière)
      if (_nameInput.length() > 0) {
        _nameInput = _nameInput.substring(0, _nameInput.length()-1);
      } 
      return;
    }
    if (k >= 32 && k <= 126) {
      if (_nameInput.length() < 12) {
        _nameInput += char(k);
      }
    }
  }

  void saveGame(String filename) {
    ArrayList <String> lines = new ArrayList <String>();

    lines.add(_score + " " + _lives);

    lines.add(_hero._cellX + " " + _hero._cellY);
 
    String[] boardLines = _board.serialize();
    for (int i = 0; i < boardLines.length; i++) {
      lines.add(boardLines[i]);
    }
    saveStrings(filename,lines.toArray(new String[lines.size()]));
    println("Partie sauvegardée dans " + filename); 
  } 

  void loadGame(String filename) {
    String[] lines = loadStrings(filename);
    if (lines == null || lines.length < 3) {
      println("Pas de sauvegarde trouvée.");
      return;
    }

    String[] parts = split(lines[0], ' ');
    _score = int(parts[0]);
    _lives = int(parts[1]);


    _extraLifeGiven = (_score >= LIFE_THRESHOLD); // la vie bonus à 10 000 est déjà donnée si le score est supérieur au seuil

    String[] heroParts = split(lines[1], ' ');
    int hx = int(heroParts[0]);
    int hy = int(heroParts[1]);

    int boardStart = 2;
    int nbCellsX = lines[boardStart + 1].length();
    int nbCellsY = lines.length - (boardStart + 1);

    int boardWidth = nbCellsX * CELL_SIZE;
    int boardHeight = nbCellsY * CELL_SIZE;

    PVector pos = new PVector((width - boardWidth) / 2.0,(height - boardHeight) / 2.0);

    _board = new Board(pos, nbCellsX, nbCellsY, CELL_SIZE);
    _board.loadFromLines(lines, boardStart); 

    _levelName = _board.getLevelTitle();  

    _hero = new Hero(_board, hx, hy, CELL_SIZE * 0.8);

    createGhostsInHouse();

    _gameOver = false;
    _frightenedTimer = 0;
    _ghostsEatenInFrightened = 0;
    setAllGhostsFrightened(false);
    resetBonusState();

    _awaitingName = false;
    _pendingRank = -1;
    _nameInput = "";

    println("Partie chargée depuis " + filename);
  }

  void restartLevel() {
    initFromLevelFile("levels/level1.txt");
    hideHighScoreScreen();
  }

  void resetBonusState() { // pour gérer les bonus
    _bonusActive = false;
    _bonusTimer = 0;
    _bonusCooldown = int(random(BONUS_APPEAR_MIN,BONUS_APPEAR_MAX));
  } 

  void scheduleNextBonus() {
    _bonusCooldown = int(random(BONUS_APPEAR_MIN,BONUS_APPEAR_MAX));
  }

  void spawnBonus() {
    ArrayList <PVector> candidates = new ArrayList <PVector>();

    for (int y = 0; y < _board.getNbCellsY(); y++) {
      for (int x = 0; x < _board.getNbCellsX(); x++) {
        TypeCell cell = _board.getCell(x, y);
        if (cell == TypeCell.EMPTY || cell == TypeCell.DOT) {
          
          if (!(x == _hero._cellX && y == _hero._cellY)) {
            candidates.add(new PVector(x, y));
          }
        }
      }
    }
    if (candidates.size() == 0) {
      scheduleNextBonus(); 
      return;
    }

    int idx = int(random(candidates.size()));
    PVector c = candidates.get(idx);

    _bonusCellX = int(c.x);
    _bonusCellY = int(c.y);

    _board.placeBonus(_bonusCellX, _bonusCellY);
    _bonusActive = true;
    _bonusTimer = BONUS_LIFETIME;
  }

  void updateBonus() {
    if (_bonusActive) {
      _bonusTimer--;
      
      if (_bonusTimer <= 0) {
        _board.clearBonus(_bonusCellX, _bonusCellY);
        _bonusActive = false;
        scheduleNextBonus();
      }
      
    } 
    else {
      if (_bonusCooldown > 0) {
        _bonusCooldown--;
      }
      if (_bonusCooldown == 0) {
        spawnBonus();
      }
    }
  }


  void update() {
    if (_menu.isVisible()) return;
    if (_showHighScoreScreen) return;
    if (_gameOver) return;
    if (_awaitingName) return;

    _hero.update(_board);

    updateGhostRelease();

    /* Choix : je préfère ici gérer et donc centraliser les collisions héros et fantômes
       pour avoir une seule logique pour le score et les vies.
       J'évite des incohérences si plusieur fantômes touchent le héros à la même frame
    */
    for (Ghost g : _ghosts) {// maj des fantôme et des collisions
      g.update(); 
      if (g.isInHouse()) continue;
      if (g.collidesWith(_hero)) { 
        
       if (_frightenedTimer > 0 && g.isFrightened()) {
         _ghostsEatenInFrightened++;

         int index = min(_ghostsEatenInFrightened - 1, GHOST_EAT_SCORES.length - 1);

         int gained = GHOST_EAT_SCORES[index];
         _score += gained;

          g.respawn();
        } else {
          loseLife();
          return;
        }
      }
    }

    // gestion des Pac-gommes/Super-Pac-Gommes/ bonus
    TypeCell eaten = _board.collectAt(_hero._cellX, _hero._cellY);
    if (eaten == TypeCell.DOT) {
      _score += SCORE_DOT; 
    } else if (eaten == TypeCell.SUPER_DOT) {
      _score += SCORE_SUPER_DOT;

      _frightenedTimer = FRIGHTENED_DURATION;
      setAllGhostsFrightened(true);

      _ghostsEatenInFrightened = 0;
    } else if (eaten == TypeCell.BONUS) {

      _score += SCORE_BONUS;
      _bonusActive = false;
      _bonusTimer = 0;
      scheduleNextBonus();
    }

    if (_frightenedTimer > 0) {
      _frightenedTimer--;
      if (_frightenedTimer == 0) {
        setAllGhostsFrightened(false);
        _ghostsEatenInFrightened = 0;
      }
    }

    updateBonus(); 

    if (_board.hasNoDots()) {
      handleGameOver();
    }
    
    if (!_extraLifeGiven && _score >= LIFE_THRESHOLD) { // vie bonus à 10 000 points (une seule fois)
      _lives++;
      _extraLifeGiven = true;
    }
  }

  void drawIt() {
    background(0);

    _board.drawIt();
    _hero.drawIt();

    for (Ghost g : _ghosts) {
      g.drawIt();
    }

    fill(255);
    textAlign(LEFT, TOP);
    textSize(16);
    text("Score : " + _score, 10, 10);
    text("Vies  : " + _lives, 10,30);
    text("High : " + getHighScore(), 10, 50);

    if (_gameOver) {
      textAlign(CENTER, CENTER);
      textSize(32);
      fill(255, 0, 0);
      text("FIN DE PARTIE", width/ 2, height/2);
    }

    if (_showHighScoreScreen) {
      drawHighScoreScreen();
    }

    if (_awaitingName) {
      drawNameInput();
    }

    _menu.drawIt();
  }
 
  void drawHighScoreScreen() {
    fill(0, 0, 0, 200);
    rect(0, 0, width, height);

    fill(255); 
    textAlign(CENTER, TOP);
    textSize(28);
    text("MEILLEURS SCORES", width/2, 60);

    textSize(20);
    float y = 120; 
    for (int i = 0; i < 5; i++) {
      String line = (i+1) + ". " + _topNames[i] + " - " + _topScores[i];
      text(line, width/2, y);
      y += 30;
    }

    textSize(16);
    text("Appuie sur ESC pour revenir", width/2, y + 40);
  }

  void drawNameInput() {
    fill(0, 0, 0, 200);
    rect(0, 0, width, height);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(24);
    text("NOUVEAU MEILLEUR SCORE !", width/2, height/2 -60);

    textSize(18);
    text("Entre ton nom puis appuie sur Entrée :", width/2, height/2 - 20);

    textSize(22);
    text(_nameInput + "_", width/2, height/2 + 20);
  }

  void handleKey(int k) {
    if (_awaitingName) {
      handleNameInput(k);
      return;
    }

    if (_showHighScoreScreen) {
      if (k == ESC || k == ENTER || k == ' ') {
        hideHighScoreScreen();
      }
      return ;
    }

    if (_menu.isVisible()) {
      _menu.handleKey(k);
      return ;
    }

    if (_gameOver) {
      return ;
    }

    if (k == 'k' || k == 'K') {
      loseLife();
      return;
    }

    PVector dir = new PVector(0, 0);

    if (k == 'z' || k == 'Z' || keyCode == UP) {
      dir.y = -1;
    } else if (k == 's' || k == 'S' || keyCode == DOWN) {
      dir.y = 1;
    } else if (k == 'q' || k == 'Q' || keyCode == LEFT) {
      dir.x = -1;
    } else if (k == 'd' || k == 'D' || keyCode == RIGHT) {
      dir.x = 1;
    }

    if (dir.x != 0 || dir.y != 0) {
      _hero.launchMove(dir);
    }
  }

  void toggleMenu() {
    if (_menu.isVisible()) _menu.hide();
    else _menu.show();
  }
}
