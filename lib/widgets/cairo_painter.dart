import 'package:flutter/material.dart';
import '../models/grid.dart';
import '../models/cell.dart';

class CairoPainter extends CustomPainter {
  final Grid grid;
  final Animation<double>? animation;

  CairoPainter({required this.grid, this.animation})
      : super(repaint: animation);

  static const revealedMineColor = Colors.red;
  static const revealedSafeColor = Colors.grey;
  static const unrevealedColor = Colors.blue;
  static const flaggedColor = Colors.orange;
  static const textColor = Colors.black;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    for (var cell in grid.cells.values) {
      paint.color = getCellColor(cell);
      Path pentagon = cell.pentagonPath!;
      canvas.drawPath(pentagon, paint);

      if (cell.isRevealed && cell.adjacentMines > 0 && !cell.isMine) {
        drawText(canvas, cell.center, cell.adjacentMines.toString());
      }

      if (cell.isFlagged && !cell.isRevealed) {
        drawFlag(canvas, cell.center);
      }
    }
  }

  Color getCellColor(Cell cell) {
    if (cell.isRevealed) {
      return cell.isMine ? revealedMineColor : revealedSafeColor.shade300;
    } else {
      return cell.isFlagged ? flaggedColor : unrevealedColor;
    }
  }

  void drawText(Canvas canvas, Offset position, String text) {
    TextSpan span = TextSpan(
      style: const TextStyle(color: textColor, fontSize: 14.0),
      text: text,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(position.dx - tp.width / 2, position.dy - tp.height / 2),
    );
  }

  void drawFlag(Canvas canvas, Offset position) {
    Paint flagPaint = Paint()..color = Colors.red;
    Path flagPath = Path();
    flagPath.moveTo(position.dx, position.dy - 10);
    flagPath.lineTo(position.dx + 10, position.dy);
    flagPath.lineTo(position.dx, position.dy + 10);
    flagPath.close();
    canvas.drawPath(flagPath, flagPaint);
  }

  @override
  bool shouldRepaint(CairoPainter oldDelegate) {
    return oldDelegate.grid != grid || oldDelegate.animation != animation;
  }
}
