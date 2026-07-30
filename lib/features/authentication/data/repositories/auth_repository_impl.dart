import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Stream<AuthUserEntity?> get authStateChanges {
    return _remoteDataSource.authStateChanges;
  }

  @override
  AuthUserEntity? get currentUser {
    return _remoteDataSource.currentUser;
  }

  @override
  Future<AuthUserEntity> signInWithGoogle() {
    return _remoteDataSource.signInWithGoogle();
  }

  @override
  Future<AuthUserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthUserEntity> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) {
    return _remoteDataSource.createUserWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _remoteDataSource.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }
}
