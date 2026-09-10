/*
Squelette réalisé par mon professeur :

final int CELL_SIZE = 50; 

final int SCORE_DOT = 10;
final int SCORE_SUPER_DOT = 50;
*/

 

import java.util.ArrayList; 
 
// Ce seront les constantes globales du jeu

final int CELL_SIZE = 30; 

final int SCORE_DOT = 10;    
final int SCORE_SUPER_DOT = 50;    
final int SCORE_BONUS = 500;   
final int SCORE_EAT_GHOST = 200;   

final int INITIAL_LIVES = 2;     
final int LIFE_THRESHOLD = 10000;   

final float HERO_SPEED = 3.0; 

final int FRIGHTENED_DURATION =600; // c'est la durée du mode super en frames (10s)

final int BONUS_APPEAR_MIN = 600; 
final int BONUS_APPEAR_MAX = 1200;  

final int BONUS_LIFETIME = 600;

final int GHOST_RELEASE_INTERVAL = 180;

final int[] GHOST_EAT_SCORES = {200, 400, 800, 1600};
 
PImage SPRITES;    
PImage HERO_IMG; 
PImage GHOST_IMG; 

/* pac-man -> un carré 40x40 autour de lui */
final int HERO_SX = 848;
final int HERO_SY = 448;
final int HERO_SW = 40;
final int HERO_SH = 40;  

/* fantomes -> un carré 40x40 autour d'eux */
final int GHOST_SX = 0;
final int GHOST_SY = 0;
final int GHOST_SW = 40; 
final int GHOST_SH = 40;
