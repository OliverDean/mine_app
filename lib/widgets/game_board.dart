// widgets/game_board.dart

import 'package:flutter/material.dart';
import '../models/grid.dart';
import 'cairo_painter.dart';
import '../models/cell.dart';
import '../providers/game_provider.dart';
import 'package:provider/provider.dart';

class GameBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return GestureDetector(
          onTapUp: (details) {
            handleTap(context, details.localPosition);
          },
          onLongPressStart: (details) {
            handleLongPress(context, details.localPosition);
          },
          child: CustomPaint(
            size: Size.infinite,
            painter: CairoPainter(grid: gameProvider.grid),
          ),
        );
      },
    );
  }

  void handleTap(BuildContext context, Offset position) {
    Cell? cell = getCellAtPosition(context, position);
    if (cell != null) {
      Provider.of<GameProvider>(context, listen: false).revealCell(cell);
      // Handle game over or win
    }
  }

  void handleLongPress(BuildContext context, Offset position) {
    Cell? cell = getCellAtPosition(context, position);
    if (cell != null) {
      Provider.of<GameProvider>(context, listen: false).toggleFlag(cell);
    }
  }

  Cell? getCellAtPosition(BuildContext context, Offset position) {
    Grid grid = Provider.of<GameProvider>(context, listen: false).grid;
    for (Cell cell in grid.cells.values) {
      Path pentagon = cell.pentagonPath ?? createPentagonPath(cell);
      if (pentagon.contains(position)) {
        return cell;
      }
    }
    return null;
  }

  Path createPentagonPath(Cell cell) {
    Path path = Path();
    path.moveTo(cell.vertices[0].dx, cell.vertices[0].dy);
    for (int i = 1; i < cell.vertices.length; i++) {
      path.lineTo(cell.vertices[i].dx, cell.vertices[i].dy);
    }
    path.close();
    cell.pentagonPath = path; // Cache the path
    return path;
  }
}
