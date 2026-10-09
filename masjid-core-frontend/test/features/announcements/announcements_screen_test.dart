// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/announcements/application/news_seen.dart';
import 'package:masjid_core_frontend/features/announcements/data/announcements_api.dart';
import 'package:masjid_core_frontend/features/announcements/data/announcements_repository.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/create_announcement_request.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/add_announcement_screen.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/announcements_screen.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/widgets/announcement_card.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../shared/ui/ui_test_helpers.dart';

class _MockAnnouncementsRepository extends Mock
    implements AnnouncementsRepository {}

class _MockApiClient extends Mock implements ApiClient {}

class _FakeCreate extends Fake implements CreateAnnouncementRequest {}

class _SignedInAs extends AuthController {
  _SignedInAs(this.permissions);

  final List<String> permissions;

  @override
  AuthState build() => AuthSignedIn(
    AppUser(
      id: 'u1',
      fullName: 'Rafiq',
      masjidId: 'm1',
      permissions: permissions,
    ),
  );
}

PageResult<AnnouncementModel> _page(List<AnnouncementModel> items) =>
    PageResult.fromJson(<String, dynamic>{
      'items': items.map((item) => item.toJson()).toList(),
      'meta': <String, dynamic>{
        'page': 1,
        'limit': 20,
        'total': items.length,
        'totalPages': 1,
        'hasNextPage': false,
      },
    }, AnnouncementModel.fromJson);

final _eid = AnnouncementModel(
  id: 'a1',
  title: 'Eid namaz',
  message: 'Eid namaz at 7 AM at the Eidgah.',
  createdAt: DateTime.utc(2026, 10, 8, 10),
);

final _clean = AnnouncementModel(
  id: 'a2',
  title: 'Cleaning day',
  message: 'Please help clean the masjid on Sunday.',
  createdAt: DateTime.utc(2026, 10, 1, 10),
);

const _manager = <String>[AppPermissions.announcementsManage];

Future<ProviderContainer> _pump(
  WidgetTester tester,
  AnnouncementsRepository repository, {
  List<String> permissions = const <String>[],
}) {
  return pumpRouted(
    tester,
    const AnnouncementsScreen(showAppBar: true),
    overrides: [
      announcementsRepositoryProvider.overrideWithValue(repository),
      authControllerProvider.overrideWith(() => _SignedInAs(permissions)),
    ],
    extraRoutes: const <String, Widget>{
      '/announcements/add': Scaffold(body: Text('add page')),
    },
  );
}

