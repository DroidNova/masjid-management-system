import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/app/router.dart';
import 'package:masjid_core_frontend/core/settings/app_settings.dart';
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

    final settings = ref.watch(appSettingsProvider);
    final language = settings.language;

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      // Null follows the device language until the person picks one.
      locale: language?.locale,
      theme: AppTheme.light(languageCode: language?.code ?? 'en'),
      builder: (context, child) => _TextSize(
        largeText: settings.largeText,
        child: child ?? const SizedBox.shrink(),
      ),
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

/// Applies the "Large text" setting on top of the device's text size, and
/// caps the total at 200% so layouts still fit (UI_REDESIGN_PLAN.md,
/// section 5).
class _TextSize extends StatelessWidget {
  const _TextSize({required this.largeText, required this.child});

  final bool largeText;
  final Widget child;

  static const double _largeTextFactor = 1.2;
  static const double _maxScale = 2;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final deviceScale = media.textScaler.scale(16) / 16;
    final scale = (deviceScale * (largeText ? _largeTextFactor : 1)).clamp(
      0.8,
      _maxScale,
    );
    return MediaQuery(
      data: media.copyWith(textScaler: TextScaler.linear(scale)),
      child: child,
    );
  }
}
