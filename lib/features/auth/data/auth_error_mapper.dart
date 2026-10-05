import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/app_failure.dart';

/// Converts Firebase errors into messages safe to show to users.
AppFailure mapAuthException(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return const AppFailure('That email address looks invalid.');
      case 'user-disabled':
        return const AppFailure('This account has been disabled.');
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return const AppFailure('Incorrect email or password.');
      case 'email-already-in-use':
        return const AppFailure('An account with this email already exists.');
      case 'weak-password':
        return const AppFailure('Password is too weak. Use 8+ characters.');
      case 'too-many-requests':
        return const AppFailure('Too many attempts. Try again later.');
      case 'network-request-failed':
        return const AppFailure(
          'No internet connection. Check your network and try again.',
        );
      case 'operation-not-allowed':
        return const AppFailure(
          'This sign-in method is not enabled in Firebase yet.',
        );
      case 'operation-not-supported-in-this-environment':
        return const AppFailure(
          'Google Sign-In is not supported on this platform yet.',
        );
      case 'account-exists-with-different-credential':
        return const AppFailure(
          'An account already exists with this email using another sign-in method.',
        );
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
      case 'canceled':
      case 'web-context-canceled':
      case 'web-context-cancelled':
        return const AppFailure('Sign-in cancelled.', isCancelled: true);
    }
    return AppFailure(error.message ?? 'Authentication failed. Try again.');
  }
  return const AppFailure('Something went wrong. Try again.');
}