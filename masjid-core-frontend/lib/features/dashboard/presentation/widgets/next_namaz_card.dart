import 'dart:async';

import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/namaz_time_summary.dart';
import 'package:masjid_core_frontend/features/namaz_time/application/prayer_schedule.dart';
import 'package:masjid_core_frontend/features/namaz_time/presentation/widgets/prayer_labels.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// The top of Home: the next prayer in big digits with a live countdown,
/// and today's prayers in a row with the next one highlighted.
class NextNamazCard extends StatefulWidget {
  const NextNamazCard({
    super.key,
    required this.times,
    required this.onOpen,
    this.canUpdate = false,
    this.clock = DateTime.now,
  });

  final NamazTimeSummary? times;

  /// Opens the full times page (and, for editors, setting times).
  final VoidCallback onOpen;
  final bool canUpdate;

  /// Overrides "now" in tests.
  final DateTime Function() clock;

  @override
  State<NextNamazCard> createState() => _NextNamazCardState();
}

class _NextNamazCardState extends State<NextNamazCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // The countdown changes once a minute.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final now = widget.clock();
    final next = nextPrayer(widget.times, now);

    if (next == null) {
      return HeroCard(
        tone: AppTones.namaz,
        onTap: widget.canUpdate ? widget.onOpen : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(AppIcons.mosque, size: 56),
            const SizedBox(height: AppSpace.m),
            Text(
              l10n.namazTimesNotSet,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            if (widget.canUpdate) ...<Widget>[
              const SizedBox(height: AppSpace.l),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTones.namaz.color,
                ),
                onPressed: widget.onOpen,
                icon: const Icon(AppIcons.time),
                label: Text(l10n.setTimes),
              ),
            ],
          ],
        ),
      );
    }

    final name = next.prayer.prayer.label(l10n);
    final time = prayerTimeText(context, next.prayer.time);
    final countdown = countdownText(l10n, next.until);
    final today = prayersOfDay(
      widget.times,
      isFriday: now.weekday == DateTime.friday,
    );
    final nextIsToday = DateUtils.isSameDay(next.at, now);

    return HeroCard(
      tone: AppTones.namaz,
      onTap: widget.onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(next.prayer.prayer.icon, size: 56),
              const SizedBox(width: AppSpace.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.nextNamaz,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      name,
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        time,
                        style: textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(countdown),
                  ],
                ),
              ),
              ReadAloudButton(
                text: l10n.nextNamazSpoken(name, time, countdown),
                color: Colors.white,
              ),
            ],
          ),
          if (today.length > 1) ...<Widget>[
            const Divider(color: Colors.white24, height: AppSpace.xxl),
            Row(
              children: <Widget>[
                for (final prayer in today)
                  Expanded(
                    child: _PrayerColumn(
                      prayer: prayer,
                      highlighted:
                          nextIsToday && prayer.prayer == next.prayer.prayer,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PrayerColumn extends StatelessWidget {
  const _PrayerColumn({required this.prayer, required this.highlighted});

  final PrayerTime prayer;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s),
      decoration: BoxDecoration(
        color: highlighted ? Colors.white24 : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.s),
      ),
      child: Column(
        children: <Widget>[
          Icon(prayer.prayer.icon, size: 22),
          const SizedBox(height: AppSpace.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              prayer.prayer.label(l10n),
              style: textTheme.labelMedium?.copyWith(color: Colors.white),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              prayerTimeText(context, prayer.time),
              style: textTheme.labelSmall?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
