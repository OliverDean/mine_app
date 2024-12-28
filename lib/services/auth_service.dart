import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

/// A service class responsible for handling user authentication through Firebase.
///
/// Features:
/// 1. Real-time auth state changes via [authStateChanges].
/// 2. Retrieval of the current user via [currentUser].
/// 3. Email/Password sign-in, sign-up, and sign-out methods.
/// 4. Optionally, a method to re-authenticate a user or send verification emails.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// A stream of authentication state changes.
  /// Emits a [User?] whenever the sign-in state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Returns the currently signed-in [User], or null if no one is signed in.
  User? get currentUser => _auth.currentUser;

  /// Signs in a user with the given [email] and [password].
  /// 
  /// Returns the [User] upon successful sign-in.
  /// 
  /// Throws a [FirebaseAuthException] if sign-in fails (e.g., wrong password, user not found).
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      // You can log or re-throw the exception with a custom message.
      rethrow;
    }
  }

  /// Creates a new user account with the given [email] and [password].
  ///
  /// Returns the newly created [User].
  /// 
  /// Throws a [FirebaseAuthException] if account creation fails (e.g., weak password, email in use).
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      // Handle error codes such as email-already-in-use, invalid-email, weak-password, etc.
      rethrow;
    }
  }

  /// Sends a verification email to the currently signed-in user if the user is not null
  /// and their email is not yet verified.
  /// 
  /// Commonly called after [createUserWithEmailAndPassword].
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Signs out the currently signed-in user.
  ///
  /// Future completes once the sign-out process is finished.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// (Optional) Re-authenticates the current user with the provided [password].
  /// 
  /// Useful for sensitive operations like deleting an account or updating an email.
  /// Note: This example uses email/password only. If you have alternative providers,
  /// you’ll need to adjust accordingly (Google, Apple, etc.).
  Future<void> reauthenticateCurrentUser(String password) async {
    final user = currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user is currently signed in.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password.trim(),
    );
    await user.reauthenticateWithCredential(credential);
  }
}
