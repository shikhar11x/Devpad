import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_providers.dart';

enum AuthAction { email, google, reset, signOut }

@immutable
class AuthActionState {
  const AuthActionState({this.action, this.errorMessage});

  /// The action currently running, or null when idle.
  final AuthAction? action;
  final String? errorMessage;

  bool get isLoading => action != null;
}

class AuthController extends Notifier<AuthActionState> {
  @override
  AuthActionState build() => const AuthActionState();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  void reset() => state = const AuthActionState();

  Future<bool> _run(AuthAction action, Future<void> Function() task) async {
    state = AuthActionState(action: action);
    try {
      await task();
      state = const AuthActionState();
      return true;
    } on AppFailure catch (f) {
      state = f.isCancelled
          ? const AuthActionState()
          : AuthActionState(errorMessage: f.message);
      return false;
    } catch (_) {
      state = const AuthActionState(
        errorMessage: 'Something went wrong. Try again.',
      );
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) =>
      _run(
        AuthAction.email,
        () => _repo.signInWithEmail(email: email, password: password),
      );

  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) =>
      _run(
        AuthAction.email,
        () => _repo.signUpWithEmail(
          email: email,
          password: password,
          displayName: displayName,
        ),
      );

  Future<bool> signInWithGoogle() =>
      _run(AuthAction.google, _repo.signInWithGoogle);

  Future<bool> sendPasswordReset(String email) =>
      _run(AuthAction.reset, () => _repo.sendPasswordReset(email));

  Future<bool> signOut() => _run(AuthAction.signOut, _repo.signOut);
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthActionState>(AuthController.new);