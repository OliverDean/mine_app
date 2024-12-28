import 'package:flutter/material.dart';
import '../models/grid.dart';
import '../models/cell.dart';

class GameProvider with ChangeNotifier {
  late Grid grid;
  int flagsPlaced = 0;

  GameProvider({
    required int rows,
    required int cols,
    required int mineCount,
    required double cellSize,
  }) {
    grid = Grid(rows: rows, cols: cols, mineCount: mineCount, cellSize: cellSize);
  }

  void revealCell(Cell cell) {
    if (grid.gameStatus != GameStatus.inProgress) return;
    grid.revealCell(cell);
    notifyListeners();
  }

  void toggleFlag(Cell cell) {
    if (grid.gameStatus != GameStatus.inProgress || cell.isRevealed) return;

    if (cell.isFlagged) {
      cell.isFlagged = false;
      flagsPlaced--;
    } else if (flagsPlaced < grid.mineCount) {
      cell.isFlagged = true;
      flagsPlaced++;
    }
    notifyListeners();
  }

  void resetGame(int rows, int cols, int mineCount, double cellSize) {
    grid = Grid(rows: rows, cols: cols, mineCount: mineCount, cellSize: cellSize);
    flagsPlaced = 0;
    notifyListeners();
  }

  int get remainingMines => grid.mineCount - flagsPlaced;

  GameStatus get status => grid.gameStatus;
}
