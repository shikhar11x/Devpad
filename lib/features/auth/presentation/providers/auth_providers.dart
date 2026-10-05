import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

// Composition root for the auth feature: the only place that wires
// the Firebase implementation to the repository contract.
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final authDataSourceProvider = Provider<FirebaseAuthDataSource>(
  (ref) => FirebaseAuthDataSource(ref.watch(firebaseAuthProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authDataSourceProvider)),
);

/// Emits the signed-in user or null. Firebase restores the session on
/// startup, so this also provides auth persistence.
final authStateProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

extension AuthStateX on AsyncValue<AuthUser?> {
  AuthUser? get userOrNull => maybeWhen(data: (u) => u, orElse: () => null);
}

/// Convenience: current user or null (also null while loading).
final currentUserProvider = Provider<AuthUser?>(
  (ref) => ref.watch(authStateProvider).userOrNull,
);