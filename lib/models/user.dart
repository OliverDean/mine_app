/// A model representing a user within the game.
class User {
  /// The unique identifier of the user (often from Firebase Auth).
  final String uid;

  /// The display name or username of the user.
  final String username;

  /// The user's cumulative score.
  final int score;

  /// The user's current level or rank in the game.
  final int level;

  /// The total number of games the user has played.
  final int gamesPlayed;

  /// The total number of games the user has won.
  final int gamesWon;

  /// A URL pointing to the user's profile image.
  final String? profileImageUrl;

  /// A list of achievements the user has earned.
  final List<String> achievements;

  User({
    required this.uid,
    required this.username,
    this.score = 0,
    this.level = 1,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.profileImageUrl,
    this.achievements = const [],
  });

  /// Creates a new [User] from a map of key-value pairs (e.g. data from Firestore).
  factory User.fromMap(Map<String, dynamic> data) {
    // Validate required fields
    if (data['uid'] == null || data['username'] == null) {
      throw ArgumentError('User map is missing "uid" or "username".');
    }

    return User(
      uid: data['uid'],
      username: data['username'],
      score: data['score'] is int ? data['score'] : 0,
      level: data['level'] is int ? data['level'] : 1,
      gamesPlayed: data['gamesPlayed'] is int ? data['gamesPlayed'] : 0,
      gamesWon: data['gamesWon'] is int ? data['gamesWon'] : 0,
      profileImageUrl: data['profileImageUrl'] as String?,
      achievements: data['achievements'] is List
          ? List<String>.from(data['achievements'])
          : [],
    );
  }

  /// Converts the [User] object into a map suitable for storage (e.g., Firestore).
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'score': score,
      'level': level,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'profileImageUrl': profileImageUrl,
      'achievements': achievements,
    };
  }

  /// Creates a new [User] by copying the existing instance and overriding specified fields.
  User copyWith({
    String? username,
    int? score,
    int? level,
    int? gamesPlayed,
    int? gamesWon,
    String? profileImageUrl,
    List<String>? achievements,
  }) {
    return User(
      uid: uid,
      username: username ?? this.username,
      score: score ?? this.score,
      level: level ?? this.level,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      achievements: achievements ?? this.achievements,
    );
  }

  /// Increments the user's score by [amount].
  User addScore(int amount) {
    return copyWith(score: score + amount);
  }

  /// Increments the number of games played by one.
  User incrementGamesPlayed() {
    return copyWith(gamesPlayed: gamesPlayed + 1);
  }

  /// Increments the number of games won by one.
  User incrementGamesWon() {
    return copyWith(gamesWon: gamesWon + 1);
  }

  /// Adds a new achievement to the user's list of achievements if not already earned.
  User addAchievement(String achievement) {
    if (!achievements.contains(achievement)) {
      final updatedAchievements = List<String>.from(achievements)..add(achievement);
      return copyWith(achievements: updatedAchievements);
    }
    return this;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.uid == uid &&
        other.username == username &&
        other.score == score &&
        other.level == level &&
        other.gamesPlayed == gamesPlayed &&
        other.gamesWon == gamesWon &&
        other.profileImageUrl == profileImageUrl &&
        _listEquals(other.achievements, achievements);
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        username.hashCode ^
        score.hashCode ^
        level.hashCode ^
        gamesPlayed.hashCode ^
        gamesWon.hashCode ^
        profileImageUrl.hashCode ^
        achievements.hashCode;
  }

  @override
  String toString() {
    return 'User(uid: $uid, username: $username, score: $score, level: $level, gamesPlayed: $gamesPlayed, gamesWon: $gamesWon, profileImageUrl: $profileImageUrl, achievements: $achievements)';
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
