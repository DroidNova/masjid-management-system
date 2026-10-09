// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/masjid_request_repository.dart';
import 'package:masjid_core_frontend/features/masjid_request/data/models/track_masjid_application_result.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/track_masjid_application_screen.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/widgets/request_timeline.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';

class _MockMasjidRequestRepository extends Mock
    implements MasjidRequestRepository {}

Future<void> _pumpAndTrack(
  WidgetTester tester,
  MasjidRequestRepository repository,
) async {
  await pumpUi(
    tester,
    const TrackMasjidApplicationScreen(),
    size: const Size(420, 1400),
    overrides: [masjidRequestRepositoryProvider.overrideWithValue(repository)],
  );
  await tapKeypad(tester, '9876543210');
  await tester.tap(find.widgetWithText(FilledButton, 'Check'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Check waits for a full phone number', (tester) async {
    await pumpUi(
      tester,
      const TrackMasjidApplicationScreen(),
      size: const Size(420, 1400),
      overrides: [
        masjidRequestRepositoryProvider.overrideWithValue(
          _MockMasjidRequestRepository(),
        ),
      ],
    );
    await tapKeypad(tester, '98765');
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Check'))
          .onPressed,
      isNull,
    );
  });

  testWidgets('lists the requests for the phone with their progress', (
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
          'reviewedAt': '2026-10-08T10:00:00.000Z',
        }),
      ],
    );

    await _pumpAndTrack(tester, repository);

    expect(find.text('Jama Masjid'), findsOneWidget);
    expect(find.text('Imam Sahab'), findsOneWidget);
    expect(find.widgetWithText(StatusBadge, 'Approved'), findsOneWidget);
    expect(find.byType(RequestTimeline), findsOneWidget);
    expect(find.text('7 Oct 2026'), findsOneWidget);
    expect(find.text('8 Oct 2026'), findsOneWidget);
  });

  testWidgets('says when nothing was found', (tester) async {
    final repository = _MockMasjidRequestRepository();
    when(
      () => repository.trackApplicationByPhone(any()),
    ).thenAnswer((_) async => const []);

    await _pumpAndTrack(tester, repository);

    expect(find.text('No request found for this number.'), findsOneWidget);
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
