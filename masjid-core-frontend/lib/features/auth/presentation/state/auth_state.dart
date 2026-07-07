import 'package:platform_core_frontend/features/auth/domain/entities/current_user.dart';
import 'package:platform_core_frontend/shared/types/json_types.dart';

enum AuthStatus {
  initial,
  checking,
  authenticated,
  unauthenticated,
}

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.errorCode,
    this.fieldErrors,
    this.isSubmitting = false,
    this.isLoggingOut = false,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null,
        errorCode = null,
        fieldErrors = null,
        isSubmitting = false,
        isLoggingOut = false;

  final AuthStatus status;
  final CurrentUser? user;
  final String? errorMessage;
  final String? errorCode;
  final JsonMap? fieldErrors;
  final bool isSubmitting;
  final bool isLoggingOut;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    CurrentUser? user,
    bool clearUser = false,
    String? errorMessage,
    String? errorCode,
    JsonMap? fieldErrors,
    bool clearError = false,
    bool? isSubmitting,
    bool? isLoggingOut,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      fieldErrors: clearError ? null : (fieldErrors ?? this.fieldErrors),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }
}
