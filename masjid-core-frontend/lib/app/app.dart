import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/app/router.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/theme/app_theme.dart';

/// Lets non-widget code (and widgets above a Scaffold) show snack bars.
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MasjidCoreApp extends ConsumerWidget {
  const MasjidCoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tell the user why they were signed out (e.g. session expired).
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthSignedOut && next.message != null) {
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(next.message!)),
        );
      }
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      routerConfig: ref.watch(routerProvider),
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
