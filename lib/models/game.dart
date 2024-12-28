/// A model class representing a game lobby instance in the application.
/// 
/// [Game] objects are typically stored in or retrieved from a database (e.g. Firestore).
/// This class provides utility methods for serialization/deserialization, immutability,
/// and basic validations of relevant fields.
class Game {
  /// The unique identifier for this game (e.g., Firestore document ID).
  final String id;

  /// A short title or name for the game, e.g. 'Beginner Lobby'.
  final String title;

  /// Indicates if this game is open for players to join.
  final bool isOpen;

  /// The maximum number of players that can join this game.
  final int maxPlayers;

  /// The current number of players already in this game.
  final int currentPlayers;

  /// (Optional) Timestamp or DateTime representing when the game was created.
  /// If you store timestamps in Firestore, you might convert them to a Dart DateTime.
  final DateTime? createdAt;

  /// (Optional) Additional metadata or configuration for the game, if needed.
  /// For instance, you could store a description, a list of host user IDs, etc.
  // final String description;

  /// Creates a new immutable [Game] instance.
  ///
  /// If [maxPlayers] is less than [currentPlayers], it sets [maxPlayers] to [currentPlayers]
  /// for basic data integrity. You can add custom validations or throw an exception instead.
  Game({
    required this.id,
    required this.title,
    required this.isOpen,
    required this.maxPlayers,
    required this.currentPlayers,
    this.createdAt,
  }) : assert(maxPlayers >= 0 && currentPlayers >= 0);

  /// Creates a new [Game] from a [docId] and [data] map (commonly from Firestore).
  /// 
  /// Falls back to default values if fields are missing.
  /// 
  /// Example usage:
  /// ```dart
  /// final game = Game.fromMap(doc.id, doc.data());
  /// ```
  factory Game.fromMap(String docId, Map<String, dynamic> data) {
    // Convert Firestore Timestamp to DateTime if needed:
    DateTime? createdAt;
    if (data['createdAt'] != null) {
      // Adjust logic if your backend stores timestamps differently
      // For Firestore Timestamp:
      // createdAt = (data['createdAt'] as Timestamp).toDate();
      createdAt = DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now();
    }

    final int maxPlayers = data['maxPlayers'] is int ? data['maxPlayers'] : 0;
    final int currentPlayers = data['currentPlayers'] is int ? data['currentPlayers'] : 0;

    // Basic sanity check: Ensure maxPlayers >= currentPlayers
    final int validatedMaxPlayers = maxPlayers < currentPlayers ? currentPlayers : maxPlayers;

    return Game(
      id: docId,
      title: data['title'] as String? ?? 'Untitled Game',
      isOpen: data['isOpen'] as bool? ?? false,
      maxPlayers: validatedMaxPlayers,
      currentPlayers: currentPlayers,
      createdAt: createdAt,
    );
  }

  /// Serializes this [Game] into a map, suitable for sending to a database (e.g., Firestore).
  /// 
  /// Example usage:
  /// ```dart
  /// final gameMap = game.toMap();
  /// await firestore.collection('games').doc(game.id).set(gameMap);
  /// ```
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isOpen': isOpen,
      'maxPlayers': maxPlayers,
      'currentPlayers': currentPlayers,
      // If you're using Firestore Timestamp, convert DateTime accordingly:
      // 'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Returns a new [Game] object with updated fields, while preserving immutable design.
  ///
  /// Example usage:
  /// ```dart
  /// final updatedGame = game.copyWith(currentPlayers: game.currentPlayers + 1);
  /// ```
  Game copyWith({
    String? title,
    bool? isOpen,
    int? maxPlayers,
    int? currentPlayers,
    DateTime? createdAt,
  }) {
    // Basic sanity check for players
    final int newCurrentPlayers = currentPlayers ?? this.currentPlayers;
    final int newMaxPlayers = maxPlayers ?? this.maxPlayers;
    final int validatedMaxPlayers = newMaxPlayers < newCurrentPlayers
        ? newCurrentPlayers
        : newMaxPlayers;

    return Game(
      id: id,
      title: title ?? this.title,
      isOpen: isOpen ?? this.isOpen,
      maxPlayers: validatedMaxPlayers,
      currentPlayers: newCurrentPlayers,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// A convenience getter to check if the game is full.
  bool get isFull => currentPlayers >= maxPlayers;

  /// A convenience getter to check if the game has started or is in the waiting phase.
  /// Extend this logic according to your specific start rules.
  bool get canJoin => isOpen && !isFull;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Game) return false;

    return other.id == id &&
        other.title == title &&
        other.isOpen == isOpen &&
        other.maxPlayers == maxPlayers &&
        other.currentPlayers == currentPlayers &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        isOpen.hashCode ^
        maxPlayers.hashCode ^
        currentPlayers.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'Game(id: $id, title: $title, isOpen: $isOpen, '
        'maxPlayers: $maxPlayers, currentPlayers: $currentPlayers, '
        'createdAt: $createdAt)';
  }
}
