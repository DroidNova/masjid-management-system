import 'package:dio/dio.dart';

String getReadableErrorMessage(
  Object error, {
  String fallbackMessage = 'Something went wrong. Please try again.',
}) {
  final rawMessage = _extractRawMessage(error);
  final rawCode = _extractRawCode(error);
  final combined = '${rawCode ?? ''} ${rawMessage ?? ''}'.toLowerCase();

  if (combined.contains('unauthorized') ||
      combined.contains('session expired') ||
      combined.contains('401')) {
    return 'Session expired. Please login again.';
  }
  if (combined.contains('forbidden') || combined.contains('403')) {
    return 'You are not allowed to perform this action.';
  }
  if (combined.contains('user_masjid_not_assigned') ||
      combined.contains('not assigned to a masjid') ||
      combined.contains('not assigned to any masjid')) {
    return 'You are not assigned to any masjid yet.';
  }
  if (combined.contains('phone_already_exists') ||
      (combined.contains('phone') && combined.contains('exists'))) {
    return 'Phone number already exists.';
  }
  if (combined.contains('email_already_exists') ||
      (combined.contains('email') && combined.contains('exists'))) {
    return 'Email already exists.';
  }
  if (combined.contains('bad_request') || combined.contains('400')) {
    return 'Please check the entered details.';
  }

  final cleaned = rawMessage?.replaceFirst('Exception: ', '').trim();
  if (cleaned != null && cleaned.isNotEmpty) return cleaned;
  return fallbackMessage;
}

String? _extractRawMessage(Object error) {
  if (error is DioException) {
    final responseData = error.response?.data;
    final message = _messageFromResponseData(responseData);
    if (message != null && message.isNotEmpty) return message;
    return error.message;
  }

  final message = error.toString();
  return message.isEmpty ? null : message;
}

String? _extractRawCode(Object error) {
  if (error is! DioException) return null;
  final responseData = error.response?.data;
  if (responseData is Map<String, dynamic>) {
    final code = responseData['code'] ?? responseData['errorCode'];
    if (code != null && code.toString().isNotEmpty) return code.toString();

    final responseError = responseData['error'];
    if (responseError is Map<String, dynamic>) {
      final nestedCode = responseError['code'] ?? responseError['errorCode'];
      if (nestedCode != null && nestedCode.toString().isNotEmpty) {
        return nestedCode.toString();
      }
    }
  }
  return null;
}

String? _messageFromResponseData(Object? responseData) {
  if (responseData is Map<String, dynamic>) {
    final message = responseData['message'];
    if (message is String && message.isNotEmpty) return message;
    if (message is List && message.isNotEmpty) return message.join('\n');

    final responseError = responseData['error'];
    if (responseError is Map<String, dynamic>) {
      final errorMessage = responseError['message'];
      if (errorMessage is String && errorMessage.isNotEmpty) {
        return errorMessage;
      }
      if (errorMessage is List && errorMessage.isNotEmpty) {
        return errorMessage.join('\n');
      }
    }
  }

  if (responseData is String && responseData.isNotEmpty) return responseData;
  return null;
}
