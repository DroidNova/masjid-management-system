import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/settings/app_settings.dart';
import 'package:masjid_core_frontend/features/auth/presentation/auth_landing_screen.dart';
import 'package:masjid_core_frontend/features/auth/presentation/login_password_screen.dart';
import 'package:masjid_core_frontend/features/auth/presentation/login_phone_screen.dart';
import 'package:masjid_core_frontend/features/auth/presentation/otp_screen.dart';
import 'package:masjid_core_frontend/features/language/presentation/language_screen.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/masjid_request_form_screen.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/masjid_request_submitted_screen.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/track_masjid_application_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';

import '../shared/ui/ui_test_helpers.dart';

/// Pumps the start screens behind a router, with no language chosen yet.
Future<ProviderContainer> _pumpRouter(
  WidgetTester tester,
  String location,
) async {
  tester.view.physicalSize = const Size(420, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(overrides: await testAppOverrides());
  // No language saved yet.
  await container.read(sharedPreferencesProvider).remove('settings.language');
  container.invalidate(appSettingsProvider);
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: location,
    routes: <RouteBase>[
      GoRoute(
        path: '/language',
        builder: (context, state) =>
            LanguageScreen(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthLandingScreen(),
      ),
      GoRoute(
        path: '/login-phone',
        builder: (context, state) => const LoginPhoneScreen(),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Consumer(
        builder: (context, ref, _) => MaterialApp.router(
          routerConfig: router,
          locale: ref.watch(appSettingsProvider).language?.locale,
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('picking a language saves it and continues', (tester) async {
    final container = await _pumpRouter(tester, '/language?from=%2Fauth');

    expect(find.text(LanguageScreen.title), findsOneWidget);
    await tester.tap(find.text('اردو'));
    await tester.pumpAndSettle();

    expect(container.read(appSettingsProvider).language, AppLanguage.urdu);
    expect(find.byType(AuthLandingScreen), findsOneWidget);
    // The start screen now speaks Urdu, right to left.
    expect(find.text('لاگ ان'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(AuthLandingScreen))),
      TextDirection.rtl,
    );
  });

  testWidgets('the start screen opens login and shows the language', (
    tester,
  ) async {
    final container = await _pumpRouter(tester, '/auth');
    await container
        .read(appSettingsProvider.notifier)
        .setLanguage(AppLanguage.hindi);
    await tester.pumpAndSettle();

    expect(find.text('हिन्दी'), findsOneWidget);
    await tester.tap(find.text('लॉग इन'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPhoneScreen), findsOneWidget);
  });

  group('every start screen lays out', () {
    // The loading spinner and placeholders never settle otherwise.
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
      'language': const LanguageScreen(),
      'landing': const AuthLandingScreen(),
      'phone': const LoginPhoneScreen(),
      'password': const LoginPasswordScreen(phone: '+919876543210'),
      'code': const OtpScreen(
        phone: '+919876543210',
        challengeId: 'c',
        otpLength: 4,
      ),
      'registration': const MasjidRequestFormScreen(),
      'sent': const MasjidRequestSubmittedScreen(),
      'track': const TrackMasjidApplicationScreen(),
    };
    const sizes = <String, Size>{
      'phone': Size(360, 780),
      'desktop': Size(1280, 900),
    };

    for (final screen in screens.entries) {
      for (final language in <String>['en', 'hi', 'ur']) {
        for (final size in sizes.entries) {
          testWidgets('${screen.key} in $language on a ${size.key}', (
            tester,
          ) async {
            await pumpUi(
              tester,
              screen.value,
              locale: Locale(language),
              size: size.value,
            );
            expect(tester.takeException(), isNull);
          });
        }
      }

      testWidgets('${screen.key} on a phone with a large device font', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpUi(tester, screen.value, size: const Size(360, 780));
        expect(tester.takeException(), isNull);
      });
    }
  });
}
