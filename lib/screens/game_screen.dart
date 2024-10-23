// screens/game_screen.dart

import 'package:flutter/material.dart';
import '../widgets/game_board.dart';
import '../providers/game_provider.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cairo Minesweeper'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              gameProvider.resetGame(10, 10, 20);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GameBoard(),
          Positioned(
            top: 10,
            left: 10,
            child: buildStatusPanel(context),
          ),
          if (gameProvider.grid.gameOver) buildGameOverDialog(context),
          if (gameProvider.grid.gameWon) buildGameWonDialog(context),
        ],
      ),
    );
  }

  Widget buildStatusPanel(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.black.withOpacity(0.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mines: ${gameProvider.remainingMines}',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(width: 20),
          Text(
            'Flags: ${gameProvider.flagsPlaced}',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget buildGameOverDialog(BuildContext context) {
    return Center(
      child: AlertDialog(
        title: Text('Game Over'),
        content: Text('You hit a mine!'),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<GameProvider>(context, listen: false)
                  .resetGame(10, 10, 20);
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }

  Widget buildGameWonDialog(BuildContext context) {
    return Center(
      child: AlertDialog(
        title: Text('Congratulations!'),
        content: Text('You won the game!'),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<GameProvider>(context, listen: false)
                  .resetGame(10, 10, 20);
            },
            child: Text('Play Again'),
          ),
        ],
      ),
    );
  }
}
