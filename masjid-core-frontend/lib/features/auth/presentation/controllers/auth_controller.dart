import 'package:flutter/foundation.dart';
import 'package:platform_core_frontend/core/auth/access_policy.dart';
import 'package:platform_core_frontend/core/constants/api_error_codes.dart';
import 'package:platform_core_frontend/core/network/api_exception.dart';
import 'package:platform_core_frontend/core/network/api_result.dart';
import 'package:platform_core_frontend/core/storage/token_storage.dart';
import 'package:platform_core_frontend/features/auth/domain/entities/auth_tokens.dart';
import 'package:platform_core_frontend/features/auth/domain/entities/current_user.dart';
import 'package:platform_core_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:platform_core_frontend/features/auth/presentation/state/auth_state.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthRepository authRepository,
    required TokenStorage tokenStorage,
  })  : _authRepository = authRepository,
        _tokenStorage = tokenStorage;

  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;

  AuthState _state = const AuthState.initial();
  AuthState get state => _state;

  bool get canAccessAdmin => AccessPolicy.canViewAdmin(_state.user);

  bool get canViewSettings => AccessPolicy.canViewSettings(_state.user);

  bool get canManageUsers => AccessPolicy.canManageUsers(_state.user);

  Future<void> restoreSession() async {
    if (_state.status == AuthStatus.checking) {
      return;
    }

    _setState(
      _state.copyWith(
        status: AuthStatus.checking,
        clearError: true,
      ),
    );

    final accessToken = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (_isBlank(accessToken) && _isBlank(refreshToken)) {
      _markUnauthenticated();
      return;
    }

    final userResult = await _authRepository.getCurrentUser();
    if (await _applyCurrentUserResult(userResult)) {
      return;
    }

    if (_isBlank(refreshToken)) {
      await _tokenStorage.clearTokens();
      _markUnauthenticated();
      return;
    }

    final refreshResult =
        await _authRepository.refreshToken(refreshToken: refreshToken);
    switch (refreshResult) {
      case ApiSuccess<AuthTokens>():
        final retriedUserResult = await _authRepository.getCurrentUser();
        if (await _applyCurrentUserResult(retriedUserResult)) {
          return;
        }
      case ApiFailure<AuthTokens>():
        break;
    }

    await _tokenStorage.clearTokens();
    _markUnauthenticated(
      message: 'Your session has expired. Please login again.',
      errorCode: ApiErrorCodes.sessionExpired,
    );
  }

  Future<bool> login({
    required String emailOrPhone,
    required String password,
  }) async {
    return _submitAuth(
      action: () => _authRepository.login(
        payload: {
          'emailOrPhone': emailOrPhone.trim(),
          'password': password,
        },
      ),
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setState(
      _state.copyWith(
        isSubmitting: true,
      ),
    );

    final result = await _authRepository.register(
      payload: {
        'fullName': name.trim(),
        'email': email.trim(),
        'password': password,
      },
    );

    switch (result) {
      case ApiSuccess<AuthTokens>():
        await _tokenStorage.clearTokens();
        _setState(
          _state.copyWith(
            status: AuthStatus.unauthenticated,
            clearUser: true,
            clearError: true,
            isSubmitting: false,
            isLoggingOut: false,
          ),
        );
        return true;
      case ApiFailure<AuthTokens>(:final exception):
        _markUnauthenticated(message: _toUserMessage(exception), errorCode: exception.errorCode, fieldErrors: exception.errors);
        return false;
    }
  }

  Future<void> logout() async {
    _setState(
      _state.copyWith(
        isLoggingOut: true,
        clearError: true,
      ),
    );

    await _authRepository.logout();

    _setState(
      _state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearError: true,
        isSubmitting: false,
        isLoggingOut: false,
      ),
    );
  }

  void clearError() {
    if (_state.errorMessage == null) {
      return;
    }

    _setState(_state.copyWith(clearError: true));
  }

  Future<bool> _submitAuth({
    required Future<ApiResult<AuthTokens>> Function() action,
  }) async {
    _setState(
      _state.copyWith(
        isSubmitting: true,
      ),
    );

    final authResult = await action();
    switch (authResult) {
      case ApiSuccess<AuthTokens>(:final data):
        final user = data.user;
        if (user != null) {
          _setState(
            _state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
              clearError: true,
              isSubmitting: false,
              isLoggingOut: false,
            ),
          );
          return true;
        }
        final userResult = await _authRepository.getCurrentUser();
        final success = await _applyCurrentUserResult(userResult);
        if (!success) {
          _setState(_state.copyWith(isSubmitting: false));
        }
        return success;
      case ApiFailure<AuthTokens>(:final exception):
        _markUnauthenticated(message: _toUserMessage(exception), errorCode: exception.errorCode, fieldErrors: exception.errors);
        return false;
    }
  }

  Future<bool> _applyCurrentUserResult(ApiResult<CurrentUser> result) async {
    switch (result) {
      case ApiSuccess<CurrentUser>(:final data):
        _setState(
          _state.copyWith(
            status: AuthStatus.authenticated,
            user: data,
            clearError: true,
            isSubmitting: false,
            isLoggingOut: false,
          ),
        );
        return true;
      case ApiFailure<CurrentUser>(:final exception):
        _markUnauthenticated(message: _toUserMessage(exception), errorCode: exception.errorCode, fieldErrors: exception.errors);
        return false;
    }
  }

  void _markUnauthenticated({String? message, String? errorCode, Map<String, dynamic>? fieldErrors}) {
    _setState(
      _state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        errorMessage: message,
        errorCode: errorCode,
        fieldErrors: fieldErrors,
        clearError: message == null,
        isSubmitting: false,
        isLoggingOut: false,
      ),
    );
  }

  String _toUserMessage(ApiException exception) {
    if (exception.isInvalidCredentials) {
      return 'Invalid username or password.';
    }
    if (exception.isSessionExpired) {
      return 'Your session has expired. Please login again.';
    }
    if (exception.isForbidden) {
      return 'You do not have permission to perform this action.';
    }
    if (exception.isValidationError) {
      final validationMessage = _validationErrorsMessage(exception.errors);
      if (validationMessage != null) {
        return validationMessage;
      }
      return exception.message.isNotEmpty ? exception.message : 'Please check the entered details.';
    }
    final message = exception.message.trim();
    if (message.isNotEmpty) {
      return message;
    }
    return 'Something went wrong. Please try again later.';
  }

  String? _validationErrorsMessage(Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) {
      return null;
    }

    final messages = <String>[];
    for (final value in errors.values) {
      if (value is String && value.trim().isNotEmpty) {
        messages.add(value.trim());
      } else if (value is List) {
        for (final item in value) {
          if (item is String && item.trim().isNotEmpty) {
            messages.add(item.trim());
          }
        }
      }
    }

    if (messages.isEmpty) {
      return null;
    }

    if (messages.length == 1) {
      return messages.first;
    }

    return messages.map((message) => '• $message').join('\n');
  }


  bool _isBlank(String? value) => value == null || value.isEmpty;

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}
