class User {
  final String uid;
  final String username;

  User({required this.uid, required this.username});

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      uid: data['uid'],
      username: data['username'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
    };
  }
}
