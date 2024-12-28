import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// import '../models/user.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final AuthService authService = AuthService(); // Example: adjust as needed

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser; // Assumes AuthService has currentUser

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cairo Minesweeper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              Navigator.of(context).pushReplacementNamed('/login'); 
              // Adjust the route as needed for your login flow
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${user?.displayName ?? 'Player'}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/game');
                // Navigate to the game screen
              },
              child: const Text('Start New Game', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/join');
                // Navigate to a screen where user can join a game (e.g., enter a code)
              },
              child: const Text('Join a Game', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
