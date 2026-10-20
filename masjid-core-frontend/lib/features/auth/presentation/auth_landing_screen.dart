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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BrandBackdrop(
              icon: AppIcons.mosque,
              // Change language: a light button on the green, so it wraps
              // instead of overflowing with large text.
              top: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
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
              child: Column(
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.appTitle,
                      style: textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    l10n.appTagline,
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            PageBody.form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 176,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: FadeSlideIn(
                            delay: const Duration(milliseconds: 250),
                            child: ActionTile(
                              icon: AppIcons.login,
                              label: l10n.login,
                              tone: AppTones.brand,
                              onTap: () => context.push('/login-phone'),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpace.m),
                        Expanded(
                          child: FadeSlideIn(
                            delay: const Duration(milliseconds: 330),
                            // Daily use; registering a masjid is rare
                            // and is a link below.
                            child: ActionTile(
                              icon: AppIcons.mosque,
                              label: l10n.masjidTimesTitle,
                              tone: AppTones.namaz,
                              onTap: () => context.push('/visit'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.l),
                  // Rare: registering a masjid and following that request.
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 400),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        TextButton(
                          onPressed: () => context.push('/masjid-request'),
                          child: Text(l10n.registerMasjid),
                        ),
                        Text(
                          '·',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.push('/masjid-request/track'),
                          child: Text(l10n.trackRequest),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
