import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';

/// The error's code, or null for non-API errors.
String? apiErrorCode(Object error) => error is ApiException ? error.code : null;

/// Text to show for any error. Never shows raw exception text.
///
/// No internet, too many tries, and unknown failures are always in the
/// app's language. Other API errors: in English the server's message
/// (written for people, and the most specific); in Hindi and Urdu the
/// translated sentence for the error's code, or the server's message for
/// a code the app does not know.
String errorText(AppLocalizations l10n, Object error) {
  if (error is! ApiException) return l10n.somethingWentWrong;
  switch (error.code) {
    case ApiErrorCodes.network:
      return l10n.errorNoInternet;
    case ApiErrorCodes.tooManyRequests:
      return l10n.errorTooManyTries;
    case ApiErrorCodes.unknown:
      return l10n.somethingWentWrong;
  }
  final server = error.message;
  if (l10n.localeName == 'en' && server.isNotEmpty) return server;
  return translatedError(l10n, error.code) ??
      (server.isEmpty ? l10n.somethingWentWrong : server);
}

/// The app's own sentence for a server error code, or null when the app
/// has none. Codes: masjid-core/src/common/constants/error-codes.constant.ts.
String? translatedError(AppLocalizations l10n, String code) => switch (code) {
  'UNAUTHORIZED' ||
  'SESSION_EXPIRED' ||
  'SESSION_REVOKED' => l10n.errorLoginAgain,
  'FORBIDDEN' ||
  'MASJID_ACCESS_FORBIDDEN' ||
  'MASJID_REQUEST_FORBIDDEN' ||
  'MASJID_USER_FORBIDDEN' ||
  'ANNOUNCEMENT_ACCESS_FORBIDDEN' ||
  'PROJECT_ACCESS_FORBIDDEN' ||
  'IMAM_SALARY_ACCESS_FORBIDDEN' ||
  'FINANCE_ACCESS_FORBIDDEN' ||
  'PASSWORD_CHANGE_NOT_ALLOWED' ||
  'PASSWORD_LOGIN_NOT_ALLOWED_FOR_MEMBER' ||
  'INVALID_ROLE_FOR_CREATION' ||
  'ROLE_NOT_ASSIGNABLE' ||
  'SUPER_ADMIN_IMMUTABLE' => l10n.notAllowedMessage,
  'VALIDATION_ERROR' ||
  'BAD_REQUEST' ||
  'MASJID_REQUEST_REQUESTER_DETAILS_REQUIRED' => l10n.errorCheckInput,
  'NOT_FOUND' ||
  'MASJID_REQUEST_NOT_FOUND' ||
  'MASJID_NOT_FOUND' ||
  'MASJID_USER_NOT_FOUND' ||
  'ANNOUNCEMENT_NOT_FOUND' ||
  'PROJECT_NOT_FOUND' ||
  'IMAM_SALARY_NOT_FOUND' ||
  'COLLECTION_NOT_FOUND' ||
  'EXPENSE_NOT_FOUND' ||
  'USER_NOT_FOUND' ||
  'ROLE_NOT_FOUND' => l10n.errorNotFound,
  'INTERNAL_SERVER_ERROR' ||
  'SERVICE_UNAVAILABLE' ||
  'MASJID_REQUEST_APPROVAL_FAILED' => l10n.somethingWentWrong,
  'CONFLICT' => l10n.errorAlreadyExists,
  'INVALID_CREDENTIALS' => l10n.errorWrongPassword,
  'OTP_INVALID' => l10n.errorWrongCode,
  'OTP_EXPIRED' || 'OTP_CHALLENGE_INVALID' => l10n.errorCodeExpired,
  'PASSWORD_UNCHANGED' => l10n.errorSamePassword,
  'USER_INACTIVE' => l10n.errorAccountInactive,
  'USER_MASJID_NOT_ASSIGNED' => l10n.noMasjidAssigned,
  'USER_IN_ANOTHER_MASJID' => l10n.errorInAnotherMasjid,
  'MASJID_USER_ALREADY_LINKED' => l10n.errorAlreadyInMasjid,
  'PHONE_ALREADY_EXISTS' => l10n.phoneAlreadyRegistered,
  'EMAIL_ALREADY_EXISTS' => l10n.errorEmailTaken,
  'USER_ALREADY_EXISTS_WITH_DIFFERENT_DETAILS' => l10n.errorPhoneOtherPerson,
  'IMAM_SALARY_ALREADY_EXISTS' => l10n.errorSalaryMonthStarted,
  'MASJID_REQUEST_ALREADY_APPROVED' ||
  'MASJID_REQUEST_ALREADY_REJECTED' => l10n.errorRequestDecided,
  'MASJID_NOT_APPROVED' => l10n.errorMasjidNotApproved,
  'PUBLIC_REGISTER_DISABLED' || 'CANNOT_LEAVE_MASJID' => l10n.notAllowedMessage,
  _ => null,
};
