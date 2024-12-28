import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/grid.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  static const int defaultRows = 10;
  static const int defaultCols = 10;
  static const int defaultMines = 20;

  @override
  Widget build(BuildContext context) {
    // Calculate cellSize here and pass it into the provider
    double screenWidth = MediaQuery.of(context).size.width;
    double cellSize = screenWidth / (defaultCols * 1.5);

    return ChangeNotifierProvider(
      create: (_) => GameProvider(
        rows: defaultRows,
        cols: defaultCols,
        mineCount: defaultMines,
        cellSize: cellSize,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cairo Minesweeper'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                Provider.of<GameProvider>(context, listen: false).resetGame(
                  defaultRows,
                  defaultCols,
                  defaultMines,
                  cellSize,
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            const GameBoard(),
            Positioned(
              top: 10,
              left: 10,
              child: buildStatusPanel(context),
            ),
            Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                if (gameProvider.status == GameStatus.lost) {
                  return buildGameOverDialog(context);
                } else if (gameProvider.status == GameStatus.won) {
                  return buildGameWonDialog(context);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatusPanel(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black.withValues(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Mines: ${gameProvider.remainingMines}',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(width: 20),
          Text(
            'Flags: ${gameProvider.flagsPlaced}',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget buildGameOverDialog(BuildContext context) {
    return Center(
      child: AlertDialog(
        title: const Text('Game Over'),
        content: const Text('You hit a mine!'),
        actions: [
          TextButton(
            onPressed: () {
              final gameProvider = Provider.of<GameProvider>(context, listen: false);
              double screenWidth = MediaQuery.of(context).size.width;
              double cellSize = screenWidth / (10 * 1.5);
              gameProvider.resetGame(10, 10, 20, cellSize);
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  Widget buildGameWonDialog(BuildContext context) {
    return Center(
      child: AlertDialog(
        title: const Text('Congratulations!'),
        content: const Text('You won the game!'),
        actions: [
          TextButton(
            onPressed: () {
              final gameProvider = Provider.of<GameProvider>(context, listen: false);
              double screenWidth = MediaQuery.of(context).size.width;
              double cellSize = screenWidth / (10 * 1.5);
              gameProvider.resetGame(10, 10, 20, cellSize);
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
}
