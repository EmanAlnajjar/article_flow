import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_user_entity.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthUserEntity? user;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.successMessage,
  });

  bool get isAuthenticated {
    return status == AuthStatus.authenticated && user != null;
  }

  bool get isLoading {
    return status == AuthStatus.loading;
  }

  AuthState copyWith({
    AuthStatus? status,
    AuthUserEntity? user,
    String? errorMessage,
    String? successMessage,
    bool clearUser = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props {
    return [status, user, errorMessage, successMessage];
  }
}
