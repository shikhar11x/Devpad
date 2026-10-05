import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.uid,
    super.email,
    super.displayName,
    super.photoUrl,
  });

  factory AuthUserModel.fromFirebase(User user) => AuthUserModel(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
}