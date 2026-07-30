import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/app_exception.dart';
import '../models/auth_user_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  late final Future<void> _googleInitialization;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn {
    _googleInitialization = _googleSignIn.initialize();
  }

  @override
  Stream<AuthUserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }

      return AuthUserModel.fromFirebaseUser(user);
    });
  }

  @override
  AuthUserModel? get currentUser {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return null;
    }

    return AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Future<AuthUserModel> signInWithGoogle() async {
    try {
      await _googleInitialization;

      final googleUser = await _googleSignIn.authenticate();

      final googleAuthentication = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuthentication.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      return _getUserOrThrow(
        userCredential,
        message: 'Google Sign-In did not return a user.',
      );
    } on GoogleSignInException catch (exception) {
      if (exception.code == GoogleSignInExceptionCode.canceled) {
        throw const AppException(message: 'Google Sign-In was cancelled.');
      }

      throw AppException(
        message: exception.description ?? 'Google Sign-In failed.',
      );
    } on FirebaseAuthException catch (exception) {
      throw AppException(message: _mapFirebaseError(exception));
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        message: 'Unable to sign in with Google. Please try again.',
      );
    }
  }

  @override
  Future<AuthUserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return _getUserOrThrow(
        userCredential,
        message: 'Sign-in did not return a user.',
      );
    } on FirebaseAuthException catch (exception) {
      throw AppException(message: _mapFirebaseError(exception));
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(message: 'Unable to sign in. Please try again.');
    }
  }

  @override
  Future<AuthUserModel> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw const AppException(
          message: 'Account creation did not return a user.',
        );
      }

      await user.updateDisplayName(name.trim());
      await user.reload();

      final updatedUser = _firebaseAuth.currentUser;

      if (updatedUser == null) {
        throw const AppException(
          message: 'Unable to load the created account.',
        );
      }

      return AuthUserModel.fromFirebaseUser(updatedUser);
    } on FirebaseAuthException catch (exception) {
      throw AppException(message: _mapFirebaseError(exception));
    } on AppException {
      rethrow;
    } catch (_) {
      throw const AppException(
        message: 'Unable to create the account. Please try again.',
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (exception) {
      throw AppException(message: _mapFirebaseError(exception));
    } catch (_) {
      throw const AppException(
        message: 'Unable to send the reset email. Please try again.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleInitialization;

      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } on FirebaseAuthException catch (exception) {
      throw AppException(message: _mapFirebaseError(exception));
    } catch (_) {
      throw const AppException(
        message: 'Unable to sign out. Please try again.',
      );
    }
  }

  AuthUserModel _getUserOrThrow(
    UserCredential userCredential, {
    required String message,
  }) {
    final user = userCredential.user;

    if (user == null) {
      throw AppException(message: message);
    }

    return AuthUserModel.fromFirebaseUser(user);
  }

  String _mapFirebaseError(FirebaseAuthException exception) {
    return switch (exception.code) {
      'account-exists-with-different-credential' =>
        'An account already exists with a different sign-in method.',
      'email-already-in-use' =>
        'An account already exists for this email address.',
      'invalid-email' => 'Please enter a valid email address.',
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'The email or password is incorrect.',
      'weak-password' => 'The password must contain at least 6 characters.',
      'operation-not-allowed' => 'This sign-in method is not enabled.',
      'user-disabled' => 'This user account has been disabled.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'network-request-failed' => 'No internet connection.',
      _ => exception.message ?? 'Authentication failed. Please try again.',
    };
  }
}
