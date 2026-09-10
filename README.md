# Pac-Man 2D — Java / Processing

Recréation fidèle du jeu d'arcade classique Pac-Man développée en **Java / Processing** dans le cadre de ma Licence 2 Mathématiques-Informatique.  
Le projet met en œuvre les principes fondamentaux de la **Programmation Orientée Objet (POO)**, une architecture modulaire et la gestion d'états en temps réel.

---

## 🎮 Fonctionnalités & Mécaniques de Jeu

- **Contrôles & Fluidité (Input Buffering) :** Mémorisation de la direction souhaitée (`_desiredDirection`) pour engager automatiquement les virages dès l'intersection suivante, garantissant un gameplay sans à-coups.
- **IA des Fantômes & Gestion des États :** 
  - Déplacements autonomes sur grille avec interdiction du demi-tour spontané.
  - Cycle de sortie temporisé depuis la maison centrale.
  - Mode apeuré (*Frightened*) avec réduction de vitesse et bascule visuelle.
- **Système de Score Rétro-Arcade :**
  - Collecte de pac-gommes et super pac-gommes.
  - Multiplicateur de score croissant sur les fantômes mangés (200, 400, 800, 1600 pts).
  - Apparition et disparition aléatoires de bonus temporaires (fruits).
  - Gain d'une vie supplémentaire au franchissement des 10 000 points.
- **Persistance des Données (I/O) :**
  - Chargement dynamique du niveau depuis une matrice textuelle (`level1.txt`).
  - Système de sauvegarde et reprise d'état en cours de partie (`save.txt`).
  - Gestion d'un tableau Top 5 des scores avec tri à l'insertion et saisie interactive du nom du joueur.
- **Interface & Contrôles :** Menu pause avec navigation clavier, écran de Game Over et gestion des raccourcis.

---

## 🏗️ Architecture Logicielle & Choix de Conception

Le programme suit une séparation stricte des responsabilités (POO) pour assurer modularité et lisibilité :

- `Board` : Modélisation et rendu de la grille matricielle (murs, couloirs, tunnels toriques, gommes et bonus).
- `Hero` : Entité Pac-Man (gestion vectorielle de position, normalisation cardinale, orientation des sprites).
- `Ghost` : Machine à états des fantômes (patrouille, vulnérabilité, retour en maison et respawn).
- `Game` : Chef d'orchestre du jeu (boucle principale, détection des conditions de fin, coordination des sous-systèmes).
- `Menu` : IHM superposée (reprise, redémarrage, sauvegarde, tableau des scores).
- `Constants` : Centralisation des règles métier (scores, vitesses, temporisations).

---

## 🛠️ Défis Techniques & Résolution de Problèmes

Extrait des problématiques traitées durant le cycle de développement et de débogage :

1. **Centralisation de la logique de collision :**  
   Pour éviter que plusieurs fantômes ne modifient l'état global du jeu dans la même frame (entraînant des pertes multiples de vies instantanées), la détection de collision et l'application des dégâts ont été centralisées au sein de `Game` avec une interruption ciblée du cycle de mise à jour dès le déclenchement d'un impact.

2. **Fiabilisation des transitions d'états :**  
   Résolution de désynchronisations où les fantômes conservaient un état vulnérable post-élimination via une réinitialisation explicite et déterministe lors du `respawn()`.

3. **Système de buffer de commande :**  
   Remplacement d'une lecture de touche brute par un système d'anticipation de trajectoire pour gommer la rigidité des déplacements sur grille discrète.

---

## 🚀 Installation & Exécution

### Prérequis
- [Processing IDE](https://processing.org/download) (version 3.x ou 4.x recommandée) avec le mode Java standard.

### Lancement & Fonctionnement
1. Cloner le dépôt :
   ```bash
   git clone https://github.com/keliandadou910-creator/pacman-processing.git
2. Ouvrir le fichier pacman.pde dans l'IDE Processing.
3. Vérifier la présence des dossiers img/ (sprites) et levels/ (level1.txt).
4. Cliquer sur le bouton Exécuter (Play).
5. Contrôles-Déplacements : Flèches directionnelles ou touches Z, Q, S, D
6. Menu Pause : Touche Échap (ESC)
7. Navigation Menu : Flèches Haut / Bas + Entrée
