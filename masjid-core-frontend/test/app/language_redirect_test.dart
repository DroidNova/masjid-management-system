import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/app/router.dart';

String? _go(bool chosen, String location, {String? target}) => languageRedirect(
  hasChosenLanguage: chosen,
  uri: Uri.parse(location),
  target: target,
);

void main() {
  group('before a language is chosen', () {
    test('the requested page waits behind the language picker', () {
      expect(_go(false, '/auth'), '/language?from=%2Fauth');
      expect(
        _go(false, '/masjid-request/track'),
        '/language?from=%2Fmasjid-request%2Ftrack',
      );
    });

    test("the auth redirect's target is what comes after the picker", () {
      expect(
        _go(false, '/main/home', target: '/auth'),
        '/language?from=%2Fauth',
      );
    });

    test('the splash screen, the picker, and the gallery are left alone', () {
      expect(_go(false, '/splash'), isNull);
      expect(
        _go(false, '/projects', target: '/splash?from=%2Fprojects'),
        '/splash?from=%2Fprojects',
      );
      expect(_go(false, '/language?from=%2Fauth'), isNull);
      expect(_go(false, '/dev/gallery'), isNull);
    });
  });

  test('after a language is chosen only the auth redirect applies', () {
    expect(_go(true, '/auth'), isNull);
    expect(_go(true, '/main/home', target: '/auth'), '/auth');
  });
}
