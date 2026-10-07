import 'package:masjid_core_frontend/core/network/api_exception.dart';

/// Text safe to show the user for any error thrown by a repository.
///
/// ApiException messages come from the server and are written for users.
/// Anything else (a bug, a parse error) gets a generic message; never show
/// raw exception text like "FormatException: ...".
String userMessage(Object error) {
  if (error is ApiException) return error.message;
  return 'Something went wrong. Please try again.';
}

/// Validation message for one form field from a 400 response, if any.
String? fieldError(Object? error, String field) {
  if (error is! ApiException) return null;
  final messages = error.fieldErrors[field];
  return messages == null || messages.isEmpty ? null : messages.first;
}
