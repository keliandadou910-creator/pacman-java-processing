/*
Squelette réalisé par mon professeur :

  class Hero {
  // position on screen
  PVector _position;
  PVector _posOffset;
  // position on board
  int _cellX, _cellY;
  // display size
  float _size;
  
  // move data
  PVector _direction;
  boolean _moving; // is moving ? 
    
  Hero() {
  }
  
  void launchMove(PVector dir) {
  }
  
  void move(Board board) {
  }
  
  void update(Board board) {
  }
  
  void drawIt() {
  }
}
*/



class Hero {
  Board _board;

  PVector _position;

  int _cellX, _cellY;

  float _size;

  // déplacement plus lisse (comme dans ghost)
  PVector _direction; 
  PVector _desiredDirection;
  boolean _moving;
  int _targetCellX, _targetCellY;
  PVector _targetPosition;
  float _angle;// orientation visuelle du sprite

  Hero(Board board, int cellX, int cellY, float size) {
    _board = board;
    _cellX = cellX;
    _cellY = cellY; 
    _size  = size;

    _position = _board.getCellCenter(_cellY, _cellX);

    _direction = new PVector(0, 0);
    _desiredDirection = new PVector(0, 0); 

    _moving = false;
    _targetCellX = _cellX;
    _targetCellY = _cellY;
    _targetPosition = _position.copy();
    _angle = 0;
  }

  PVector normalizeToCardinal(PVector dir) { 
    PVector d = dir.copy(); 
    if (abs(d.x) > abs(d.y)) {
      d.x = d.x > 0 ? 1 : -1;
      d.y = 0;
    } 
    else {
      d.y = d.y > 0 ? 1 : -1;
      d.x = 0; 
    }
    return d;
  }

  boolean isZero(PVector v) {
    return (v.x == 0 && v.y == 0);
  }
  
  /*Détermine si Pac-Man peut aller de (fromX,fromY) dans la direction "dir" en tenant compte des tunnels à gauche et à droite
    -> Si oui, remplit dest[0]= nx, dest[1] = ny et renvoie vrai. */
  boolean canMove(int fromX, int fromY, PVector dir, int[] dest) {
    if (isZero(dir)) return false;

    PVector d = normalizeToCardinal(dir);
    int maxX = _board.getNbCellsX();
    int maxY = _board.getNbCellsY() ;

    int nx = fromX + int(d.x);
    int ny = fromY + int(d.y);
 

    // si la case de gauche et la case de droite de cette ligne sont des couloirs (pas des murs),
    // alors on permet de passer de 0 -> maxX-1 et de maxX-1 -> 0.
    boolean ligneTunnel = (!_board.isWall(0, fromY) && !_board.isWall(maxX - 1, fromY));

    if (d.x < 0 && fromX == 0 && ligneTunnel) {
      nx = maxX - 1; 
    } else if (d.x > 0 && fromX == maxX - 1 && ligneTunnel) {
      nx = 0;
    } 

    if (nx < 0 || nx >= maxX || ny < 0 || ny >= maxY) return false;
    if (_board.isWall(nx, ny)) return false;

    dest[0] = nx;
    dest[1] = ny;
    return true;
  }

  boolean tryStartMove() {
    int[] dest = new int[2];

    // essaie la direction désirée (via les touches)
    if (!isZero(_desiredDirection)) {
      if (canMove(_cellX, _cellY, _desiredDirection, dest)) {
        _direction = normalizeToCardinal(_desiredDirection);
        _moving = true;
        _targetCellX = dest[0];
        _targetCellY = dest[1];
        _targetPosition = _board.getCellCenter(_targetCellY, _targetCellX);
        _angle = atan2(_direction.y, _direction.x);
        return true;
      }
    }

    // ou continuer dans la direction actuelle si possible
    if (!isZero(_direction)) {
      if (canMove(_cellX, _cellY, _direction, dest)) {
        _moving = true;
        _targetCellX = dest[0];
        _targetCellY = dest[1];
        _targetPosition = _board.getCellCenter(_targetCellY, _targetCellX);
        return true;
      }
    }
    // si aucun mouvement possible
    return false;
  }

  /* je me suis dit que mémoriser la direction demandé même si le déplacement 
     n'est pas possible immédiatement était uen bonne idée pour un contrôle plus fluide
  */

  // Si le héros est à l'arrêt, cela va tenter immédiatement de commencer à bouger.
  void launchMove(PVector dir) {
    _desiredDirection = normalizeToCardinal(dir);

    if (!_moving) {
      tryStartMove();
    }
  }

  void move() {
    if (!_moving) return;

    PVector step = _direction.copy();
    step.mult(HERO_SPEED);
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

  // appeler normalement par Game.update()
  void update(Board board) {
    if (!_moving) { 
      tryStartMove();
    }

    move();
  }

  void drawIt() {
    pushMatrix(); 
    translate(_position.x, _position.y);
    rotate(_angle); 
    imageMode(CENTER);

    if (HERO_IMG != null) {
      image(HERO_IMG, 0, 0, _size, _size);
    } 
    else {
      noStroke();
      fill(255, 255, 0); 
      ellipse(0, 0, _size, _size);
    }
    popMatrix();
  }
}
