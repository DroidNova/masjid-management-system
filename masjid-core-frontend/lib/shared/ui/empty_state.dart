import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';
import 'package:masjid_core_frontend/shared/ui/tone_icon.dart';

/// A big picture, one short sentence, and at most one button. Used for
/// empty lists, errors, "no internet", and "not allowed" (rule 10).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.tone = AppTones.neutral,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final AppTone tone;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final detail = message;
    final label = actionLabel;
    final buttonIcon = actionIcon;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ToneIcon(icon: icon, tone: tone, size: 112, circle: true),
              const SizedBox(height: AppSpace.xl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge,
              ),
              if (detail != null) ...<Widget>[
                const SizedBox(height: AppSpace.s),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (label != null && onAction != null) ...<Widget>[
                const SizedBox(height: AppSpace.xl),
                buttonIcon == null
                    ? FilledButton(onPressed: onAction, child: Text(label))
                    : FilledButton.icon(
                        onPressed: onAction,
                        icon: Icon(buttonIcon),
                        label: Text(label),
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
