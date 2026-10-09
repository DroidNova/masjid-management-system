import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/settings/app_settings.dart';
import 'package:masjid_core_frontend/core/settings/speaker.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/theme/app_theme.dart';
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

/// Pumps [child] inside the app's theme, localizations, and providers, on a
/// screen of [size] logical pixels.
Future<ProviderContainer> pumpUi(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  Size size = const Size(400, 900),
  Map<String, Object> prefs = const <String, Object>{},
  FakeSpeaker? speaker,
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
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.light(languageCode: locale.languageCode),
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}
