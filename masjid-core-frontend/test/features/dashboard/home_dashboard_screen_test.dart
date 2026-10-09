// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/namaz_time_summary.dart';
import 'package:masjid_core_frontend/features/dashboard/presentation/home_dashboard_screen.dart';
import 'package:masjid_core_frontend/features/dashboard/presentation/widgets/next_namaz_card.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';

class _MockDashboardRepository extends Mock implements DashboardRepository {}

class _FixedAuth extends AuthController {
  _FixedAuth(this.permissions);

  final List<String> permissions;
  int signOutCalls = 0;

  @override
  AuthState build() => AuthSignedIn(
    AppUser(id: 'u1', fullName: 'Rafiq', permissions: permissions),
  );

  @override
  Future<void> signOut() async => signOutCalls++;
}

final _dashboard = DashboardResponse.fromJson(const {
  'masjid': {'id': 'm1', 'name': 'Barota Masjid'},
  'namazTime': {
    'fajr': '05:00 AM',
    'zuhr': '01:30 PM',
    'asr': '05:00 PM',
    'maghrib': '06:45 PM',
    'isha': '08:15 PM',
  },
  'membersCount': 12,
  'latestAnnouncements': [
    {
      'id': 'a1',
      'title': 'Eid prayer',
      'message': 'Eid namaz at 7 AM.',
      'createdAt': '2026-10-07T10:00:00.000Z',
    },
  ],
  'financeSummary': {
    'totalCollection': 100,
    'totalExpense': 40,
    'currentBalance': 60,
    'thisMonthCollection': 50,
    'thisMonthExpense': 10,
  },
});

const _member = <String>[
  AppPermissions.dashboardRead,
  AppPermissions.projectsRead,
  AppPermissions.ownContributionsRead,
];

const _committee = <String>[
  AppPermissions.dashboardRead,
  AppPermissions.namazTimesUpdate,
  AppPermissions.collectionsManage,
  AppPermissions.expensesManage,
  AppPermissions.imamSalaryRead,
];

Future<_FixedAuth> _pump(
  WidgetTester tester,
  DashboardRepository repository, {
  List<String> permissions = _member,
}) async {
  final auth = _FixedAuth(permissions);
  await pumpUi(
    tester,
    const Scaffold(body: HomeDashboardScreen()),
    size: const Size(420, 2000),
    overrides: [
      dashboardRepositoryProvider.overrideWithValue(repository),
      authControllerProvider.overrideWith(() => auth),
    ],
  );
  return auth;
}

List<String> _tileLabels(WidgetTester tester) => tester
    .widgetList<ActionTile>(find.byType(ActionTile))
    .map((tile) => tile.label)
    .toList();

void main() {
  testWidgets('no masjid: says so and offers to log out', (tester) async {
    final repository = _MockDashboardRepository();
    when(() => repository.getMyMasjidDashboard()).thenThrow(
      const ApiException(
        message: 'Current user is not assigned to a masjid',
        code: ApiErrorCodes.userMasjidNotAssigned,
        statusCode: 403,
      ),
    );

    final auth = await _pump(tester, repository);

    expect(
      find.text('You are not assigned to any masjid yet.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Logout'));
    expect(auth.signOutCalls, 1);
  });

  testWidgets('other errors: a picture, one line, and Try again', (
    tester,
  ) async {
    final repository = _MockDashboardRepository();
    when(() => repository.getMyMasjidDashboard()).thenThrow(
      const ApiException(
        message: 'Masjid not found',
        code: 'MASJID_NOT_FOUND',
        statusCode: 404,
      ),
    );

    await _pump(tester, repository);

    expect(find.text('Unable to load dashboard'), findsOneWidget);
    // No raw server text for people who just want their masjid.
    expect(find.text('Masjid not found'), findsNothing);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('a member sees times, their tiles, news, and the balance', (
    tester,
  ) async {
    final repository = _MockDashboardRepository();
    when(
      () => repository.getMyMasjidDashboard(),
    ).thenAnswer((_) async => _dashboard);

    await _pump(tester, repository);

    expect(find.byType(NextNamazCard), findsOneWidget);
    expect(_tileLabels(tester), <String>['News', 'Projects', 'My payments']);
    expect(find.text('Eid prayer'), findsOneWidget);
    expect(find.text('₹60'), findsOneWidget);
    expect(find.text('+₹50'), findsOneWidget);
    expect(find.text('−₹10'), findsOneWidget);
  });

  testWidgets('the committee gets money, salary, and times tiles first', (
    tester,
  ) async {
    final repository = _MockDashboardRepository();
    when(
      () => repository.getMyMasjidDashboard(),
    ).thenAnswer((_) async => _dashboard);

    await _pump(tester, repository, permissions: _committee);

    expect(_tileLabels(tester), <String>[
      'Money in',
      'Money out',
      'Salary',
      'Times',
      'News',
      'Projects',
    ]);
  });

  group('NextNamazCard', () {
    const times = NamazTimeSummary(
      fajr: '05:00 AM',
      zuhr: '01:30 PM',
      asr: '05:00 PM',
      maghrib: '06:45 PM',
      isha: '08:15 PM',
    );

    testWidgets('shows the next prayer, its time, and the time left', (
      tester,
    ) async {
      await pumpUi(
        tester,
        Scaffold(
          body: NextNamazCard(
            times: times,
            onOpen: () {},
            clock: () => DateTime(2026, 10, 8, 15, 40),
          ),
        ),
      );

      expect(find.text('Next namaz'), findsOneWidget);
      expect(find.text('Asr'), findsNWidgets(2));
      expect(find.text('5:00 PM'), findsNWidgets(2));
      expect(find.text('in 1 h 20 min'), findsOneWidget);
    });

    testWidgets('without times, editors are offered to set them', (
      tester,
    ) async {
      var opened = 0;
      await pumpUi(
        tester,
        Scaffold(
          body: NextNamazCard(
            times: null,
            canUpdate: true,
            onOpen: () => opened++,
          ),
        ),
      );

      expect(find.text('Namaz times are not set yet.'), findsOneWidget);
      await tester.tap(find.text('Set times'));
      expect(opened, 1);
    });
  });
}
