// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/auth_repository.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/community/data/community_repository.dart';
import 'package:masjid_core_frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:masjid_core_frontend/features/profile/presentation/change_password_screen.dart';
import 'package:masjid_core_frontend/features/profile/presentation/profile_screen.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';

class _MockCommunityRepository extends Mock implements CommunityRepository {}

class _MockDashboardRepository extends Mock implements DashboardRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _FixedAuth extends AuthController {
  _FixedAuth(this.user);

  final AppUser user;
  int signOutCalls = 0;

  @override
  AuthState build() => AuthSignedIn(user);

  @override
  Future<void> signOut() async {
    signOutCalls++;
    state = const AuthSignedOut();
  }
}

AppUser _user({
  List<String> roles = const ['MEMBER'],
  List<String> permissions = const [AppPermissions.masjidLeave],
  String? masjidId = 'm1',
  String status = 'ACTIVE',
}) => AppUser(
  id: 'u1',
  fullName: 'Mohammed Rafiq',
  phone: '+919876543210',
  roles: roles,
  permissions: permissions,
  masjidId: masjidId,
  status: status,
  isPhoneVerified: true,
  isFamilyHead: true,
  createdAt: DateTime(2026, 1, 15),
);

Future<_FixedAuth> _pump(
  WidgetTester tester,
  AppUser user, {
  CommunityRepository? community,
}) async {
  final auth = _FixedAuth(user);
  final dashboard = _MockDashboardRepository();
  when(() => dashboard.getMyMasjidDashboard()).thenAnswer(
    (_) async => DashboardResponse.fromJson(const {
      'masjid': {
        'id': 'm1',
        'name': 'Barota Jama Masjid',
        'locality': 'Barota',
        'state': 'Bihar',
      },
      'membersCount': 12,
      'latestAnnouncements': <Object>[],
    }),
  );
  await pumpUi(
    tester,
    const Scaffold(body: ProfileScreen()),
    size: const Size(420, 1600),
    overrides: [
      authControllerProvider.overrideWith(() => auth),
      dashboardRepositoryProvider.overrideWithValue(dashboard),
      communityRepositoryProvider.overrideWithValue(
        community ?? _MockCommunityRepository(),
      ),
    ],
  );
  return auth;
}

