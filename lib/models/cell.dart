// models/cell.dart

import 'dart:ui';

class Cell {
  final int q; // Axial coordinate
  final int r; // Axial coordinate
  late Offset center; // Center position for rendering
  bool isMine;
  bool isRevealed;
  bool isFlagged;
  int adjacentMines;
  late List<Offset> vertices; // For rendering the pentagon
  List<Cell> neighbors = []; // Neighboring cells
  Path? pentagonPath; // Cached path for rendering and hit-testing

  Cell({
    required this.q,
    required this.r,
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.adjacentMines = 0,
  });
}
