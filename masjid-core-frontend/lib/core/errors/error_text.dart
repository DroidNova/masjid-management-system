import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';

/// The error's code, or null for non-API errors.
String? apiErrorCode(Object error) => error is ApiException ? error.code : null;

/// Text to show for any error, in the app's language where the app knows
/// the case (no internet, too many tries, unknown failures). Other API
/// errors show the server's message, which names the specific problem.
/// Never shows raw exception text.
String errorText(AppLocalizations l10n, Object error) {
  if (error is! ApiException) return l10n.somethingWentWrong;
  return switch (error.code) {
    ApiErrorCodes.network => l10n.errorNoInternet,
    ApiErrorCodes.tooManyRequests => l10n.errorTooManyTries,
    ApiErrorCodes.unknown => l10n.somethingWentWrong,
    _ => error.message.isEmpty ? l10n.somethingWentWrong : error.message,
  };
}