Future<void> _holdLeave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Leave masjid'));
  await tester.tap(find.text('Leave masjid'));
  await tester.pumpAndSettle();
  final gesture = await tester.startGesture(
    tester.getCenter(
      find.descendant(
        of: find.byType(HoldToConfirmButton),
        matching: find.text('Leave'),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 2100));
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows who you are and your account status', (tester) async {
    await _pump(tester, _user());

    expect(find.text('Mohammed Rafiq'), findsOneWidget);
    expect(find.text('+919876543210'), findsOneWidget);
    expect(find.text('Member'), findsOneWidget);
    expect(find.text('Family head'), findsOneWidget);
    expect(find.widgetWithText(StatusBadge, 'Active'), findsOneWidget);
    expect(find.widgetWithText(StatusBadge, 'Verified'), findsOneWidget);
    expect(find.text('Barota Jama Masjid'), findsOneWidget);
    expect(find.text('Barota, Bihar'), findsOneWidget);
    expect(find.text('15 Jan 2026'), findsOneWidget);
  });

  testWidgets('members have no password to change', (tester) async {
    await _pump(tester, _user());
    expect(find.text('Change password'), findsNothing);
  });

  testWidgets('the imam can change their password', (tester) async {
    await _pump(tester, _user(roles: const ['IMAM']));
    expect(find.text('Change password'), findsOneWidget);
  });

  testWidgets('settings are saved: large text and read aloud', (tester) async {
    await _pump(tester, _user());
    await tester.tap(find.text('Large text'));
    await tester.pumpAndSettle();

    final tile = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Large text'),
    );
    expect(tile.value, isTrue);
  });

  testWidgets('log out asks first, then signs out', (tester) async {
    final auth = await _pump(tester, _user());

    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(auth.signOutCalls, 0);

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Logout'));
    await tester.pumpAndSettle();
    expect(auth.signOutCalls, 1);
  });

  group('leave masjid', () {
    testWidgets('is hidden without a masjid', (tester) async {
      await _pump(tester, _user(masjidId: null));
      expect(find.text('Leave masjid'), findsNothing);
    });

    testWidgets('is hidden without the permission', (tester) async {
      await _pump(tester, _user(permissions: const []));
      expect(find.text('Leave masjid'), findsNothing);
    });

    testWidgets('a single tap only opens the warning', (tester) async {
      final community = _MockCommunityRepository();
      await _pump(tester, _user(), community: community);

      await tester.ensureVisible(find.text('Leave masjid'));
      await tester.tap(find.text('Leave masjid'));
      await tester.pumpAndSettle();
      expect(find.text('Leave the masjid?'), findsOneWidget);
      expect(find.text('Barota Jama Masjid'), findsWidgets);

      await tester.tap(
        find.descendant(
          of: find.byType(HoldToConfirmButton),
          matching: find.text('Leave'),
        ),
      );
      await tester.pumpAndSettle();
      verifyNever(() => community.leaveMyMasjid());
    });

    testWidgets('holding Leave leaves, shows it, and signs out', (
      tester,
    ) async {
      final community = _MockCommunityRepository();
      when(() => community.leaveMyMasjid()).thenAnswer((_) async {});
      final auth = await _pump(tester, _user(), community: community);

      await _holdLeave(tester);

      verify(() => community.leaveMyMasjid()).called(1);
      expect(find.text('You left Barota Jama Masjid'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(auth.signOutCalls, 1);
    });

    testWidgets('a refusal shows the reason and keeps you signed in', (
      tester,
    ) async {
      final community = _MockCommunityRepository();
      when(() => community.leaveMyMasjid()).thenThrow(
        const ApiException(
          message: 'You are the last committee member.',
          code: 'CANNOT_LEAVE_MASJID',
          statusCode: 400,
        ),
      );
      final auth = await _pump(tester, _user(), community: community);

      await _holdLeave(tester);

      expect(find.text('You are the last committee member.'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(auth.signOutCalls, 0);
      expect(find.text('Leave masjid'), findsOneWidget);
    });
  });

  group('change password', () {
    Future<_MockAuthRepository> pumpChange(WidgetTester tester) async {
      final repository = _MockAuthRepository();
      await pumpUi(
        tester,
        const ChangePasswordScreen(),
        size: const Size(420, 1200),
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      return repository;
    }

    Future<void> fill(
      WidgetTester tester,
      String current,
      String next,
      String repeat,
    ) async {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Current password'),
        current,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'New password'),
        next,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'New password again'),
        repeat,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
    }

    testWidgets('checks length and that both new passwords match', (
      tester,
    ) async {
      final repository = await pumpChange(tester);
      await fill(tester, 'old-pass', 'short', 'short');
      expect(find.text('Use at least 8 letters or numbers.'), findsOneWidget);

      await fill(tester, 'old-pass', 'new-pass-1', 'new-pass-2');
      expect(find.text('The two passwords are not the same.'), findsOneWidget);
      verifyZeroInteractions(repository);
    });

    testWidgets('a wrong current password is explained', (tester) async {
      final repository = await pumpChange(tester);
      when(
        () => repository.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenThrow(
        const ApiException(
          message: 'Invalid credentials',
          code: ApiErrorCodes.invalidCredentials,
          statusCode: 401,
        ),
      );

      await fill(tester, 'wrong-pass', 'new-pass-1', 'new-pass-1');
      expect(find.text('The current password is wrong.'), findsOneWidget);
    });

    testWidgets('success shows the tick', (tester) async {
      final repository = await pumpChange(tester);
      when(
        () => repository.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async {});

      await fill(tester, 'old-pass', 'new-pass-1', 'new-pass-1');
      verify(
        () => repository.changePassword(
          currentPassword: 'old-pass',
          newPassword: 'new-pass-1',
        ),
      ).called(1);
      expect(find.text('Password changed'), findsOneWidget);
    });
  });
}
