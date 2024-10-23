// providers/game_provider.dart

import 'package:flutter/material.dart';
import '../models/grid.dart';
import '../models/cell.dart';
import '../utils/constants.dart';

class GameProvider with ChangeNotifier {
  late Grid grid;
  int flagsPlaced = 0;

  GameProvider({required int rows, required int cols, required int mineCount, required BuildContext context}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cellSize = screenWidth / (cols * 1.5);
    grid = Grid(rows: rows, cols: cols, mineCount: mineCount, cellSize: cellSize);
    }

  void revealCell(Cell cell) {
    if (grid.gameOver || grid.gameWon) return;

    grid.revealCell(cell);
    notifyListeners();

    if (grid.gameOver) {
      // Handle game over logic
    } else if (grid.gameWon) {
      // Handle game won logic
    }
  }

  void toggleFlag(Cell cell) {
    if (grid.gameOver || grid.gameWon || cell.isRevealed) return;

    if (cell.isFlagged) {
      cell.isFlagged = false;
      flagsPlaced--;
    } else if (flagsPlaced < grid.mineCount) {
      cell.isFlagged = true;
      flagsPlaced++;
    }
    notifyListeners();
  }

  void resetGame(int rows, int cols, int mineCount) {
    grid = Grid(rows: rows, cols: cols, mineCount: mineCount);
    flagsPlaced = 0;
    notifyListeners();
  }

  int get remainingMines => grid.mineCount - flagsPlaced;
}
