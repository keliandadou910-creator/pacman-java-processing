/*
Squelette réalisé par mon professeur :

Game game;

void setup() {
  size(800, 800, P2D);
  game = new Game();
}

void draw() {
  game.update();
  game.drawIt();
}

void keyPressed() {
  game.handleKey(key);
}

void mousePressed() {
}
*/

Game game;

void settings() {
  // pour bien  dimensionner la fenêtre
  String[] lines = loadStrings("levels/level1.txt");
  
  if (lines == null || lines.length < 2) {
    println("Erreur : impossible de charger levels/level1.txt");
    exit();
  }

  int nbCellsX = lines[1].length();
  int nbCellsY = lines.length - 1;
  int boardWidth  = nbCellsX * CELL_SIZE;
  int boardHeight = nbCellsY * CELL_SIZE;

  size(boardWidth, boardHeight);
}

void setup() {
  // essaie de charger Pac-Man
  SPRITES = loadImage("img/pacman_sprites.png");
  println("SPRITES = " + SPRITES);

  if (SPRITES == null) {
    println("ERREUR : img/pacman_sprites.png introuvable !");
  } 
  else {
    HERO_IMG  = SPRITES.get(HERO_SX,  HERO_SY,  HERO_SW,  HERO_SH);
    GHOST_IMG = SPRITES.get(GHOST_SX, GHOST_SY, GHOST_SW, GHOST_SH);
    
    println("HERO_IMG  = " + HERO_IMG);
    println("GHOST_IMG = " + GHOST_IMG);
  }
  game = new Game();
}


void draw() {
  game.update();
  game.drawIt();
}

void keyPressed() {
  // au cas où ESC est pressé pour afficher et/ou cacher le menu
  if (key == ESC) {
    key = 0; // sert à empêcher Processing de fermer la fenêtre
    game.toggleMenu();
    return ;
  }
  game.handleKey(key);
}
