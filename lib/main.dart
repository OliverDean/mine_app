// main.dart

import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import 'providers/game_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(CairoMinesweeperApp());
}

class CairoMinesweeperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cairo Minesweeper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (_) => GameProvider(rows: 10, cols: 10, mineCount: 20),
        child: GameScreen(),
      ),
    );
  }
}
