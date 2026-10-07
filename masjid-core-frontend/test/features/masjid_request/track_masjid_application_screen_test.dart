// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/masjid_request_repository.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/models/track_masjid_application_result.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/track_masjid_application_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockMasjidRequestRepository extends Mock
    implements MasjidRequestRepository {}

Future<void> _pumpAndTrack(
  WidgetTester tester,
  MasjidRequestRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        masjidRequestRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: TrackMasjidApplicationScreen(),
      ),
    ),
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Registered Phone Number *'),
    '9876543210',
  );
  await tester.tap(find.text('Track'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists the applications for the normalized phone', (
    tester,
  ) async {
    final repository = _MockMasjidRequestRepository();
    when(() => repository.trackApplicationByPhone('+919876543210')).thenAnswer(
      (_) async => [
        TrackMasjidApplicationResult.fromJson(const {
          'masjidName': 'Jama Masjid',
          'status': 'APPROVED',
          'imamName': 'Imam Sahab',
          'requestedAt': '2026-10-07T10:00:00.000Z',
          'reviewedAt': null,
        }),
      ],
    );

    await _pumpAndTrack(tester, repository);

    expect(find.text('Jama Masjid'), findsOneWidget);
    expect(find.text('APPROVED'), findsOneWidget);
    expect(find.text('Imam: Imam Sahab'), findsOneWidget);
    expect(find.text('Requested: 7 Oct 2026'), findsOneWidget);
  });

  testWidgets('says when nothing was found', (tester) async {
    final repository = _MockMasjidRequestRepository();
    when(
      () => repository.trackApplicationByPhone(any()),
    ).thenAnswer((_) async => const []);

    await _pumpAndTrack(tester, repository);

    expect(
      find.text('No application found for this phone number.'),
      findsOneWidget,
    );
  });

  testWidgets('shows the server message on error', (tester) async {
    final repository = _MockMasjidRequestRepository();
    when(() => repository.trackApplicationByPhone(any())).thenThrow(
      const ApiException(
        message: 'Enter a valid phone number',
        code: 'BAD_REQUEST',
        statusCode: 400,
      ),
    );

    await _pumpAndTrack(tester, repository);

    expect(find.text('Enter a valid phone number'), findsOneWidget);
  });
}
