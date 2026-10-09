import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';

export 'package:masjid_core_frontend/core/errors/error_text.dart'
    show apiErrorCode;

/// Text for a failed login step, in the app's language. The common login
/// mistakes get short local messages; anything else goes to [errorText].
String authErrorText(AppLocalizations l10n, Object error) {
  return switch (apiErrorCode(error)) {
    ApiErrorCodes.otpInvalid => l10n.errorWrongCode,
    ApiErrorCodes.otpExpired ||
    ApiErrorCodes.otpChallengeInvalid => l10n.errorCodeExpired,
    ApiErrorCodes.invalidCredentials => l10n.errorWrongPassword,
    ApiErrorCodes.userInactive => l10n.errorAccountInactive,
    _ => errorText(l10n, error),
  };
}
