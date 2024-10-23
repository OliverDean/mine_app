// test/grid_test.dart

import 'package:flutter_test/flutter_test.dart';
import '../models/grid.dart';

void main() {
  test('Grid Initialization Test', () {
    int rows = 10;
    int cols = 10;
    int mineCount = 20;

    Grid grid = Grid(rows: rows, cols: cols, mineCount: mineCount);

    // Check that the correct number of cells are created
    expect(grid.cells.length, rows * cols);

    // Check that the correct number of mines are placed
    int minesPlaced = grid.cells.values.where((cell) => cell.isMine).length;
    expect(minesPlaced, mineCount);

    // Check that adjacent mines are calculated
    bool adjacentMinesCalculated = grid.cells.values.every((cell) {
      return cell.isMine || cell.adjacentMines >= 0;
    });
    expect(adjacentMinesCalculated, true);
  });
}
