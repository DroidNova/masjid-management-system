// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:masjid_core_frontend/features/dashboard/presentation/home_dashboard_screen.dart';
import 'package:masjid_core_frontend/features/namaz_time/presentation/namaz_times_screen.dart';
import 'package:masjid_core_frontend/features/profile/presentation/change_password_screen.dart';
import 'package:masjid_core_frontend/features/profile/presentation/profile_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';

class _MockDashboardRepository extends Mock implements DashboardRepository {}

class _FixedAuth extends AuthController {
  @override
  AuthState build() => AuthSignedIn(
    AppUser(
      id: 'u1',
      fullName: 'Mohammed Rafiq Khan',
      phone: '+919876543210',
      roles: const <String>['COMMITTEE_MEMBER', 'MEMBER'],
      // Everything a committee member has: the busiest screens.
      permissions: const <String>[
        AppPermissions.dashboardRead,
        AppPermissions.masjidLeave,
        AppPermissions.namazTimesUpdate,
        AppPermissions.announcementsManage,
        AppPermissions.collectionsManage,
        AppPermissions.expensesManage,
        AppPermissions.projectsRead,
        AppPermissions.imamSalaryRead,
        AppPermissions.ownContributionsRead,
      ],
      masjidId: 'm1',
      status: 'ACTIVE',
      isFamilyHead: true,
      createdAt: DateTime(2026),
    ),
  );
}

final _dashboard = DashboardResponse.fromJson(const {
  'masjid': {
    'id': 'm1',
    'name': 'Barota Jama Masjid Committee',
    'locality': 'Barota',
    'district': 'Patna',
    'state': 'Bihar',
  },
  'namazTime': {
    'fajr': '05:00 AM',
    'zuhr': '01:30 PM',
    'asr': '05:00 PM',
    'maghrib': '06:45 PM',
    'isha': '08:15 PM',
    'jumma': '01:15 PM',
    'note': 'Times change with the season.',
  },
  'membersCount': 120,
  'latestAnnouncements': [
    {
      'id': 'a1',
      'title': 'Eid ul Adha namaz will be held at the Eidgah',
      'message': 'Please come early. Bring your own mat.',
      'createdAt': '2026-10-07T10:00:00.000Z',
    },
  ],
  'financeSummary': {
    'totalCollection': 1250000,
    'totalExpense': 40000,
    'currentBalance': 1210000,
    'thisMonthCollection': 125000,
    'thisMonthExpense': 99999,
  },
});

/// Every U2 screen lays out without overflow in each language, on a phone
/// and on desktop, and with a large device font.
void main() {
  setUp(() {
    // Loading placeholders pulse forever otherwise.
    TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearAccessibilityFeaturesTestValue();
  });

  final screens = <String, Widget>{
    'home': const Scaffold(body: HomeDashboardScreen()),
    'times': const Scaffold(body: NamazTimesScreen()),
    'profile': const Scaffold(body: ProfileScreen()),
    'password': const ChangePasswordScreen(),
  };
  const sizes = <String, Size>{
    'phone': Size(360, 780),
    'desktop': Size(1280, 900),
  };

  Future<void> pump(
    WidgetTester tester,
    Widget screen,
    Locale locale,
    Size size,
  ) async {
    final repository = _MockDashboardRepository();
    when(
      () => repository.getMyMasjidDashboard(),
    ).thenAnswer((_) async => _dashboard);
    await pumpUi(
      tester,
      screen,
      locale: locale,
      size: size,
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(_FixedAuth.new),
      ],
    );
  }

  for (final screen in screens.entries) {
    for (final language in <String>['en', 'hi', 'ur']) {
      for (final size in sizes.entries) {
        testWidgets('${screen.key} in $language on a ${size.key}', (
          tester,
        ) async {
          await pump(tester, screen.value, Locale(language), size.value);
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('${screen.key} on a phone with a large device font', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pump(
        tester,
        screen.value,
        const Locale('ur'),
        const Size(360, 780),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
