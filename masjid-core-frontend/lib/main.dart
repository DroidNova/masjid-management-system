import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:masjid_core_frontend/app/app.dart';
import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Date names for AppFormat (Indian English).
  await initializeDateFormatting('en_IN');

  final container = ProviderContainer();

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
