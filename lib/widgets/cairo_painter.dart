// widgets/cairo_painter.dart

import 'package:flutter/material.dart';
import '../models/grid.dart';
import '../models/cell.dart';

class CairoPainter extends CustomPainter {
  final Grid grid;
  final Animation<double>? animation;

  CairoPainter({required this.grid, this.animation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    grid.cells.forEach((key, cell) {
      paint.color = getCellColor(cell);

      // Use cached pentagon path or create one
      Path pentagon = cell.pentagonPath ?? createPentagonPath(cell);
      canvas.drawPath(pentagon, paint);

      if (cell.isRevealed && cell.adjacentMines > 0 && !cell.isMine) {
        // Draw adjacent mine count
        drawText(
          canvas,
          cell.center,
          cell.adjacentMines.toString(),
        );
      }

      if (cell.isFlagged) {
        // Draw flag icon or marker
        drawFlag(canvas, cell.center);
      }
    });
  }

  Color getCellColor(Cell cell) {
    if (cell.isRevealed) {
      if (cell.isMine) {
        return Colors.red;
      } else {
        return Colors.grey.shade300;
      }
    } else {
      return cell.isFlagged ? Colors.orange : Colors.blue;
    }
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

  void drawText(Canvas canvas, Offset position, String text) {
    TextSpan span = TextSpan(
      style: TextStyle(color: Colors.black, fontSize: 14.0),
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
