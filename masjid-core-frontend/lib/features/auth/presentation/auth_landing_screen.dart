import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/settings/app_settings.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// The start screen for people who are not logged in: two big tiles
/// (log in, register a masjid) and a link to track a registration.
class AuthLandingScreen extends ConsumerWidget {
  const AuthLandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final language = ref.watch(appSettingsProvider).language;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: PageBody.form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Change language: on the page rather than in a top bar,
                  // so it wraps instead of overflowing with large text.
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(
                        Uri(
                          path: '/language',
                          queryParameters: <String, String>{'from': '/auth'},
                        ).toString(),
                      ),
                      icon: const Icon(AppIcons.language),
                      label: Text(language?.nativeName ?? l10n.chooseLanguage),
                    ),
                  ),
                  const SizedBox(height: AppSpace.l),
                  ScreenHeader(
                    icon: AppIcons.mosque,
                    title: l10n.appTitle,
                    subtitle: l10n.appTagline,
                  ),
                  SizedBox(
                    height: 176,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: ActionTile(
                            icon: AppIcons.login,
                            label: l10n.login,
                            tone: AppTones.brand,
                            onTap: () => context.push('/login-phone'),
                          ),
                        ),
                        const SizedBox(width: AppSpace.m),
                        Expanded(
                          child: ActionTile(
                            icon: AppIcons.registerMasjid,
                            label: l10n.registerMasjid,
                            tone: AppTones.namaz,
                            onTap: () => context.push('/masjid-request'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.l),
                  TextButton.icon(
                    onPressed: () => context.push('/masjid-request/track'),
                    icon: const Icon(AppIcons.track),
                    label: Text(
                      l10n.trackRequest,
                      style: textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
