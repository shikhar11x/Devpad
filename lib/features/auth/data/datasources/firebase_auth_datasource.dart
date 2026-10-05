import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// The only class that talks to FirebaseAuth directly.
class FirebaseAuthDataSource {
  FirebaseAuthDataSource(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String? displayName,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) {
      await cred.user?.updateDisplayName(name);
      await cred.user?.reload();
    }
  }

  Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    if (kIsWeb) {
      await _auth.signInWithPopup(provider);
      return;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        await _auth.signInWithProvider(provider);
      default:
        throw FirebaseAuthException(
          code: 'operation-not-supported-in-this-environment',
        );
    }
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> signOut() => _auth.signOut();
}