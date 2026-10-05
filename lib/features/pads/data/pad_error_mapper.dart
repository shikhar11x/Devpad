import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_failure.dart';

/// Converts Firestore errors into messages safe to show to users.
AppFailure mapPadException(Object error) {
  if (error is AppFailure) return error;
  if (error is TimeoutException) {
    return const AppFailure(
      'This is taking too long. Check your connection and try again.',
    );
  }
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return const AppFailure("You don't have permission to do that.");
      case 'unauthenticated':
        return const AppFailure('Please sign in again.');
      case 'unavailable':
        return const AppFailure(
          'No connection to the server. Check your network and try again.',
        );
      case 'not-found':
        return const AppFailure('That Pad no longer exists.');
    }
    return AppFailure(error.message ?? 'Something went wrong. Try again.');
  }
  return const AppFailure('Something went wrong. Try again.');
}