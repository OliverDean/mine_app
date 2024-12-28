// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// A stream of authentication state changes.
  /// This will emit a [User] object whenever the sign-in state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Returns the currently signed-in [User], or null if no one is signed in.
  User? get currentUser => _auth.currentUser;

  /// Signs in a user with the given [email] and [password].
  /// Throws a [FirebaseAuthException] if sign-in fails.
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  /// Creates a new user account with the given [email] and [password].
  /// Returns the newly created [User].
  /// Throws a [FirebaseAuthException] if account creation fails.
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  /// Signs out the currently signed-in user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
