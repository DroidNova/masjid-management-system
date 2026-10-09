// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:masjid_core_frontend/features/main_shell/main_tabs.dart';
import 'package:masjid_core_frontend/features/main_shell/presentation/main_shell_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';

class _MockDashboardRepository extends Mock implements DashboardRepository {}

class _FixedAuth extends AuthController {
  _FixedAuth(this.permissions);

  final List<String> permissions;

  @override
  AuthState build() => AuthSignedIn(
    AppUser(id: 'u1', fullName: 'Rafiq', permissions: permissions),
  );
}

/// The real shell around placeholder pages, one per MainTab branch.
Future<void> _pump(
  WidgetTester tester,
  List<String> permissions, {
  Size size = const Size(400, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final dashboard = _MockDashboardRepository();
  when(() => dashboard.getMyMasjidDashboard()).thenAnswer(
    (_) async => DashboardResponse.fromJson(const {
      'masjid': {'id': 'm1', 'name': 'Barota Masjid'},
      'membersCount': 1,
      'latestAnnouncements': <Object>[],
    }),
  );
  final container = ProviderContainer(
    overrides: [
      ...await testAppOverrides(),
      authControllerProvider.overrideWith(() => _FixedAuth(permissions)),
      dashboardRepositoryProvider.overrideWithValue(dashboard),
    ],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: MainTab.home.path,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            MainShellScreen(navigationShell: shell),
        branches: <StatefulShellBranch>[
          for (final tab in MainTab.values)
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: tab.path,
                  builder: (context, state) =>
                      Center(child: Text('page ${tab.name}')),
                ),
              ],
            ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

List<String> _barLabels(WidgetTester tester) => tester
    .widgetList<NavigationDestination>(find.byType(NavigationDestination))
    .map((destination) => destination.label)
    .toList();

void main() {
  testWidgets('a member gets Home, News, My payments, Profile', (tester) async {
    await _pump(tester, const <String>[
      AppPermissions.dashboardRead,
      AppPermissions.ownContributionsRead,
    ]);

    expect(_barLabels(tester), <String>[
      'Home',
      'News',
      'My payments',
      'Profile',
    ]);
    // Home's title is the masjid's name.
    expect(find.text('Barota Masjid'), findsOneWidget);
  });

  testWidgets('the committee gets Money, Projects, People; tabs switch', (
    tester,
  ) async {
    await _pump(tester, const <String>[
      AppPermissions.dashboardRead,
      AppPermissions.collectionsManage,
      AppPermissions.expensesManage,
    ]);

    expect(_barLabels(tester), <String>[
      'Home',
      'Money',
      'Projects',
      'People',
      'Profile',
    ]);
    await tester.tap(find.text('People'));
    await tester.pumpAndSettle();
    expect(find.text('page people'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('page profile'), findsOneWidget);
  });

  testWidgets('desktop shows the side menu with the masjid name', (
    tester,
  ) async {
    await _pump(tester, const <String>[
      AppPermissions.dashboardRead,
      AppPermissions.namazTimesUpdate,
    ], size: const Size(1280, 800));

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(MasjidHeader), findsOneWidget);
    expect(find.text('Times'), findsOneWidget);
  });
}
