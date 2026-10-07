// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/namaz_time_model.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/update_namaz_time_request.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/namaz_time_repository.dart';
import 'package:masjid_core_frontend/features/namaz_time/presentation/update_namaz_time_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockNamazTimeRepository extends Mock implements NamazTimeRepository {}

class _SignedInAs extends AuthController {
  _SignedInAs(this.user);

  final AppUser user;

  @override
  AuthState build() => AuthSignedIn(user);
}

const _user = AppUser(id: 'u1', fullName: 'Imam', masjidId: 'user-masjid');

const _times = NamazTimeModel(
  masjidId: 'user-masjid',
  fajr: '05:00 AM',
  zuhr: '01:30 PM',
  note: 'Ramadan timings',
);

/// Opens the screen on top of a home page, so `context.pop()` works.
Future<ProviderContainer> _pump(
  WidgetTester tester,
  NamazTimeRepository repository, {
  AppUser user = _user,
  NamazTimeModel? initial,
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const Text('Home')),
      GoRoute(
        path: '/update',
        builder: (_, _) => UpdateNamazTimeScreen(initial: initial),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        namazTimeRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(() => _SignedInAs(user)),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  unawaited(router.push('/update'));
  await tester.pump();
  return ProviderScope.containerOf(tester.element(find.byType(Navigator)));
}

String _fieldText(WidgetTester tester, String label) => tester
    .widget<EditableText>(
      find.descendant(
        of: find.widgetWithText(TextFormField, label),
        matching: find.byType(EditableText),
      ),
    )
    .controller
    .text;

void main() {
  late _MockNamazTimeRepository repository;

  setUpAll(() => registerFallbackValue(const UpdateNamazTimeRequest()));
  setUp(() => repository = _MockNamazTimeRepository());

  testWidgets("loads the signed-in user's masjid, then fills the form", (
    tester,
  ) async {
    final response = Completer<NamazTimeModel>();
    when(() => repository.getMyNamazTime()).thenAnswer((_) => response.future);

    await _pump(tester, repository);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    response.complete(_times);
    await tester.pumpAndSettle();

    expect(_fieldText(tester, 'Fajr'), '05:00 AM');
    expect(_fieldText(tester, 'Zuhr'), '01:30 PM');
    expect(_fieldText(tester, 'Asr'), '');
    expect(_fieldText(tester, 'Note'), 'Ramadan timings');
  });

  testWidgets('prefilled from the dashboard: no request', (tester) async {
    await _pump(tester, repository, initial: _times);
    await tester.pumpAndSettle();

    expect(_fieldText(tester, 'Fajr'), '05:00 AM');
    expect(_fieldText(tester, 'Note'), 'Ramadan timings');
    verifyNever(() => repository.getMyNamazTime());
  });

  testWidgets('shows the server message and retries on error', (tester) async {
    when(() => repository.getMyNamazTime()).thenThrow(
      const ApiException(
        message: 'You are not allowed to access this masjid',
        code: 'MASJID_ACCESS_FORBIDDEN',
        statusCode: 403,
      ),
    );

    await _pump(tester, repository);
    await tester.pumpAndSettle();

    expect(
      find.text('You are not allowed to access this masjid'),
      findsOneWidget,
    );

    when(() => repository.getMyNamazTime()).thenAnswer((_) async => _times);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(_fieldText(tester, 'Fajr'), '05:00 AM');
  });

  testWidgets('says so when the user has no masjid', (tester) async {
    await _pump(
      tester,
      repository,
      user: const AppUser(id: 'u2', fullName: 'No Masjid'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Masjid not found for this user.'), findsOneWidget);
    verifyNever(() => repository.getMyNamazTime());
  });

  testWidgets('save sends filled fields, marks changes and goes back', (
    tester,
  ) async {
    when(() => repository.getMyNamazTime()).thenAnswer((_) async => _times);
    when(
      () => repository.updateMyNamazTime(any()),
    ).thenAnswer((_) async => _times);

    final container = await _pump(tester, repository);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save Namaz Time'));
    await tester.tap(find.text('Save Namaz Time'));
    await tester.pumpAndSettle();

    final request =
        verify(() => repository.updateMyNamazTime(captureAny())).captured.single
            as UpdateNamazTimeRequest;
    expect(request.toJson(), <String, dynamic>{
      'fajr': '05:00 AM',
      'zuhr': '01:30 PM',
      'note': 'Ramadan timings',
    });
    expect(container.read(dataVersionProvider(DataScope.namazTimes)), 1);
    expect(container.read(dataVersionProvider(DataScope.dashboard)), 1);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('a failed save shows the message and field errors', (
    tester,
  ) async {
    when(() => repository.getMyNamazTime()).thenAnswer((_) async => _times);
    when(() => repository.updateMyNamazTime(any())).thenThrow(
      const ApiException(
        message: 'Validation failed',
        code: ApiErrorCodes.validation,
        statusCode: 400,
        fieldErrors: <String, List<String>>{
          'note': <String>['note must be shorter than 500 characters'],
        },
      ),
    );

    await _pump(tester, repository);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save Namaz Time'));
    await tester.tap(find.text('Save Namaz Time'));
    await tester.pumpAndSettle();

    expect(find.text('Validation failed'), findsOneWidget);
    expect(
      find.text('note must be shorter than 500 characters'),
      findsOneWidget,
    );
    expect(find.text('Home'), findsNothing);
  });
}