void main() {
  setUpAll(() => registerFallbackValue(_FakeCreate()));

  test('the list asks the server for visible news only', () async {
    final client = _MockApiClient();
    when(
      () => client.get<Map<String, dynamic>>(any(), query: any(named: 'query')),
    ).thenAnswer((_) async => <String, dynamic>{'items': <Object>[]});

    await AnnouncementsApi(client).getAnnouncements();

    final query =
        verify(
              () => client.get<Map<String, dynamic>>(
                '/announcements/my-masjid',
                query: captureAny(named: 'query'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(query['isActive'], isTrue);
  });

  testWidgets('members read the news; no add, edit, or delete', (tester) async {
    final repository = _MockAnnouncementsRepository();
    when(
      () => repository.getAnnouncements(page: any(named: 'page')),
    ).thenAnswer((_) async => _page([_eid, _clean]));

    await _pump(tester, repository);

    expect(find.text('Eid namaz'), findsOneWidget);
    expect(find.text('Cleaning day'), findsOneWidget);
    expect(find.byType(ReadAloudButton), findsNWidgets(2));
    expect(find.text('Add news'), findsNothing);
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('managers get Add news, Edit, and Delete', (tester) async {
    final repository = _MockAnnouncementsRepository();
    when(
      () => repository.getAnnouncements(page: any(named: 'page')),
    ).thenAnswer((_) async => _page([_eid]));

    await _pump(tester, repository, permissions: _manager);

    expect(find.text('Add news'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    await tester.tap(find.text('Add news'));
    await tester.pumpAndSettle();
    expect(find.text('add page'), findsOneWidget);
  });

  testWidgets('delete needs a hold, then the news is gone', (tester) async {
    final repository = _MockAnnouncementsRepository();
    when(
      () => repository.getAnnouncements(page: any(named: 'page')),
    ).thenAnswer((_) async => _page([_eid]));
    when(
      () => repository.deactivateAnnouncement('a1'),
    ).thenAnswer((_) async => _eid.copyWith(isActive: false));

    await _pump(tester, repository, permissions: _manager);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this news?'), findsOneWidget);

    final hold = find.descendant(
      of: find.byType(HoldToConfirmButton),
      matching: find.text('Delete'),
    );
    final gesture = await tester.startGesture(tester.getCenter(hold));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2100));
    await gesture.up();
    await tester.pumpAndSettle();

    verify(() => repository.deactivateAnnouncement('a1')).called(1);
    expect(find.text('News deleted'), findsOneWidget);
  });

  testWidgets('no news: a picture, and Add for managers', (tester) async {
    final repository = _MockAnnouncementsRepository();
    when(
      () => repository.getAnnouncements(page: any(named: 'page')),
    ).thenAnswer((_) async => _page(const []));

    await _pump(tester, repository, permissions: _manager);

    expect(find.text('No news yet'), findsOneWidget);
    expect(find.text('Add the first news'), findsOneWidget);
  });

  testWidgets('a failed load offers Try again', (tester) async {
    final repository = _MockAnnouncementsRepository();
    when(() => repository.getAnnouncements(page: any(named: 'page'))).thenThrow(
      const ApiException(message: 'boom', code: 'UNKNOWN', statusCode: 500),
    );

    await _pump(tester, repository);

    expect(find.text('Unable to load news'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('unseen news is marked New; opening the list remembers it', (
    tester,
  ) async {
    final repository = _MockAnnouncementsRepository();
    when(
      () => repository.getAnnouncements(page: any(named: 'page')),
    ).thenAnswer((_) async => _page([_eid, _clean]));

    // Seen up to 5 Oct: Eid (8 Oct) is new, Cleaning (1 Oct) is not.
    final container = await pumpRouted(
      tester,
      const AnnouncementsScreen(),
      prefs: <String, Object>{
        'news.lastSeen.u1': DateTime.utc(2026, 10, 5).toIso8601String(),
      },
      overrides: [
        announcementsRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(() => _SignedInAs(const [])),
      ],
    );

    final cards = tester.widgetList<AnnouncementCard>(
      find.byType(AnnouncementCard),
    );
    expect(cards.map((card) => card.isNew), <bool>[true, false]);
    expect(find.text('New'), findsOneWidget);
    // Opening the list counted as seeing the newest one.
    expect(container.read(newsLastSeenProvider), DateTime.utc(2026, 10, 8, 10));
  });

  test('isNewNews: newer than last seen, everything before a first look', () {
    final seen = DateTime.utc(2026, 10, 5);
    expect(isNewNews(DateTime.utc(2026, 10, 8), seen), isTrue);
    expect(isNewNews(DateTime.utc(2026, 10, 2), seen), isFalse);
    expect(isNewNews(DateTime.utc(2026, 10, 2), null), isTrue);
    expect(isNewNews(null, null), isFalse);
  });

  group('add news', () {
    testWidgets('empty fields are asked for; nothing is sent', (tester) async {
      final repository = _MockAnnouncementsRepository();
      await pumpRouted(
        tester,
        const AddAnnouncementScreen(),
        overrides: [
          announcementsRepositoryProvider.overrideWithValue(repository),
        ],
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Please fill this in.'), findsNWidgets(2));
      verifyNever(() => repository.createAnnouncement(any()));
    });

    testWidgets('saving publishes it, shows the tick, and goes back', (
      tester,
    ) async {
      final repository = _MockAnnouncementsRepository();
      when(
        () => repository.createAnnouncement(any()),
      ).thenAnswer((_) async => _eid);
      await pumpRouted(
        tester,
        const AddAnnouncementScreen(),
        overrides: [
          announcementsRepositoryProvider.overrideWithValue(repository),
        ],
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        '  Eid namaz ',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Message'),
        'Eid namaz at 7 AM.',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      final request =
          verify(
                () => repository.createAnnouncement(captureAny()),
              ).captured.single
              as CreateAnnouncementRequest;
      expect(request.title, 'Eid namaz');
      expect(request.isActive, isTrue);
      expect(find.text('News published'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });
  });

  testWidgets('a long message folds and opens with Read more', (tester) async {
    final long = AnnouncementModel(
      id: 'a3',
      title: 'Ramadan',
      message: List<String>.filled(40, 'Taraweeh after Isha.').join(' '),
      createdAt: DateTime.utc(2026, 10, 8),
    );
    await pumpUi(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: AnnouncementCard(announcement: long),
        ),
      ),
    );

    expect(find.text('Read more'), findsOneWidget);
    await tester.tap(find.text('Read more'));
    await tester.pumpAndSettle();
    expect(find.text('Show less'), findsOneWidget);
  });
}
