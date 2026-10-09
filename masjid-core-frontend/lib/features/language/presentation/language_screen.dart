import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/settings/app_settings.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// The very first screen: pick the app's language (UI_REDESIGN_PLAN.md,
/// rule 12). Each language is written in its own script with a big letter,
/// so people find theirs without reading English. Also opened from Profile.
///
/// [from] is where to continue afterwards; without it the screen goes back
/// (when opened from Profile) or to the start screen.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key, this.from});

  final String? from;

  /// The question in all three languages: nobody has chosen one yet.
  static const String title = 'भाषा चुनें  ·  زبان چنیں  ·  Choose language';

  static const Map<AppLanguage, String> _letters = <AppLanguage, String>{
    AppLanguage.hindi: 'अ',
    AppLanguage.urdu: 'ا',
    AppLanguage.english: 'A',
  };

  static const Map<AppLanguage, AppTone> _tones = <AppLanguage, AppTone>{
    AppLanguage.hindi: AppTones.news,
    AppLanguage.urdu: AppTones.brand,
    AppLanguage.english: AppTones.namaz,
  };

  Future<void> _choose(
    BuildContext context,
    WidgetRef ref,
    AppLanguage language,
  ) async {
    await ref.read(appSettingsProvider.notifier).setLanguage(language);
    if (!context.mounted) return;
    final next = from;
    if (next != null && next.startsWith('/')) {
      context.go(next);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appSettingsProvider).language;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: Navigator.canPop(context) ? AppBar() : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: PageBody.form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const ScreenHeader(icon: AppIcons.language, title: title),
                  for (final language in AppLanguage.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.m),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.l),
                          side: BorderSide(
                            color: language == current
                                ? AppTones.brand.color
                                : AppColors.border,
                            width: language == current ? 3 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => _choose(context, ref, language),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpace.l),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 64,
                                  height: 64,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _tones[language]!.container,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    _letters[language]!,
                                    style: textTheme.headlineMedium?.copyWith(
                                      color: _tones[language]!.color,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpace.l),
                                Expanded(
                                  child: Text(
                                    language.nativeName,
                                    style: textTheme.headlineSmall,
                                  ),
                                ),
                                if (language == current)
                                  Icon(
                                    AppIcons.done,
                                    size: 32,
                                    color: AppTones.brand.color,
                                  ),
                              ],
                            ),
                          ),
                        ),
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
