import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/ui/motion.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';
import 'package:masjid_core_frontend/shared/ui/tone_icon.dart';

/// The picture, title, and one short line at the top of a single-task
/// screen (enter phone, enter code...). The picture says what the screen
/// is for before any reading. [compact] (short screens, see
/// [isShortForKeypad]) uses a smaller picture and less space, so a keypad
/// screen fits without scrolling.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.tone = AppTones.brand,
    this.trailing,
    this.compact = false,
  });

  final bool compact;

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

    return FadeSlideIn(
      child: Column(
        children: <Widget>[
          if (compact)
            ToneIcon(icon: icon, tone: tone, size: 64, circle: true)
          else ...<Widget>[
            // Room for the glow, which spills 14 px around the picture.
            const SizedBox(height: 14),
            Breathing(
              color: tone.color,
              size: 116,
              child: ToneIcon(icon: icon, tone: tone, size: 88, circle: true),
            ),
          ],
          SizedBox(height: compact ? AppSpace.m : AppSpace.l + 6),
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
          SizedBox(height: compact ? AppSpace.l : AppSpace.xl),
        ],
      ),
    );
  }
}

/// True when a keypad screen's scrolling area is too short for the full
/// header and keypad (most phones with the 3-button bar). Pass the
/// area's height from a [LayoutBuilder].
bool isShortForKeypad(double height) => height < 640;
