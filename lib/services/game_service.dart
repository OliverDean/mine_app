import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game.dart'; // Import your Game model here

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches available games from Firestore.
  /// "Available" might mean isOpen == true and currentPlayers < maxPlayers.
  /// Adjust the query based on your game logic.
  Future<List<Game>> getAvailableGames() async {
    try {
      final query = await _firestore
          .collection('games')
          .where('isOpen', isEqualTo: true)
          .where('currentPlayers', isLessThan: FieldValue.increment(999999999)) // example large number
          .get();

      return query.docs.map((doc) => Game.fromMap(doc.id, doc.data())).toList();
    } catch (e) {
      // Log and handle error gracefully.
      // For cyber security, do not reveal internal details to the user.
      // A logging service or Crashlytics can capture 'e' for dev analysis.
      rethrow; // Up to you whether to rethrow or return empty list
    }
  }

  /// Joins a game by its [gameId]. This involves:
  /// - Validating input.
  /// - Checking if the game still has space (read currentPlayers & maxPlayers).
  /// - Incrementing currentPlayers in a safe, transactional manner.
  ///
  /// Ensure Firestore Security Rules:
  /// - Auth required
  /// - Only allow increment if currentPlayers < maxPlayers
  /// - Possibly store user ID in the game's player list
  Future<void> joinGame(String gameId) async {
    if (gameId.isEmpty) {
      throw ArgumentError('Game ID cannot be empty.');
    }

    try {
      await _firestore.runTransaction((transaction) async {
        final gameRef = _firestore.collection('games').doc(gameId);
        final snapshot = await transaction.get(gameRef);

        if (!snapshot.exists) {
          throw StateError('Game does not exist.');
        }

        final data = snapshot.data()!;
        final currentPlayers = data['currentPlayers'] as int? ?? 0;
        final maxPlayers = data['maxPlayers'] as int? ?? 0;
        final isOpen = data['isOpen'] as bool? ?? false;

        if (!isOpen) {
          throw StateError('Game is not open for joining.');
        }

        if (currentPlayers >= maxPlayers) {
          throw StateError('Game is already full.');
        }

        // If all checks pass, increment currentPlayers.
        transaction.update(gameRef, {
          'currentPlayers': currentPlayers + 1,
        });

        // Optional: Add the user's ID to a players list field for the game.
        // final user = FirebaseAuth.instance.currentUser;
        // if (user != null) {
        //   transaction.update(gameRef, {
        //     'players': FieldValue.arrayUnion([user.uid])
        //   });
        // }
      });
    } on FirebaseException catch (firebaseError) {
      // Handle Firestore-specific errors.
      // Log firebaseError.code and firebaseError.message securely.
      rethrow; 
    } catch (e) {
      // Handle other exceptions (e.g., StateError).
      rethrow; 
    }
  }
}
