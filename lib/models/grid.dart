// models/grid.dart

import 'dart:math';
import 'dart:ui';
import '../utils/constants.dart';
import 'cell.dart';

class Grid {
  final int rows;
  final int cols;
  final int mineCount;
  final double cellSize;
  Map<String, Cell> cells = {};
  bool gameOver = false;
  bool gameWon = false;

  Grid({
    required this.rows,
    required this.cols,
    required this.mineCount,
    this.cellSize = Constants.defaultCellSize,
  }) {
    initializeGrid();
  }

  void initializeGrid() {
    generateCells();
    establishNeighbors();
    placeMines();
    calculateAdjacentMines();
  }

  void generateCells() {
    double a = cellSize; // Side length of the pentagon
    double h = a * sqrt(3); // Height based on equilateral triangle properties

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        int q = col - (row >> 1);
        int r = row;
        String key = '$q,$r';

        Cell cell = Cell(q: q, r: r);

        // Calculate center position
        double x = a * (q * 1.5);
        double y = h * r;

        // Offset every other row
        if (r % 2 != 0) {
          x += a * 0.75;
        }

        cell.center = Offset(x, y);
        cell.vertices = calculatePentagonVertices(cell.center, a, r % 2 == 0);
        cells[key] = cell;
      }
    }
  }

  List<Offset> calculatePentagonVertices(
      Offset center, double size, bool upright) {
    List<Offset> points = [];
    double angleOffset = upright ? 0 : pi;

    for (int i = 0; i < 5; i++) {
      double angle = (2 * pi / 5) * i + angleOffset - pi / 2;
      double x = center.dx + size * cos(angle);
      double y = center.dy + size * sin(angle);
      points.add(Offset(x, y));
    }
    return points;
  }

  void establishNeighbors() {
    List<List<int>> neighborOffsetsEvenRow = [
      [1, 0],   // Right
      [0, 1],   // Bottom Right
      [-1, 1],  // Bottom Left
      [-1, 0],  // Left
      [-1, -1], // Top Left
      [0, -1],  // Top Right
    ];

    List<List<int>> neighborOffsetsOddRow = [
      [1, 0],   // Right
      [1, 1],   // Bottom Right
      [0, 1],   // Bottom Left
      [-1, 0],  // Left
      [0, -1],  // Top Left
      [1, -1],  // Top Right
    ];

    cells.forEach((key, cell) {
      List<List<int>> neighborOffsets =
          (cell.r % 2 == 0) ? neighborOffsetsEvenRow : neighborOffsetsOddRow;

      for (var offset in neighborOffsets) {
        int neighborQ = cell.q + offset[0];
        int neighborR = cell.r + offset[1];
        String neighborKey = '$neighborQ,$neighborR';

        if (cells.containsKey(neighborKey)) {
          cell.neighbors.add(cells[neighborKey]!);
        }
      }
    });
  }

  void placeMines() {
    List<Cell> cellList = cells.values.toList();
    cellList.shuffle();
    for (int i = 0; i < mineCount; i++) {
      cellList[i].isMine = true;
    }
  }

  void calculateAdjacentMines() {
    cells.forEach((key, cell) {
      if (!cell.isMine) {
        int count = 0;
        for (Cell neighbor in cell.neighbors) {
          if (neighbor.isMine) {
            count++;
          }
        }
        cell.adjacentMines = count;
      }
    });
  }

  void revealCell(Cell cell) {
    if (cell.isRevealed || cell.isFlagged) return;

    cell.isRevealed = true;

    if (cell.isMine) {
      gameOver = true;
      // Additional game over handling
    } else if (cell.adjacentMines == 0) {
      // Recursively reveal neighbors
      for (Cell neighbor in cell.neighbors) {
        if (!neighbor.isRevealed) {
          revealCell(neighbor);
        }
      }
    }

    checkForWin();
  }

  void checkForWin() {
    bool allNonMineCellsRevealed = cells.values.every((cell) {
      return cell.isMine || cell.isRevealed;
    });

    if (allNonMineCellsRevealed) {
      gameWon = true;
      gameOver = true;
      // Additional game won handling
    }
  }
}
