import 'package:firebase_auth/firebase_auth.dart';
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  bool get isLoggedIn => currentUser != null;

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    String? username,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (username != null && username.trim().isNotEmpty) {
      await credential.user?.updateDisplayName(username.trim());
      // Reload so currentUser.displayName is up to date right away,
      // without the caller needing to reload manually.
      await credential.user?.reload();
    }

    return _firebaseAuth.currentUser;
  }

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
  String messageForError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Invalid email address';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'user-not-found':
          return 'No account found with this email';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect password';
        case 'email-already-in-use':
          return 'This email is already in use';
        case 'weak-password':
          return 'Password is too weak (minimum 6 characters)';
        case 'network-request-failed':
          return 'Please check your internet connection';
        default:
          return error.message ?? 'An unexpected error occurred';
      }
    }
    return error.toString();
  }
}