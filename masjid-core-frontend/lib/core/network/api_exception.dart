import 'package:dio/dio.dart';

/// Error codes the backend sends in `errorCode` (masjid-core
/// src/common/constants/error-codes.constant.ts). Compare against these,
/// never against message text.
class ApiErrorCodes {
  const ApiErrorCodes._();

  static const String network = 'NETWORK_ERROR';
  static const String unknown = 'UNKNOWN_ERROR';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String forbidden = 'FORBIDDEN';
  static const String sessionExpired = 'SESSION_EXPIRED';
  static const String sessionRevoked = 'SESSION_REVOKED';
  static const String validation = 'VALIDATION_ERROR';
  static const String tooManyRequests = 'TOO_MANY_REQUESTS';
  static const String userMasjidNotAssigned = 'USER_MASJID_NOT_ASSIGNED';
  static const String userInAnotherMasjid = 'USER_IN_ANOTHER_MASJID';
  static const String otpInvalid = 'OTP_INVALID';
  static const String otpExpired = 'OTP_EXPIRED';
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String otpChallengeInvalid = 'OTP_CHALLENGE_INVALID';
  static const String notFound = 'NOT_FOUND';
  static const String masjidUserAlreadyLinked = 'MASJID_USER_ALREADY_LINKED';
  static const String announcementNotFound = 'ANNOUNCEMENT_NOT_FOUND';
  static const String imamSalaryNotFound = 'IMAM_SALARY_NOT_FOUND';
  static const String imamSalaryAlreadyExists = 'IMAM_SALARY_ALREADY_EXISTS';
}

/// A failed API call, built once from the backend's error envelope:
/// `{ success: false, message, errorCode, errors?, requestId }`.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    required this.code,
    this.statusCode,
    this.fieldErrors = const <String, List<String>>{},
    this.requestId,
  });

  /// Human-readable message from the server (safe to show).
  final String message;

  /// Machine-readable `errorCode` (see [ApiErrorCodes]).
  final String code;
  final int? statusCode;

  /// Validation messages per field, from `errors`.
  final Map<String, List<String>> fieldErrors;
  final String? requestId;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNetworkError => code == ApiErrorCodes.network;

  /// Converts any Dio failure into an [ApiException].
  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final data = response?.data;

    if (response == null) {
      final timeout =
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout;
      return ApiException(
        message: timeout
            ? 'The server took too long to respond. Please try again.'
            : 'Cannot reach the server. Check your internet connection.',
        code: ApiErrorCodes.network,
      );
    }

    if (data is Map<String, dynamic>) {
      final message = data['message'];
      final code = data['errorCode'];
      return ApiException(
        message: message is String && message.isNotEmpty
            ? message
            : 'Something went wrong. Please try again.',
        code: code is String && code.isNotEmpty ? code : ApiErrorCodes.unknown,
        statusCode: response.statusCode,
        fieldErrors: _readFieldErrors(data['errors']),
        requestId: data['requestId']?.toString(),
      );
    }

    return ApiException(
      message: 'Something went wrong. Please try again.',
      code: ApiErrorCodes.unknown,
      statusCode: response.statusCode,
    );
  }

  static Map<String, List<String>> _readFieldErrors(Object? errors) {
    if (errors is! Map<String, dynamic>) return const <String, List<String>>{};
    return errors.map(
      (field, value) => MapEntry(
        field,
        value is List
            ? value.map((item) => item.toString()).toList()
            : <String>[value.toString()],
      ),
    );
  }

  /// Screens built before M4 show `error.toString()`; keep that readable.
  @override
  String toString() => message;
}
