// mocktail needs `when(() => mock.call())` closures, not tear-offs.
// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/announcements/data/announcements_repository.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/add_announcement_screen.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/announcements_screen.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/models/app_user.dart';
import 'package:masjid_core_frontend/features/namaz_time/data/models/namaz_time_model.dart';
import 'package:masjid_core_frontend/features/namaz_time/presentation/update_namaz_time_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../shared/ui/ui_test_helpers.dart';

class _MockAnnouncementsRepository extends Mock
    implements AnnouncementsRepository {}

class _Manager extends AuthController {
  @override
  AuthState build() => const AuthSignedIn(
    AppUser(
      id: 'u1',
      fullName: 'Imam Sahab',
      masjidId: 'm1',
      permissions: <String>[
        AppPermissions.announcementsManage,
        AppPermissions.namazTimesUpdate,
      ],
    ),
  );
}

final _page = PageResult.fromJson(<String, dynamic>{
  'items': <Map<String, dynamic>>[
    AnnouncementModel(
      id: 'a1',
      title: 'Eid ul Adha namaz will be held at the Eidgah this year',
      message: List<String>.filled(20, 'Please come early.').join(' '),
      createdAt: DateTime.utc(2026, 10, 8),
    ).toJson(),
    AnnouncementModel(
      id: 'a2',
      title: 'Cleaning',
      message: 'Sunday after Fajr.',
      createdAt: DateTime.utc(2026, 10, 2),
    ).toJson(),
  ],
  'meta': <String, dynamic>{
    'page': 1,
    'limit': 20,
    'total': 2,
    'totalPages': 1,
    'hasNextPage': false,
  },
}, AnnouncementModel.fromJson);

/// The U3 screens lay out without overflow in each language, on a phone
/// and on desktop, and with a large device font.
void main() {
  setUp(() {
    TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
  });
  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearAccessibilityFeaturesTestValue();
  });

  final screens = <String, Widget>{
    'change times': const UpdateNamazTimeScreen(
      initial: NamazTimeModel(
        fajr: '05:00 AM',
        zuhr: '12:45 PM',
        asr: '04:30 PM',
        maghrib: '06:10 PM',
        isha: '07:45 PM',
        jumma: '01:15 PM',
      ),
    ),
    'news': const AnnouncementsScreen(showAppBar: true),
    'add news': const AddAnnouncementScreen(),
  };
  const sizes = <String, Size>{
    'phone': Size(360, 780),
    'desktop': Size(1280, 900),
  };

  Future<void> pump(
    WidgetTester tester,
    Widget screen,
    Locale locale,
    Size size,
  ) async {
    final repository = _MockAnnouncementsRepository();
    when(
      () => repository.getAnnouncements(page: any(named: 'page')),
    ).thenAnswer((_) async => _page);
    await pumpUi(
      tester,
      screen,
      locale: locale,
      size: size,
      overrides: [
        announcementsRepositoryProvider.overrideWithValue(repository),
        authControllerProvider.overrideWith(_Manager.new),
      ],
    );
  }

  for (final screen in screens.entries) {
    for (final language in <String>['en', 'hi', 'ur']) {
      for (final size in sizes.entries) {
        testWidgets('${screen.key} in $language on a ${size.key}', (
          tester,
        ) async {
          await pump(tester, screen.value, Locale(language), size.value);
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('${screen.key} on a phone with a large device font', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pump(
        tester,
        screen.value,
        const Locale('ur'),
        const Size(360, 780),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
