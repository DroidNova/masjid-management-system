import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/widgets/news_form.dart';
import 'package:masjid_core_frontend/features/visit/application/followed_masjids.dart';
import 'package:masjid_core_frontend/features/visit/data/public_masjid_api.dart';
import 'package:masjid_core_frontend/features/visit/presentation/public_masjid_screen.dart';

import '../shared/ui/ui_test_helpers.dart';

void main() {
  group('Who can see this', () {
    testWidgets('starts on Members only, with no warning', (tester) async {
      (String, String, bool)? saved;
      await pumpUi(
        tester,
        Scaffold(
          body: NewsForm(
            saving: false,
            initialTitle: 'Meeting',
            initialMessage: 'Tonight',
            onSave: (title, message, isPublic) =>
                saved = (title, message, isPublic),
          ),
        ),
        size: const Size(400, 1400),
      );

      expect(find.text('Members only'), findsOneWidget);
      expect(find.textContaining('Everyone will be able to see'), findsNothing);

      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(saved, ('Meeting', 'Tonight', false));
    });

    testWidgets('choosing Everyone shows the warning and saves it public', (
      tester,
    ) async {
      (String, String, bool)? saved;
      await pumpUi(
        tester,
        Scaffold(
          body: NewsForm(
            saving: false,
            initialTitle: 'Eid',
            initialMessage: 'At 7:30',
            onSave: (title, message, isPublic) =>
                saved = (title, message, isPublic),
          ),
        ),
        size: const Size(400, 1400),
      );

      await tester.tap(find.text('Everyone'));
      await tester.pump();
      expect(
        find.textContaining('Everyone will be able to see this'),
        findsOneWidget,
      );

      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(saved, ('Eid', 'At 7:30', true));
    });
  });

  group('public masjid page', () {
    final page = PublicMasjidPage.fromJson(<String, dynamic>{
      'publicCode': 'K7M2QX',
      'name': 'Jama Masjid',
      'locality': 'Barota',
      'district': 'Sonipat',
      'state': 'Haryana',
      'address': 'Main road',
      'namazTime': <String, dynamic>{'fajr': '05:00 AM', 'isha': '08:30 PM'},
      'latestAnnouncements': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'a-1',
          'title': 'Eid namaz',
          'message': 'At 7:30 in the morning',
          'createdAt': '2026-10-20T10:00:00.000Z',
        },
      ],
    });

    testWidgets('shows the place, times and public news, and can be followed', (
      tester,
    ) async {
      final container = await pumpUi(
        tester,
        const PublicMasjidScreen(code: 'K7M2QX'),
        size: const Size(400, 2400),
        overrides: [
          publicMasjidPageProvider('K7M2QX').overrideWith((ref) async => page),
        ],
      );

      expect(find.text('Jama Masjid'), findsWidgets);
      expect(find.text('Barota, Sonipat, Haryana'), findsOneWidget);
      expect(find.text('Code: K7M 2QX'), findsOneWidget);
      expect(find.text('Eid namaz'), findsOneWidget);
      // Public news carries no "Everyone" badge: all of it is public here.
      expect(find.text('Everyone'), findsNothing);

      await tester.tap(find.text('Follow this masjid'));
      await tester.pump();
      expect(find.text('Following'), findsOneWidget);
      expect(
        container.read(followedMasjidsProvider).map((m) => m.code),
        <String>['K7M2QX'],
      );

      await tester.tap(find.text('Following'));
      await tester.pump();
      expect(container.read(followedMasjidsProvider), isEmpty);
    });

    testWidgets('says so when no masjid has the code', (tester) async {
      await pumpUi(
        tester,
        const PublicMasjidScreen(code: 'AAAAAA'),
        overrides: [
          publicMasjidPageProvider('AAAAAA').overrideWith(
            (ref) async => throw const ApiException(
              message: 'No masjid with this code',
              code: ApiErrorCodes.masjidNotFound,
              statusCode: 404,
            ),
          ),
        ],
      );

      expect(
        find.text('No masjid with this code. Check the code and try again.'),
        findsOneWidget,
      );
    });
  });

  test('codes are typed loosely and shown in two parts', () {
    expect(normalizeMasjidCode(' k7m-2qx'), 'K7M2QX');
    expect(displayMasjidCode('K7M2QX'), 'K7M 2QX');
  });
}
