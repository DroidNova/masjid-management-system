import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Where a masjid request is, as three stops on a line: sent, being
/// checked, approved or rejected. Done stops are green ticks, the current
/// one an amber clock, a rejection a red cross, future ones grey.
class RequestTimeline extends StatelessWidget {
  const RequestTimeline({
    super.key,
    required this.status,
    this.requestedAt,
    this.reviewedAt,
  });

  /// The API status: `PENDING`, `APPROVED`, or `REJECTED`.
  final String status;
  final DateTime? requestedAt;
  final DateTime? reviewedAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final normalized = status.toUpperCase();
    final approved = normalized == 'APPROVED';
    final rejected = normalized == 'REJECTED';
    final reviewed = approved || rejected;

    final stops = <_Stop>[
      _Stop(label: l10n.stepSent, date: requestedAt, state: _StopState.done),
      _Stop(
        label: l10n.stepChecking,
        state: reviewed ? _StopState.done : _StopState.current,
      ),
      _Stop(
        label: rejected ? l10n.stepRejected : l10n.stepApproved,
        date: reviewed ? reviewedAt : null,
        state: approved
            ? _StopState.done
            : rejected
            ? _StopState.failed
            : _StopState.future,
      ),
    ];

    return Column(
      children: <Widget>[
        for (var i = 0; i < stops.length; i++)
          _StopRow(stop: stops[i], isLast: i == stops.length - 1),
      ],
    );
  }
}

enum _StopState { done, current, failed, future }

class _Stop {
  const _Stop({required this.label, required this.state, this.date});

  final String label;
  final _StopState state;
  final DateTime? date;
}

class _StopRow extends StatelessWidget {
  const _StopRow({required this.stop, required this.isLast});

  final _Stop stop;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (IconData icon, Color color) = switch (stop.state) {
      _StopState.done => (AppIcons.done, AppTones.done.color),
      _StopState.current => (AppIcons.waiting, AppTones.waiting.color),
      _StopState.failed => (Icons.cancel_rounded, AppTones.problem.color),
      _StopState.future => (
        Icons.radio_button_unchecked_rounded,
        AppColors.border,
      ),
    };
    final date = stop.date;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            children: <Widget>[
              Icon(icon, color: color, size: 32),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    margin: const EdgeInsets.symmetric(vertical: AppSpace.xs),
                    color: stop.state == _StopState.done
                        ? AppTones.done.color
                        : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpace.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    stop.label,
                    style: textTheme.titleMedium?.copyWith(
                      color: stop.state == _StopState.future
                          ? AppColors.textSecondary
                          : null,
                    ),
                  ),
                  if (date != null)
                    Text(
                      AppFormat.date(date),
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
