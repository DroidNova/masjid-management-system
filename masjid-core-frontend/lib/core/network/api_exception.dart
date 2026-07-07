import 'package:platform_core_frontend/core/constants/api_error_codes.dart';
import 'package:platform_core_frontend/shared/types/json_types.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.errorCode,
    this.statusCode,
    this.errors,
  });

  final String message;
  final String? errorCode;
  final int? statusCode;
  final JsonMap? errors;

  bool get isInvalidCredentials => errorCode == ApiErrorCodes.invalidCredentials;
  bool get isSessionExpired => errorCode == ApiErrorCodes.sessionExpired;
  bool get isUnauthorized => errorCode == ApiErrorCodes.unauthorized;
  bool get isForbidden => errorCode == ApiErrorCodes.forbidden;
  bool get isValidationError => errorCode == ApiErrorCodes.validationError;

  @override
  String toString() {
    return 'ApiException(message: $message, errorCode: $errorCode, statusCode: $statusCode, errors: $errors)';
  }
}
