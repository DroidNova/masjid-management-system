// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/features/announcements/data/announcements_repository.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/update_announcement_request.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/edit_announcement_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';

class _MockAnnouncementsRepository extends Mock
    implements AnnouncementsRepository {}

class _FakeUpdate extends Fake implements UpdateAnnouncementRequest {}

const _eid = AnnouncementModel(
  id: 'a1',
  title: 'Eid namaz',
  message: 'Eid namaz at 7 AM.',
);

Future<void> _pump(
  WidgetTester tester,
  AnnouncementsRepository repository, {
  AnnouncementModel? passed,
}) => pumpRouted(
  tester,
  EditAnnouncementScreen(announcementId: 'a1', announcement: passed),
  overrides: [announcementsRepositoryProvider.overrideWithValue(repository)],
);

String _field(WidgetTester tester, String label) => tester
    .widget<EditableText>(
      find.descendant(
        of: find.widgetWithText(TextFormField, label),
        matching: find.byType(EditableText),
      ),
    )
    .controller
    .text;

void main() {
  setUpAll(() => registerFallbackValue(_FakeUpdate()));

  testWidgets('opened from the list: uses that news, no request', (
    tester,
  ) async {
    final repository = _MockAnnouncementsRepository();
    await _pump(tester, repository, passed: _eid);

    expect(_field(tester, 'Title'), 'Eid namaz');
    expect(_field(tester, 'Message'), 'Eid namaz at 7 AM.');
    verifyNever(() => repository.getAnnouncement(any()));
  });

  testWidgets('from a fresh URL: loads by id, then shows the form', (
    tester,
  ) async {
    final repository = _MockAnnouncementsRepository();
    when(() => repository.getAnnouncement('a1')).thenAnswer((_) async => _eid);

    await _pump(tester, repository);

    expect(_field(tester, 'Title'), 'Eid namaz');
    verify(() => repository.getAnnouncement('a1')).called(1);
  });

  testWidgets('a failed load shows why and offers Try again', (tester) async {
    final repository = _MockAnnouncementsRepository();
    when(() => repository.getAnnouncement('a1')).thenThrow(
      const ApiException(
        message: 'Announcement not found',
        code: ApiErrorCodes.announcementNotFound,
        statusCode: 404,
      ),
    );

    await _pump(tester, repository);

    expect(find.text('Announcement not found'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('saving sends the change (kept visible) and goes back', (
    tester,
  ) async {
    final repository = _MockAnnouncementsRepository();
    when(
      () => repository.updateAnnouncement(any(), any()),
    ).thenAnswer((_) async => _eid);
    await _pump(tester, repository, passed: _eid);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Eid namaz moved',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    final request =
        verify(
              () => repository.updateAnnouncement('a1', captureAny()),
            ).captured.single
            as UpdateAnnouncementRequest;
    expect(request.title, 'Eid namaz moved');
    expect(request.isActive, isTrue);
    expect(find.text('Saved'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('a refused save shows the server reason', (tester) async {
    final repository = _MockAnnouncementsRepository();
    when(() => repository.updateAnnouncement(any(), any())).thenThrow(
      const ApiException(
        message: 'Title must be 150 characters or less',
        code: 'VALIDATION_ERROR',
        statusCode: 400,
      ),
    );
    await _pump(tester, repository, passed: _eid);

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Title must be 150 characters or less'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });
}
