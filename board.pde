/*
Squelette réalisé par mon professeur :

enum TypeCell 
{
  EMPTY, WALL, DOT, SUPER_DOT // others ?
}

class Board 
{
  TypeCell _cells[][];
  PVector _position;
  int _nbCellsX;
  int _nbCellsY;
  int _cellSize; // cells should be square
  
  Board(PVector position, int nbCellsX, int nbCellsY, int cellSize) {
  }
  
  PVector getCellCenter(int i, int j) {
    return null;
  }
  
  void drawIt() {
  }
}
*/


enum TypeCell {
  EMPTY, // 'V'
  WALL, // 'x'
  DOT, // 'o'
  SUPER_DOT, // 'O'
  BONUS // 'B'
}

class Board {
  TypeCell[][] _cells;   

  PVector _position; 
  int _nbCellsX;
  int _nbCellsY;
  int _cellSize; 

  String _levelTitle;

  int _nbDots;
  int _nbSuperDots;

  int _heroStartX;
  int _heroStartY;

  Board(PVector position, int nbCellsX, int nbCellsY, int cellSize) {
    _position = position;
    _nbCellsX = nbCellsX;
    _nbCellsY = nbCellsY;
    _cellSize = cellSize;
    _cells = new TypeCell[_nbCellsY][_nbCellsX];
    loadLevel("levels/level1.txt");
  }

  void loadLevel(String filename) {
    String[] lines =loadStrings(filename);
    if (lines == null) {
      println("Erreur : impossible de charger " +filename);
      exit();
    }
    loadFromLines(lines, 0);
  }

  void loadFromLines(String[] lines, int startLine) {
    _levelTitle = lines[startLine];

    _nbDots = 0;
    _nbSuperDots = 0;

    for (int i = 0; i < _nbCellsY; i++) {
      String row = lines[startLine + 1 + i];
      for (int j = 0; j < _nbCellsX; j++) {
        char c = row.charAt(j);
        switch (c) {
        case 'x':
          _cells[i][j] = TypeCell.WALL;
          break;
        case 'o':
          _cells[i][j] = TypeCell.DOT;
          _nbDots++;
          break;
        case 'O':
          _cells[i][j] = TypeCell.SUPER_DOT;
          _nbSuperDots++;
          break;
        case 'B':
          _cells[i][j] = TypeCell.BONUS;
          break;
        case 'P':
          _cells[i][j]  = TypeCell.EMPTY;
          _heroStartX = j;
          _heroStartY = i;
          break;
        case 'V':
        default:
          _cells[i][j] = TypeCell.EMPTY;
          break;
        }
      }
    }
  }

  String[] serialize() {
    String[] res = new String[_nbCellsY + 1];
    res[0] = _levelTitle;

    for (int i = 0; i < _nbCellsY; i++) {
      String row = "";
      for (int j = 0; j < _nbCellsX; j++) {
        TypeCell cell = _cells[i][j]; 
        char c;
        if (cell == TypeCell.WALL) c = 'x';
        else if (cell == TypeCell.DOT) c = 'o';
        else if (cell == TypeCell.SUPER_DOT) c = 'O';
        else if (cell == TypeCell.BONUS) c = 'B'; 
        else c = 'V'; // empty
        row += c;
      }
      res[i+1] = row;
    }

    return res;
  }

  // Renvoie le centre en pixels de la case ligne i et colonne j
  PVector getCellCenter(int i, int j) {
    float x = _position.x +j * _cellSize + _cellSize / 2.0;
    float y = _position.y + i * _cellSize + _cellSize / 2.0;
    return new PVector(x,y);
  }

  boolean isInside(int cx, int cy) { 
    return (cx >= 0 && cx < _nbCellsX && cy >= 0 && cy < _nbCellsY);
  }

  boolean isWall(int cx, int cy) {
    if (!isInside(cx, cy)) return true;  // ce qui est hors plateau est considérer comme un mur
    return _cells[cy][cx] == TypeCell.WALL; 
  }

  TypeCell getCell(int cx, int cy) {
    if (!isInside(cx, cy)) return TypeCell.EMPTY;
    return _cells[cy][cx];
  }

  /* 
     Je laisse Board décider de ce qui est collecté
     pour éviter que Game manipule direct la grille
  */

  TypeCell collectAt(int cx, int cy) {
    if (!isInside(cx, cy)) return TypeCell.EMPTY; 

    TypeCell cell = _cells[cy][cx]; 

    if (cell == TypeCell.DOT) {
      _cells[cy][cx] = TypeCell.EMPTY;
      _nbDots--; 
    } else if (cell == TypeCell.SUPER_DOT) {
      _cells[cy][cx] = TypeCell.EMPTY;
      _nbSuperDots--;
    } else if (cell == TypeCell.BONUS) {
      _cells[cy][cx] = TypeCell.EMPTY;
    }
    return cell;
  }


  boolean hasNoDots() {
    return _nbDots == 0 && _nbSuperDots == 0; // si il n'y a plus aucune Pac-gomme alors ce sera vrai 
  }

  PVector getHeroStartCell() {
    return new PVector(_heroStartX, _heroStartY);
  }

  String getLevelTitle() {
    return _levelTitle;
  }

  int getNbCellsX() {
    return _nbCellsX;
  }

  int getNbCellsY() {
    return _nbCellsY;
  }

  // pour faire apparaître un bonus avec game
  void placeBonus(int cx, int cy) {
    if (!isInside(cx, cy)) return ;
    if (_cells[cy][cx] == TypeCell.EMPTY) {
      _cells[cy][cx] = TypeCell.BONUS;
    }
  }

  void clearBonus(int cx, int cy) {
    if (!isInside(cx, cy)) return;
    if (_cells[cy][cx] == TypeCell.BONUS) {
      _cells[cy][cx] = TypeCell.EMPTY;
    }
  }

  void drawIt() {
    rectMode(CENTER); 
    noStroke();

    for (int i = 0; i < _nbCellsY; i++) {
      for (int j = 0; j < _nbCellsX; j++) { 
        float cx = _position.x + j * _cellSize + _cellSize / 2.0;
        float cy = _position.y + i * _cellSize + _cellSize / 2.0;

        TypeCell cell = _cells[i][j]; 

        if (cell == TypeCell.WALL) {
          // mur bleu
          fill(0, 0, 200);
          rect(cx, cy, _cellSize, _cellSize);
        } else {
          // couloir noir
          fill(0);
          rect(cx, cy, _cellSize, _cellSize);
          // contenu de la case 
          if (cell == TypeCell.DOT) {
            fill(255, 255, 0); 
            ellipse(cx, cy, _cellSize * 0.2, _cellSize *0.2);
          } else if (cell == TypeCell.SUPER_DOT) {
            fill(255,255,255);
            ellipse(cx, cy, _cellSize *0.5, _cellSize * 0.5);
          } else if (cell == TypeCell.BONUS) {
            fill(255, 165, 0); 
            ellipse(cx, cy, _cellSize * 0.7, _cellSize * 0.7);
          }
        }
      }
    }
  }
}
