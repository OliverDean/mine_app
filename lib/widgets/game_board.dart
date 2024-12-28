import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../providers/game_provider.dart';
import 'cairo_painter.dart';
import 'package:provider/provider.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({Key? key}) : super(key: key);

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
    }
  }

  void handleLongPress(BuildContext context, Offset position) {
    Cell? cell = getCellAtPosition(context, position);
    if (cell != null) {
      Provider.of<GameProvider>(context, listen: false).toggleFlag(cell);
    }
  }

  Cell? getCellAtPosition(BuildContext context, Offset position) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final grid = gameProvider.grid;

    for (var cell in grid.cells.values) {
      // pentagonPath is guaranteed to be set in generateCells
      if (cell.pentagonPath!.contains(position)) {
        return cell;
      }
    }
    return null;
  }
}
