import 'dart:math';
import 'dart:ui';
// import '../utils/constants.dart';
import 'cell.dart';

enum GameStatus { inProgress, lost, won }

class Grid {
  final int rows;
  final int cols;
  final int mineCount;
  final double cellSize;
  Map<String, Cell> cells = {};
  GameStatus gameStatus = GameStatus.inProgress;

  static const neighborOffsetsEvenRow = [
    [1, 0],   // Right
    [0, 1],   // Bottom Right
    [-1, 1],  // Bottom Left
    [-1, 0],  // Left
    [-1, -1], // Top Left
    [0, -1],  // Top Right
  ];

  static const neighborOffsetsOddRow = [
    [1, 0],   // Right
    [1, 1],   // Bottom Right
    [0, 1],   // Bottom Left
    [-1, 0],  // Left
    [0, -1],  // Top Left
    [1, -1],  // Top Right
  ];

  Grid({
    required this.rows,
    required this.cols,
    required this.mineCount,
    required this.cellSize,
  }) {
    assert(mineCount <= rows * cols, 'mineCount cannot exceed total number of cells');
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
    double h = a * sqrt(3); // Height for coordinate adjustments

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
        cell.pentagonPath = createPentagonPath(cell.vertices);
        cells[key] = cell;
      }
    }
  }

  Path createPentagonPath(List<Offset> vertices) {
    Path path = Path();
    path.moveTo(vertices[0].dx, vertices[0].dy);
    for (int i = 1; i < vertices.length; i++) {
      path.lineTo(vertices[i].dx, vertices[i].dy);
    }
    path.close();
    return path;
  }

  List<Offset> calculatePentagonVertices(Offset center, double size, bool upright) {
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
    for (var cell in cells.values) {
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
    }
  }

  void placeMines() {
    List<Cell> cellList = cells.values.toList();
    cellList.shuffle();
    for (int i = 0; i < mineCount; i++) {
      cellList[i].isMine = true;
    }
  }

  void calculateAdjacentMines() {
    for (var cell in cells.values) {
      if (!cell.isMine) {
        int count = 0;
        for (Cell neighbor in cell.neighbors) {
          if (neighbor.isMine) {
            count++;
          }
        }
        cell.adjacentMines = count;
      }
    }
  }

  void revealCell(Cell cell) {
    if (cell.isRevealed || cell.isFlagged || gameStatus != GameStatus.inProgress) return;

    cell.isRevealed = true;

    if (cell.isMine) {
      gameStatus = GameStatus.lost;
    } else if (cell.adjacentMines == 0) {
      // Recursively reveal neighbors
      for (Cell neighbor in cell.neighbors) {
        if (!neighbor.isRevealed && !neighbor.isMine) {
          revealCell(neighbor);
        }
      }
    }

    checkForWin();
  }

  void checkForWin() {
    if (gameStatus == GameStatus.lost) return;

    bool allNonMineCellsRevealed = cells.values.every((cell) {
      return cell.isMine || cell.isRevealed;
    });

    if (allNonMineCellsRevealed) {
      gameStatus = GameStatus.won;
    }
  }
}
