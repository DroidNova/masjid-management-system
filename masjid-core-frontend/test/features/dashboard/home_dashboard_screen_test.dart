// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/dashboard/data/dashboard_repository.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:masjid_core_frontend/features/dashboard/presentation/home_dashboard_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockDashboardRepository extends Mock implements DashboardRepository {}

/// Auth state fixed to "signed out" (no storage, no network).
class _FixedAuth extends AuthController {
  @override
  AuthState build() => const AuthSignedOut();
}

Future<void> _pump(WidgetTester tester, DashboardRepository repository) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(_FixedAuth.new),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: HomeDashboardScreen()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('says "not assigned" for USER_MASJID_NOT_ASSIGNED, by code', (
    tester,
  ) async {
    final repository = _MockDashboardRepository();
    when(() => repository.getMyMasjidDashboard()).thenThrow(
      const ApiException(
        message: 'Current user is not assigned to a masjid',
        code: ApiErrorCodes.userMasjidNotAssigned,
        statusCode: 403,
      ),
    );

    await _pump(tester, repository);

    expect(
      find.text('You are not assigned to any masjid yet.'),
      findsOneWidget,
    );
    expect(find.text('Logout / Back to Login'), findsOneWidget);
  });

  testWidgets('other errors show the message and a retry button', (
    tester,
  ) async {
    final repository = _MockDashboardRepository();
    when(() => repository.getMyMasjidDashboard()).thenThrow(
      // Mentions "masjid" but is not the no-masjid code: no longer misread.
      const ApiException(
        message: 'Masjid not found',
        code: 'MASJID_NOT_FOUND',
        statusCode: 404,
      ),
    );

    await _pump(tester, repository);

    expect(find.text('Unable to load dashboard'), findsOneWidget);
    expect(find.text('Masjid not found'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('renders the dashboard when data loads', (tester) async {
    final repository = _MockDashboardRepository();
    when(() => repository.getMyMasjidDashboard()).thenAnswer(
      (_) async => DashboardResponse.fromJson(const {
        'masjid': {'id': 'm1', 'name': 'Barota Masjid'},
        'membersCount': 12,
        'latestAnnouncements': <Object>[],
        'projectsSummary': {
          'activeProjectsCount': 0,
          'latestProjects': <Object>[],
        },
        'financeSummary': {
          'totalCollection': 100,
          'totalExpense': 40,
          'currentBalance': 60,
        },
      }),
    );

    await _pump(tester, repository);

    expect(find.textContaining('Barota Masjid'), findsWidgets);
  });
}
