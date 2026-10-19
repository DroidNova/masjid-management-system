import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/ui/motion.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// How far along something is, as a ring with the percent in the middle:
/// salary collected for the month, money raised for a project.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 112,
    this.color = Colors.white,
    this.trackColor = Colors.white24,
  });

  /// 0 to 1; values outside are clamped.
  final double value;
  final double size;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final clamped = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    final percent = (clamped * 100).round();
    return Semantics(
      value: '$percent%',
      child: _FillUp(value: clamped, builder: _ring),
    );
  }

  Widget _ring(BuildContext context, double shown) {
    final percent = (shown * 100).round();
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CircularProgressIndicator(
              value: shown,
              strokeWidth: size / 9,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: trackColor,
            ),
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: EdgeInsets.all(size / 6),
                  child: Text(
                    '$percent%',
                    textDirection: TextDirection.ltr,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: color),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A thick rounded progress bar for cards (project progress).
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.tone = AppTones.projects,
  });

  final double value;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    final clamped = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: _FillUp(
        value: clamped,
        builder: (context, shown) => LinearProgressIndicator(
          value: shown,
          minHeight: 12,
          color: tone.color,
          backgroundColor: tone.container,
        ),
      ),
    );
  }
}

/// Animates from empty (first time) or the old value to [value].
class _FillUp extends StatelessWidget {
  const _FillUp({required this.value, required this.builder});

  final double value;
  final Widget Function(BuildContext context, double shown) builder;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return builder(context, value);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, shown, _) => builder(context, shown),
    );
  }
}
