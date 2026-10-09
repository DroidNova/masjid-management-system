import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:masjid_core_frontend/app/app.dart';
import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/core/settings/app_settings.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Date names for AppFormat (Indian English).
  await initializeDateFormatting('en_IN');

  _registerFontLicenses();

  // Loaded before the first frame so the saved language and text size apply
  // immediately, with no flash of English.
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  // One HTTP client for the whole app. When the server rejects the refresh
  // token, the auth state flips to signed-out and the router shows login.
  ApiClient.configure(
    tokenStorage: container.read(tokenStorageProvider),
    onSessionExpired: () =>
        container.read(authControllerProvider.notifier).handleSessionExpired(),
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MasjidCoreApp(),
    ),
  );
}

/// The bundled fonts are SIL OFL; their licences show on the app's licence
/// page next to the packages' ones.
void _registerFontLicenses() {
  const fonts = <String, String>{
    'Mukta': 'assets/fonts/OFL-Mukta.txt',
    'Noto Nastaliq Urdu': 'assets/fonts/OFL-NotoNastaliqUrdu.txt',
  };
  LicenseRegistry.addLicense(() async* {
    for (final entry in fonts.entries) {
      final text = await rootBundle.loadString(entry.value);
      yield LicenseEntryWithLineBreaks(<String>[entry.key], text);
    }
  });
}
