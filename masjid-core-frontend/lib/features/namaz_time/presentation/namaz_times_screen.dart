import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/dashboard/application/dashboard_controller.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/namaz_time_summary.dart';
import 'package:masjid_core_frontend/features/namaz_time/application/prayer_schedule.dart';
import 'package:masjid_core_frontend/features/namaz_time/presentation/widgets/prayer_labels.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// All namaz times of the masjid, one big row per prayer with its picture,
/// the next one highlighted. People who may change the times get a button.
class NamazTimesScreen extends ConsumerWidget {
  const NamazTimesScreen({super.key, this.clock = DateTime.now});

  /// Overrides "now" in tests.
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dashboard = ref.watch(dashboardControllerProvider);
    final canUpdate = PermissionHelper.canUpdateNamazTime(
      ref.watch(currentPermissionsProvider),
    );

    return dashboard.when(
      skipLoadingOnRefresh: true,
      loading: () => const SingleChildScrollView(
        child: PageBody.form(child: SkeletonList()),
      ),
      error: (_, _) => EmptyState(
        icon: AppIcons.problem,
        tone: AppTones.problem,
        title: l10n.dashboardLoadFailed,
        actionLabel: l10n.tryAgain,
        onAction: () => ref.invalidate(dashboardControllerProvider),
      ),
      data: (data) {
        final times = data.namazTime;
        final now = clock();
        final next = nextPrayer(times, now);
        final nextToday = next != null && DateUtils.isSameDay(next.at, now)
            ? next.prayer.prayer
            : null;
        final rows = <(Prayer, String?)>[
          (Prayer.fajr, times?.fajr),
          (Prayer.zuhr, times?.zuhr),
          (Prayer.asr, times?.asr),
          (Prayer.maghrib, times?.maghrib),
          (Prayer.isha, times?.isha),
          (Prayer.jumma, times?.jumma),
        ];
        final note = times?.note?.trim() ?? '';
        final spoken = rows
            .map((row) {
              final time = parseNamazTime(row.$2);
              return time == null
                  ? null
                  : '${row.$1.label(l10n)} ${prayerTimeText(context, time)}';
            })
            .whereType<String>()
            .join('. ');

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(dashboardControllerProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: PageBody.form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (spoken.isNotEmpty)
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: ReadAloudButton(text: spoken),
                    ),
                  for (final (prayer, text) in rows)
                    _PrayerRow(
                      prayer: prayer,
                      time: parseNamazTime(text),
                      isNext: prayer == nextToday,
                    ),
                  if (note.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpace.s),
                    MessageBanner(text: note, kind: StatusKind.neutral),
                  ],
                  if (canUpdate) ...<Widget>[
                    const SizedBox(height: AppSpace.xl),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTones.namaz.color,
                      ),
                      onPressed: () => context.push(
                        '/namaz-time/update',
                        // Prefills the form; no second request.
                        extra: times ?? const NamazTimeSummary(),
                      ),
                      icon: const Icon(AppIcons.edit),
                      label: Text(l10n.changeTimes),
                    ),
                  ],
                  const SizedBox(height: AppSpace.xl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.prayer,
    required this.time,
    required this.isNext,
  });

  final Prayer prayer;
  final TimeOfDay? time;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final value = time;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.m),
      child: Card(
        color: isNext ? AppTones.namaz.container : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
          side: BorderSide(
            color: isNext ? AppTones.namaz.color : AppColors.border,
            width: isNext ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.l),
          child: Row(
            children: <Widget>[
              ToneIcon(icon: prayer.icon, tone: AppTones.namaz, size: 52),
              const SizedBox(width: AppSpace.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(prayer.label(l10n), style: textTheme.titleLarge),
                    if (isNext)
                      Text(
                        l10n.nextNamaz,
                        style: textTheme.labelMedium?.copyWith(
                          color: AppTones.namaz.color,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.s),
              // At the end, and shrinks with large text instead of
              // taking half the row.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    value == null ? '—' : prayerTimeText(context, value),
                    style: textTheme.headlineSmall?.copyWith(
                      color: value == null ? AppColors.textSecondary : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
