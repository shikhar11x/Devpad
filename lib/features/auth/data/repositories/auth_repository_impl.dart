import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth_error_mapper.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../models/auth_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final FirebaseAuthDataSource _dataSource;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw mapAuthException(e);
    }
  }

  @override
  Stream<AuthUser?> authStateChanges() => _dataSource
      .authStateChanges()
      .map((u) => u == null ? null : AuthUserModel.fromFirebase(u));

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _guard(() => _dataSource.signInWithEmail(email.trim(), password));

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) =>
      _guard(
        () => _dataSource.signUpWithEmail(email.trim(), password, displayName),
      );

  @override
  Future<void> signInWithGoogle() => _guard(_dataSource.signInWithGoogle);

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _dataSource.sendPasswordReset(email.trim()));

  @override
  Future<void> signOut() => _guard(_dataSource.signOut);
}