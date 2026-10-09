import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/settings/app_settings.dart';
import 'package:masjid_core_frontend/core/settings/speaker.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/app_icons.dart';

/// A speaker button that reads [text] aloud in the app's language (rule 6).
/// Tapping again stops. Hidden when read-aloud is off in Profile.
class ReadAloudButton extends ConsumerWidget {
  const ReadAloudButton({super.key, required this.text, this.color});

  final String text;

  /// Icon colour; white on a [HeroCard].
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      appSettingsProvider.select((settings) => settings.readAloud),
    );
    if (!enabled) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final speaking = ref.watch(readAloudControllerProvider) == text;
    final controller = ref.read(readAloudControllerProvider.notifier);

    return IconButton(
      tooltip: speaking ? l10n.stopReading : l10n.readAloud,
      color: color,
      iconSize: 28,
      icon: Icon(speaking ? AppIcons.stopReading : AppIcons.readAloud),
      onPressed: () => speaking
          ? controller.stop()
          : controller.speak(
              text,
              languageCode: Localizations.localeOf(context).languageCode,
            ),
    );
  }
}
