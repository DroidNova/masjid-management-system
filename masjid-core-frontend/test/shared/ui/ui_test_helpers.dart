import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/settings/app_settings.dart';
import 'package:masjid_core_frontend/core/settings/speaker.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/theme/app_theme.dart';
import 'package:masjid_core_frontend/shared/ui/number_keypad.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records what would have been read aloud.
class FakeSpeaker implements Speaker {
  final List<(String, String)> spoken = <(String, String)>[];
  int stops = 0;

  @override
  Future<void> speak(String text, {required String languageCode}) async {
    spoken.add((text, languageCode));
  }

  @override
  Future<void> stop() async => stops++;
}

/// The app's localizations, for test apps built by hand.
const List<LocalizationsDelegate<Object>> testLocalizationsDelegates =
    <LocalizationsDelegate<Object>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

/// Provider overrides every screen needs: saved settings (with [prefs] as
/// stored values; English chosen unless given) and a silent speaker.
Future<List<Override>> testAppOverrides({
  Map<String, Object> prefs = const <String, Object>{},
  FakeSpeaker? speaker,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    'settings.language': 'en',
    ...prefs,
  });
  final preferences = await SharedPreferences.getInstance();
  return <Override>[
    sharedPreferencesProvider.overrideWithValue(preferences),
    speakerProvider.overrideWithValue(speaker ?? FakeSpeaker()),
  ];
}

/// Taps [digits] on the on-screen [NumberKeypad].
Future<void> tapKeypad(WidgetTester tester, String digits) async {
  for (final digit in digits.split('')) {
    await tester.tap(
      find.descendant(
        of: find.byType(NumberKeypad),
        matching: find.text(digit),
      ),
    );
    await tester.pump();
  }
}

/// Pumps [child] inside the app's theme, localizations, and providers, on a
/// screen of [size] logical pixels.
Future<ProviderContainer> pumpUi(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  Size size = const Size(400, 900),
  Map<String, Object> prefs = const <String, Object>{},
  FakeSpeaker? speaker,
  List<Override> overrides = const <Override>[],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(prefs);
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      speakerProvider.overrideWithValue(speaker ?? FakeSpeaker()),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.light(languageCode: locale.languageCode),
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

/// Opens [page] on top of a plain "Home" page (so `context.pop()` and the
/// back button work), with the app's localizations and providers. Routes
/// [extraRoutes] (path → page) are there too, for screens that navigate.
Future<ProviderContainer> pumpRouted(
  WidgetTester tester,
  Widget page, {
  List<Override> overrides = const <Override>[],
  Map<String, Widget> extraRoutes = const <String, Widget>{},
  Size size = const Size(420, 1400),
  Locale locale = const Locale('en'),
  Map<String, Object> prefs = const <String, Object>{},
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: <Override>[
      ...await testAppOverrides(prefs: prefs),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  final router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('Home')),
      ),
      GoRoute(path: '/page', builder: (_, _) => page),
      for (final route in extraRoutes.entries)
        GoRoute(path: route.key, builder: (_, _) => route.value),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        locale: locale,
        theme: AppTheme.light(languageCode: locale.languageCode),
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  unawaited(router.push('/page'));
  await tester.pumpAndSettle();
  return container;
}
