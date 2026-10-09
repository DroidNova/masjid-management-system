import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/ui/app_icons.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// What a status means, so colour and icon always agree.
enum StatusKind {
  done(AppIcons.done),
  waiting(AppIcons.waiting),
  problem(AppIcons.problem),
  neutral(AppIcons.info);

  const StatusKind(this.icon);

  final IconData icon;

  AppTone get tone => switch (this) {
    done => AppTones.done,
    waiting => AppTones.waiting,
    problem => AppTones.problem,
    neutral => AppTones.neutral,
  };
}

/// A small pill: icon + one word (Paid, Due, Active...).
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.kind, required this.label});

  final StatusKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tone = kind.tone;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpace.s,
        AppSpace.xs,
        AppSpace.m,
        AppSpace.xs,
      ),
      decoration: BoxDecoration(
        color: tone.container,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(kind.icon, size: 18, color: tone.color),
          const SizedBox(width: AppSpace.xs),
          // Wraps instead of overflowing in a narrow place.
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: tone.color),
            ),
          ),
        ],
      ),
    );
  }
}
