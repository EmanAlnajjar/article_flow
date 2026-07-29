import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

class WatchAuthStateUseCase {
  final AuthRepository _repository;

  const WatchAuthStateUseCase(this._repository);

  Stream<AuthUserEntity?> call() {
    return _repository.authStateChanges;
  }
}

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  const GetCurrentUserUseCase(this._repository);

  AuthUserEntity? call() {
    return _repository.currentUser;
  }
}

class SignInWithGoogleUseCase {
  final AuthRepository _repository;

  const SignInWithGoogleUseCase(this._repository);

  Future<AuthUserEntity> call() {
    return _repository.signInWithGoogle();
  }
}

class SignInWithEmailAndPasswordUseCase {
  final AuthRepository _repository;

  const SignInWithEmailAndPasswordUseCase(
      this._repository,
      );

  Future<AuthUserEntity> call({
    required String email,
    required String password,
  }) {
    return _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}

class CreateUserWithEmailAndPasswordUseCase {
  final AuthRepository _repository;

  const CreateUserWithEmailAndPasswordUseCase(
      this._repository,
      );

  Future<AuthUserEntity> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.createUserWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
    );
  }
}

class SendPasswordResetEmailUseCase {
  final AuthRepository _repository;

  const SendPasswordResetEmailUseCase(
      this._repository,
      );

  Future<void> call({
    required String email,
  }) {
    return _repository.sendPasswordResetEmail(
      email: email,
    );
  }
}

class SignOutUseCase {
  final AuthRepository _repository;

  const SignOutUseCase(this._repository);

  Future<void> call() {
    return _repository.signOut();
  }
}