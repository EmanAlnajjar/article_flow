import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/use_cases/auth_use_cases.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final WatchAuthStateUseCase _watchAuthStateUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithEmailAndPasswordUseCase _signInWithEmailAndPasswordUseCase;
  final CreateUserWithEmailAndPasswordUseCase
  _createUserWithEmailAndPasswordUseCase;
  final SendPasswordResetEmailUseCase _sendPasswordResetEmailUseCase;
  final SignOutUseCase _signOutUseCase;

  StreamSubscription<AuthUserEntity?>? _authSubscription;

  AuthCubit({
    required WatchAuthStateUseCase watchAuthStateUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInWithEmailAndPasswordUseCase
    signInWithEmailAndPasswordUseCase,
    required CreateUserWithEmailAndPasswordUseCase
    createUserWithEmailAndPasswordUseCase,
    required SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase,
    required SignOutUseCase signOutUseCase,
  }) : _watchAuthStateUseCase = watchAuthStateUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _signInWithEmailAndPasswordUseCase = signInWithEmailAndPasswordUseCase,
       _createUserWithEmailAndPasswordUseCase =
           createUserWithEmailAndPasswordUseCase,
       _sendPasswordResetEmailUseCase = sendPasswordResetEmailUseCase,
       _signOutUseCase = signOutUseCase,
       super(const AuthState()) {
    _startWatchingAuthState();
  }

  void _startWatchingAuthState() {
    final currentUser = _getCurrentUserUseCase();

    if (currentUser != null) {
      emit(AuthState(status: AuthStatus.authenticated, user: currentUser));
    }

    _authSubscription = _watchAuthStateUseCase().listen(
      _onAuthStateChanged,
      onError: (Object error) {
        if (isClosed) {
          return;
        }

        emit(
          AuthState(
            status: AuthStatus.failure,
            user: state.user,
            errorMessage: _getErrorMessage(error),
          ),
        );
      },
    );
  }

  void _onAuthStateChanged(AuthUserEntity? user) {
    if (isClosed) {
      return;
    }

    if (user == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }

    emit(AuthState(status: AuthStatus.authenticated, user: user));
  }

  Future<void> signInWithGoogle() async {
    if (state.isLoading) {
      return;
    }

    _emitLoading();

    try {
      final user = await _signInWithGoogleUseCase();

      _emitAuthenticated(user);
    } catch (exception) {
      _emitFailure(exception);
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (state.isLoading) {
      return;
    }

    _emitLoading();

    try {
      final user = await _signInWithEmailAndPasswordUseCase(
        email: email,
        password: password,
      );

      _emitAuthenticated(user);
    } catch (exception) {
      _emitFailure(exception);
    }
  }

  Future<void> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    if (state.isLoading) {
      return;
    }

    _emitLoading();

    try {
      final user = await _createUserWithEmailAndPasswordUseCase(
        name: name,
        email: email,
        password: password,
      );

      _emitAuthenticated(user);
    } catch (exception) {
      _emitFailure(exception);
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    if (state.isLoading) {
      return;
    }

    _emitLoading();

    try {
      await _sendPasswordResetEmailUseCase(email: email);

      if (isClosed) {
        return;
      }

      emit(
        const AuthState(
          status: AuthStatus.unauthenticated,
          successMessage:
              'Password reset instructions were sent to your email.',
        ),
      );
    } catch (exception) {
      _emitFailure(exception);
    }
  }

  Future<void> signOut() async {
    if (state.isLoading) {
      return;
    }

    final currentUser = state.user;

    _emitLoading();

    try {
      await _signOutUseCase();

      if (isClosed) {
        return;
      }

      emit(const AuthState(status: AuthStatus.unauthenticated));
    } catch (exception) {
      if (isClosed) {
        return;
      }

      emit(
        AuthState(
          status: AuthStatus.failure,
          user: currentUser,
          errorMessage: _getErrorMessage(exception),
        ),
      );
    }
  }

  void clearMessages() {
    if (isClosed) {
      return;
    }

    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  void _emitLoading() {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  void _emitAuthenticated(AuthUserEntity user) {
    if (isClosed) {
      return;
    }

    emit(AuthState(status: AuthStatus.authenticated, user: user));
  }

  void _emitFailure(Object exception) {
    if (isClosed) {
      return;
    }

    emit(
      AuthState(
        status: AuthStatus.failure,
        user: state.user,
        errorMessage: _getErrorMessage(exception),
      ),
    );
  }

  String _getErrorMessage(Object exception) {
    if (exception is AppException) {
      return exception.message;
    }

    return 'Authentication failed. Please try again.';
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
