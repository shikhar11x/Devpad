import '../entities/auth_user.dart';

/// Contract the UI depends on. Swap the implementation to change backend.
/// Methods throw `AppFailure` with a user-presentable message.
abstract interface class AuthRepository {
  Stream<AuthUser?> authStateChanges();

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signInWithGoogle();

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();
}