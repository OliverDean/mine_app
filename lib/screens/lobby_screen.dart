import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../models/game.dart'; // Recommended separate file for the Game model

class LobbyScreen extends StatelessWidget {
  final GameService gameService = GameService();

  LobbyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Lobby'),
      ),
      body: FutureBuilder<List<Game>>(
        // gameService.getAvailableGames() returns Future<List<Game>> (non-null)
        future: gameService.getAvailableGames(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state: show a spinner
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Error state: show an error message
            return Center(
              child: Text('Error loading games: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // No games available
            return const Center(
              child: Text('No available games at the moment.'),
            );
          }

          // We have a list of games
          final games = snapshot.data!;

          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return ListTile(
                title: Text(game.title),
                subtitle: Text('Game ID: ${game.id}'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    try {
                      await gameService.joinGame(game.id);
                      // After joining, navigate to the game screen with the game data
                      Navigator.of(context).pushNamed('/game', arguments: game);
                    } catch (e) {
                      // Failed to join game: show a SnackBar or handle error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to join game: $e')),
                      );
                    }
                  },
                  child: const Text('Join'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
