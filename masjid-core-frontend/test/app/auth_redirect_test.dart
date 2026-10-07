import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/app/router.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';

const _member = AppUser(id: 'm', fullName: 'Member', roles: ['MEMBER']);
const _superAdmin = AppUser(id: 's', fullName: 'Admin', roles: ['SUPER_ADMIN']);

String? _go(AuthState state, String location) =>
    authRedirect(state, Uri.parse(location));

void main() {
  group('while the stored session is being checked', () {
    test('waits on the splash screen and remembers the target', () {
      expect(_go(const AuthUnknown(), '/splash'), isNull);
      expect(
        _go(const AuthUnknown(), '/projects/42'),
        '/splash?from=%2Fprojects%2F42',
      );
    });
  });

  group('signed out', () {
    test('can open login and the public masjid request pages', () {
      for (final path in [
        '/auth',
        '/login-phone',
        '/login-otp',
        '/masjid-request',
        '/masjid-request/track',
      ]) {
        expect(_go(const AuthSignedOut(), path), isNull, reason: path);
      }
    });

    test('is sent to login from any other page', () {
      expect(_go(const AuthSignedOut(), '/main/home'), '/auth');
      expect(_go(const AuthSignedOut(), '/super-admin'), '/auth');
      expect(_go(const AuthSignedOut(), '/splash'), '/auth');
    });
  });

  group('signed in member', () {
    const state = AuthSignedIn(_member);

    test('lands on the masjid home from splash and login pages', () {
      expect(_go(state, '/splash'), '/main/home');
      expect(_go(state, '/auth'), '/main/home');
      expect(_go(state, '/login-otp'), '/main/home');
      expect(_go(state, '/main'), '/main/home');
    });

    test('returns to the page they opened before the check finished', () {
      expect(_go(state, '/splash?from=%2Fprojects%2F42'), '/projects/42');
      // Never resume into a login page.
      expect(_go(state, '/splash?from=%2Flogin-otp'), '/main/home');
    });

    test('cannot open super admin pages', () {
      expect(_go(state, '/super-admin/users'), '/main/home');
    });

    test('stays on normal pages', () {
      expect(_go(state, '/main/finance'), isNull);
      expect(_go(state, '/projects/42'), isNull);
    });
  });

  group('signed in super admin', () {
    const state = AuthSignedIn(_superAdmin);

    test('lands on the admin shell and not in the masjid app', () {
      expect(_go(state, '/splash'), '/super-admin');
      expect(_go(state, '/main/home'), '/super-admin');
      expect(_go(state, '/super-admin/requests'), isNull);
    });
  });
}
