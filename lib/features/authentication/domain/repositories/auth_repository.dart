import '../entities/auth_user_entity.dart';

abstract interface class AuthRepository {
  Stream<AuthUserEntity?> get authStateChanges;

  AuthUserEntity? get currentUser;

  Future<AuthUserEntity> signInWithGoogle();

  Future<AuthUserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AuthUserEntity> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail({
    required String email,
  });

  Future<void> signOut();
}