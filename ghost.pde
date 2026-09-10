/*
Nouvelle class
*/



class Ghost {
  Board _board;

  PVector _position;
  int _cellX, _cellY;

  // déplacement plus lisse
  PVector _direction; 
  PVector _targetPosition;
  int _targetCellX, _targetCellY; 
  boolean _moving;

  float _size;

  float _normalSpeed;
  float _frightenedSpeed;
  float _speed;

  color _baseColor;
  color _frightenedColor;

  boolean _frightened;
  boolean _inHouse;

  int _spawnCellX, _spawnCellY;

  Ghost(Board board, int cellX, int cellY, float size, color c) {
    _board = board;
    _cellX = cellX;
    _cellY = cellY; 
    _size = size;

    _position = _board.getCellCenter(_cellY, _cellX);

    _direction = new PVector(1, 0);
    _moving = false;
    _targetCellX = _cellX;
    _targetCellY = _cellY;
    
    _targetPosition = _position.copy();

    _normalSpeed = HERO_SPEED * 0.9;
    _frightenedSpeed = HERO_SPEED * 0.5;
    _speed = _normalSpeed;

    _baseColor= c;
    _frightenedColor = color(0, 0, 255);

    _frightened = false;


    _inHouse = true; // les fantômes sont à dans la maison

    _spawnCellX = cellX;
    _spawnCellY = cellY;
  }

  void setFrightened(boolean f) {
    _frightened = f;
    if (f == true) {
      _speed = _frightenedSpeed;
    } else {
      _speed = _normalSpeed;
    }
  }

  boolean isFrightened() {
    return _frightened;
  }

  void setInHouse(boolean h) {
    _inHouse = h;
  }

  boolean isInHouse() {
    return _inHouse;
  }

  void respawn() {
    /* Choix que j'ai pris 
       -> au respawn, je réinitialise explicitement l'état frightened
          pour éviter qu'un fantôme reste bleu par erreur après avoir été mangé. */

    // Retour dans la maison quand respawn 
    _cellX = _spawnCellX;
    _cellY = _spawnCellY;
    _position = _board.getCellCenter(_cellY, _cellX);

    _direction = new PVector(1,  0);
    _moving = false; 
    _targetCellX = _cellX;
    _targetCellY = _cellY; 
    _targetPosition = _position.copy();

    _frightened = false; 
    _speed = _normalSpeed;

    _inHouse =  true;
  }

  boolean isOppositeDirection(PVector dir) {
    return (dir.x == -_direction.x && dir.y == -_direction.y);
  }

  void planNextMove() {
    PVector[] candidates = {
      new PVector(1, 0),   // à droite
      new PVector(-1, 0),  // à gauche
      new PVector(0, 1),   // en bas
      new PVector(0, -1)   // en haut
    };

    ArrayList <PVector> possibles = new ArrayList <PVector>();

    int maxX = _board.getNbCellsX();

    for (int i = 0; i < candidates.length; i++) {
      PVector cand = candidates[i];
      int nx = _cellX + int(cand.x);
      int ny = _cellY + int(cand.y);

      if (nx < 0) nx = maxX - 1;
      else if (nx >= maxX) nx = 0;

      if (!_board.isWall(nx, ny)) {
        if (!isOppositeDirection(cand) || possibles.size() == 0) {
          possibles.add(cand);
        } 
      }
    }
 
    if (possibles.size() == 0) {
      _direction.mult(-1);
    } 
    else {
      int idx = int(random(possibles.size()));
      _direction = possibles.get(idx).copy();
    }

    _targetCellX = _cellX +int(_direction.x);
    _targetCellY = _cellY +int(_direction.y);

    int maxCX = _board.getNbCellsX();
    if (_targetCellX < 0) _targetCellX = maxCX - 1;
    else if (_targetCellX >= maxCX) _targetCellX = 0;

    _targetPosition = _board.getCellCenter(_targetCellY, _targetCellX);
    _moving = true;
  }

  void move() {
    if (!_moving) return;

    PVector step = _direction.copy();
    step.mult(_speed);
    _position.add(step);

    boolean reached = false;

    if (_direction.x > 0 && _position.x >= _targetPosition.x) reached = true;
    else if (_direction.x < 0 && _position.x <= _targetPosition.x) reached = true;
    
    else if (_direction.y > 0 && _position.y >= _targetPosition.y) reached = true;
    
    else if (_direction.y < 0 && _position.y <= _targetPosition.y) reached = true;

    if (reached) {
      _position = _targetPosition.copy();
      _cellX = _targetCellX;
      _cellY = _targetCellY;
      _moving = false;
    }
  }

  void update() {
    // Tant qu'il est dans la maison, le fantôme ne bouge pas
    if (_inHouse) return;

    if (!_moving) {
      planNextMove();
    }
    move();
  }

  void drawIt() {
    pushMatrix();
    translate(_position.x, _position.y);
    imageMode(CENTER);

    if (GHOST_IMG != null) {
      if (_frightened) {
        tint(_frightenedColor);
      } 
      else {
        tint(_baseColor); 
      }
      
      image(GHOST_IMG, 0, 0, _size, _size);
      noTint(); 
    } 
    else {
      noStroke();
      if (_frightened) fill(_frightenedColor);
      else fill(_baseColor);
      ellipse (0, 0, _size, _size);
    } 
    popMatrix();
  }
  boolean collidesWith(Hero h) {
    return (_cellX == h._cellX && _cellY == h._cellY);
  }
}
