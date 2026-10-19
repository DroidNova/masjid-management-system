import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// One choice in [PillTabs].
@immutable
class PillTab<T> {
  const PillTab({
    required this.value,
    required this.icon,
    required this.label,
    this.tone,
  });

  final T value;
  final IconData icon;
  final String label;

  /// Colour of the icon and label while picked; the main green otherwise.
  final AppTone? tone;
}

/// Two to four big side-by-side choices (Salary · Projects · Donations).
/// A white pill slides to the picked one. The picture sits above a
/// one-line label that shrinks to fit rather than breaking mid-word, so it
/// works with large text and long Hindi or Urdu words.
class PillTabs<T> extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onChanged,
  });

  final List<PillTab<T>> tabs;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final index = tabs
        .indexWhere((tab) => tab.value == selected)
        .clamp(0, tabs.length - 1);
    const inset = 4.0;

    return Container(
      height: 76,
      padding: const EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: AppTones.neutral.container,
        borderRadius: BorderRadius.circular(AppRadius.l),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / tabs.length;
          final pickedTone = tabs[index].tone ?? AppTones.brand;
          return Stack(
            children: <Widget>[
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                start: width * index,
                top: 0,
                bottom: 0,
                width: width,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.l - inset),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: pickedTone.color.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  for (final tab in tabs)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: tab.value == selected,
                        label: tab.label,
                        excludeSemantics: true,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.m),
                          onTap: () {
                            if (tab.value == selected) return;
                            HapticFeedback.selectionClick();
                            onChanged(tab.value);
                          },
                          child: _TabFace<T>(
                            tab: tab,
                            picked: tab.value == selected,
                            textTheme: textTheme,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabFace<T> extends StatelessWidget {
  const _TabFace({
    required this.tab,
    required this.picked,
    required this.textTheme,
  });

  final PillTab<T> tab;
  final bool picked;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final color = picked
        ? (tab.tone ?? AppTones.brand).color
        : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AnimatedScale(
            scale: picked ? 1.15 : 1,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: Icon(tab.icon, color: color, size: 24),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: (textTheme.labelLarge ?? const TextStyle()).copyWith(
                color: color,
                height: 1.2,
                fontWeight: picked ? FontWeight.w700 : FontWeight.w600,
              ),
              child: Text(tab.label, maxLines: 1),
            ),
          ),
        ],
      ),
    );
  }
}
