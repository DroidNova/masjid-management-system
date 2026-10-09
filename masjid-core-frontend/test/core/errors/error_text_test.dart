import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';

const _inAnotherMasjid = ApiException(
  message: 'Committee member +919800000001 is already in another masjid.',
  code: ApiErrorCodes.userInAnotherMasjid,
);

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final hi = lookupAppLocalizations(const Locale('hi'));
  final ur = lookupAppLocalizations(const Locale('ur'));

  test('English shows the server message, which names the problem', () {
    expect(errorText(en, _inAnotherMasjid), _inAnotherMasjid.message);
  });

  test('Hindi and Urdu show the app sentence for a known code', () {
    expect(errorText(hi, _inAnotherMasjid), hi.errorInAnotherMasjid);
    expect(errorText(ur, _inAnotherMasjid), ur.errorInAnotherMasjid);
    expect(
      errorText(
        hi,
        const ApiException(
          message: 'Project not found',
          code: 'PROJECT_NOT_FOUND',
        ),
      ),
      hi.errorNotFound,
    );
  });

  test('an unknown code falls back to the server message', () {
    const error = ApiException(message: 'Odd problem', code: 'SOMETHING_NEW');
    expect(errorText(hi, error), 'Odd problem');
  });

  test('no internet and bugs are always in the app language', () {
    const offline = ApiException(
      message: 'Cannot reach the server.',
      code: ApiErrorCodes.network,
    );
    expect(errorText(en, offline), en.errorNoInternet);
    expect(errorText(ur, offline), ur.errorNoInternet);
    expect(errorText(hi, const FormatException('x')), hi.somethingWentWrong);
  });

  test('the main server codes have text in every language', () {
    for (final l10n in <AppLocalizations>[en, hi, ur]) {
      for (final code in <String>[
        'SESSION_EXPIRED',
        'FORBIDDEN',
        'VALIDATION_ERROR',
        'NOT_FOUND',
        'CONFLICT',
        'USER_IN_ANOTHER_MASJID',
        'MASJID_USER_ALREADY_LINKED',
        'PHONE_ALREADY_EXISTS',
        'EMAIL_ALREADY_EXISTS',
        'IMAM_SALARY_ALREADY_EXISTS',
        'MASJID_REQUEST_ALREADY_APPROVED',
      ]) {
        expect(translatedError(l10n, code), isNotEmpty, reason: code);
      }
    }
  });
}
