# Pac-Man 2D — Java / Processing

A faithful recreation of the classic arcade game Pac-Man developed in **Java / Processing** as part of my 2nd-year Bachelor's degree in Mathematics and Computer Science.  
The project implements fundamental **Object-Oriented Programming (OOP)** principles, modular software architecture, and real-time state management.

---

## 🎮 Features & Gameplay Mechanics

- **Input Buffering & Smooth Controls:** Direction queuing via `_desiredDirection` to automatically take turns at the next valid intersection, ensuring responsive and fluid grid navigation.
- **Ghost AI & State Machines:**
  - Autonomous tile-based pathing with reverse-direction restrictions.
  - Timed exit cycles from the central ghost house.
  - *Frightened* mode featuring dynamic speed reduction and sprite switching.
- **Classic Arcade Scoring System:**
  - Dot and energizer (power pellet) collection.
  - Progressive ghost multiplier mechanics (200, 400, 800, 1600 pts).
  - Timed random bonus items (fruit spawns).
  - Extra life awarded at the 10,000-point threshold.
- **Data Persistence (File I/O):**
  - Dynamic level parsing from text-based matrix files (`level1.txt`).
  - In-game save and resume system via flat-file persistence (`save.txt`).
  - Top 5 leaderboard using insertion sort with interactive player name input.
- **UI & Flow:** Pause menu with keyboard navigation, Game Over screen, and custom key bindings.

---

## 🏗️ Software Architecture & Design Patterns

The project enforces a strict Separation of Concerns (SoC) using OOP to ensure code maintainability and readability:

- `Board`: Models and renders the tile grid matrix (walls, corridors, wrapping tunnels, pellets, and bonuses).
- `Hero`: Encapsulates Pac-Man's state, directional vector handling, and sprite orientation.
- `Ghost`: Finite state machine governing ghost behaviors (patrolling, vulnerability, house return, and respawning).
- `Game`: Core game loop coordinator (tick updates, win/loss evaluation, and subsystem synchronization).
- `Menu`: Layered UI state overlay (resume, restart, save game, high scores).
- `Constants`: Single source of truth for game balancing rules (scores, speeds, tick delays).

---

## 🛠️ Technical Challenges & Engineering Solutions

Key engineering problems tackled during the development and debugging lifecycle:

1. **Atomic Collision Handling:**  
   To prevent race conditions where multiple ghosts triggered damage within the same frame (causing unintended multiple life losses), collision detection and life management were centralized inside `Game`, immediately interrupting the tick cycle on fatal impacts.

2. **Deterministic State Transitions:**  
   Eliminated edge cases where ghosts remained vulnerable post-elimination by enforcing explicit and deterministic state resets inside `respawn()`.

3. **Input Buffer Implementation:**  
   Replaced raw polling with an intended-direction buffer, eliminating input dropped frames and smoothing discrete grid-based turns.

---

## 🚀 Getting Started

### Prerequisites
- [Processing IDE](https://processing.org/download) (version 3.x or 4.x) with the default Java mode enabled.

### Installation & Run
1. Clone the repository:
   ```bash
   git clone [https://github.com/keliandadou910-creator/pacman-java-processing.git](https://github.com/keliandadou910-creator/pacman-java-processing.git)
