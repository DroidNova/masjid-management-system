import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';
import 'package:masjid_core_frontend/shared/ui/tone_icon.dart';

/// The picture, title, and one short line at the top of a single-task
/// screen (enter phone, enter code...). The picture says what the screen
/// is for before any reading.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.tone = AppTones.brand,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final AppTone tone;

  /// Next to the title, for example a [ReadAloudButton].
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final line = subtitle;
    final extra = trailing;

    return Column(
      children: <Widget>[
        ToneIcon(icon: icon, tone: tone, size: 88, circle: true),
        const SizedBox(height: AppSpace.l),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall,
                ),
              ),
            ),
            ?extra,
          ],
        ),
        if (line != null) ...<Widget>[
          const SizedBox(height: AppSpace.xs),
          Text(
            line,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppSpace.xl),
      ],
    );
  }
}
