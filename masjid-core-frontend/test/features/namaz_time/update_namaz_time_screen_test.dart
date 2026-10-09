// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/namaz_time/application/prayer_schedule.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/namaz_time_model.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/update_namaz_time_request.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/namaz_time_repository.dart';
import 'package:masjid_core_frontend/features/namaz_time/presentation/update_namaz_time_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';

class _MockNamazTimeRepository extends Mock implements NamazTimeRepository {}

class _FakeRequest extends Fake implements UpdateNamazTimeRequest {}

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

Future<ProviderContainer> _pump(
  WidgetTester tester,
  NamazTimeRepository repository, {
  AppUser user = _user,
  NamazTimeModel? initial,
}) async {
  return pumpRouted(
    tester,
    UpdateNamazTimeScreen(initial: initial),
    size: const Size(420, 1800),
    overrides: [
      namazTimeRepositoryProvider.overrideWithValue(repository),
      authControllerProvider.overrideWith(() => _SignedInAs(user)),
    ],
  );
}

Finder _save() => find.widgetWithText(FilledButton, 'Save');

void main() {
  setUpAll(() => registerFallbackValue(_FakeRequest()));

  test('times are stored in one fixed form and shift around midnight', () {
    expect(formatNamazTime(const TimeOfDay(hour: 17, minute: 5)), '05:05 PM');
    expect(formatNamazTime(const TimeOfDay(hour: 0, minute: 30)), '12:30 AM');
    expect(
      shiftTime(const TimeOfDay(hour: 23, minute: 58), 5),
      const TimeOfDay(hour: 0, minute: 3),
    );
    expect(
      shiftTime(const TimeOfDay(hour: 0, minute: 2), -5),
      const TimeOfDay(hour: 23, minute: 57),
    );
  });

  testWidgets('prefilled times show without a request; Save waits', (
    tester,
  ) async {
    final repository = _MockNamazTimeRepository();
    await _pump(tester, repository, initial: _times);

    expect(find.text('5:00 AM'), findsOneWidget);
    expect(find.text('1:30 PM'), findsOneWidget);
    // Asr, Maghrib, Isha, and Jumma have no time yet.
    expect(find.text('Set time'), findsNWidgets(4));
    expect(tester.widget<FilledButton>(_save()).onPressed, isNull);
    verifyNever(() => repository.getMyNamazTime());
  });

  testWidgets('+5 then Save sends the times, marks changes, goes back', (
    tester,
  ) async {
    final repository = _MockNamazTimeRepository();
    when(
      () => repository.updateMyNamazTime(any()),
    ).thenAnswer((_) async => _times);
    final container = await _pump(tester, repository, initial: _times);

    await tester.tap(find.byTooltip('5 minutes later').first);
    await tester.pump();
    expect(find.text('5:05 AM'), findsOneWidget);
    expect(find.text('Changed'), findsOneWidget);

    await tester.ensureVisible(_save());
    await tester.tap(_save());
    await tester.pumpAndSettle();

    final request =
        verify(() => repository.updateMyNamazTime(captureAny())).captured.single
            as UpdateNamazTimeRequest;
    expect(request.fajr, '05:05 AM');
    expect(request.zuhr, '01:30 PM');
    expect(request.asr, isNull);
    expect(request.note, 'Ramadan timings');
    expect(container.read(dataVersionProvider(DataScope.dashboard)), 1);

    expect(find.text('Times saved'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('leaving with changes asks first', (tester) async {
    await _pump(tester, _MockNamazTimeRepository(), initial: _times);

    await tester.tap(find.byTooltip('5 minutes earlier').first);
    await tester.pump();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Leave without saving?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Leave'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('a failed save shows the reason on the page', (tester) async {
    final repository = _MockNamazTimeRepository();
    when(() => repository.updateMyNamazTime(any())).thenThrow(
      const ApiException(
        message: 'Fajr time must be 20 characters or less',
        code: 'VALIDATION_ERROR',
        statusCode: 400,
      ),
    );
    await _pump(tester, repository, initial: _times);

    await tester.tap(find.byTooltip('5 minutes later').first);
    await tester.pump();
    await tester.ensureVisible(_save());
    await tester.tap(_save());
    await tester.pumpAndSettle();

    expect(
      find.text('Fajr time must be 20 characters or less'),
      findsOneWidget,
    );
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('from a fresh URL the times are loaded', (tester) async {
    final repository = _MockNamazTimeRepository();
    when(() => repository.getMyNamazTime()).thenAnswer((_) async => _times);

    await _pump(tester, repository);

    expect(find.text('5:00 AM'), findsOneWidget);
    verify(() => repository.getMyNamazTime()).called(1);
  });

  testWidgets('a failed load offers Try again', (tester) async {
    final repository = _MockNamazTimeRepository();
    when(() => repository.getMyNamazTime()).thenThrow(
      const ApiException(
        message: 'Masjid not found',
        code: 'NOT_FOUND',
        statusCode: 404,
      ),
    );

    await _pump(tester, repository);

    expect(find.text('Masjid not found'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('says so when the user has no masjid', (tester) async {
    await _pump(
      tester,
      _MockNamazTimeRepository(),
      user: const AppUser(id: 'u1', fullName: 'Nobody'),
    );

    expect(
      find.text('You are not assigned to any masjid yet.'),
      findsOneWidget,
    );
  });
}
