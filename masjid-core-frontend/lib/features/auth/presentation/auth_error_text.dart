import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';

/// Backend code for a challenge that is unknown, used or already consumed
/// (masjid-core error-codes.constant.ts). Not in [ApiErrorCodes] yet.

/// The error's code, or null for non-API errors.
String? apiErrorCode(Object error) => error is ApiException ? error.code : null;

/// Text for a failed login step. Rate limiting gets a friendlier hint than
/// the throttler's raw message; everything else is the server's message.
String authErrorText(Object error) {
  if (apiErrorCode(error) == ApiErrorCodes.tooManyRequests) {
    return 'Too many attempts. Please wait a minute and try again.';
  }
  return userMessage(error);
}
