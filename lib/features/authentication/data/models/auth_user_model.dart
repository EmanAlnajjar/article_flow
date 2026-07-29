import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user_entity.dart';

class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.id,
    required super.name,
    required super.email,
    super.photoUrl,
  });

  factory AuthUserModel.fromFirebaseUser(User user) {
    return AuthUserModel(
      id: user.uid,
      name:
          user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : 'ArticleFlow Reader',
      email: user.email ?? '',
      photoUrl: user.photoURL,
    );
  }
}
