// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/features/announcements/data/announcements_repository.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/update_announcement_request.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/edit_announcement_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockAnnouncementsRepository extends Mock
    implements AnnouncementsRepository {}

const _server = AnnouncementModel(
  id: 'a1',
  title: 'Server title',
  message: 'Server message',
);

Future<void> _pump(
  WidgetTester tester,
  AnnouncementsRepository repository, {
  AnnouncementModel? preview,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        announcementsRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        home: EditAnnouncementScreen(
          announcementId: 'a1',
          announcement: preview,
        ),
      ),
    ),
  );
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
  late _MockAnnouncementsRepository repository;

  setUpAll(() => registerFallbackValue(const UpdateAnnouncementRequest()));
  setUp(() => repository = _MockAnnouncementsRepository());

  testWidgets('from a fresh URL: loads by id, then shows the form', (
    tester,
  ) async {
    final response = Completer<AnnouncementModel>();
    when(
      () => repository.getAnnouncement('a1'),
    ).thenAnswer((_) => response.future);

    await _pump(tester, repository);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    response.complete(_server);
    await tester.pumpAndSettle();

    expect(_fieldText(tester, 'Title *'), 'Server title');
    expect(_fieldText(tester, 'Message *'), 'Server message');
  });

  testWidgets('opened from the list: uses that announcement, no request', (
    tester,
  ) async {
    await _pump(
      tester,
      repository,
      preview: const AnnouncementModel(
        id: 'a1',
        title: 'Old title',
        message: 'Old message',
      ),
    );
    await tester.pumpAndSettle();
    expect(_fieldText(tester, 'Title *'), 'Old title');
    expect(_fieldText(tester, 'Message *'), 'Old message');
    verifyNever(() => repository.getAnnouncement(any()));
  });

  testWidgets('shows the error when the announcement cannot be loaded', (
    tester,
  ) async {
    when(() => repository.getAnnouncement('a1')).thenThrow(
      const ApiException(
        message: 'Announcement not found',
        code: ApiErrorCodes.announcementNotFound,
        statusCode: 404,
      ),
    );

    await _pump(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('Announcement not found'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows server validation errors under the fields', (
    tester,
  ) async {
    when(
      () => repository.getAnnouncement('a1'),
    ).thenAnswer((_) async => _server);
    when(() => repository.updateAnnouncement('a1', any())).thenThrow(
      const ApiException(
        message: 'Validation failed',
        code: ApiErrorCodes.validation,
        statusCode: 400,
        fieldErrors: <String, List<String>>{
          'title': <String>['title must be shorter than 150 characters'],
        },
      ),
    );

    await _pump(tester, repository);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update Announcement'));
    await tester.pumpAndSettle();

    expect(
      find.text('title must be shorter than 150 characters'),
      findsOneWidget,
    );
    expect(find.text('Validation failed'), findsOneWidget);
  });
}
