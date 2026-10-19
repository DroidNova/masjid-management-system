import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/contributions/application/my_contributions_controllers.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_contribution_summary.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/models/imam_salary_models.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Home card for a family head: is this month's imam salary paid? One big
/// picture (green tick or amber clock), one sentence, and what is still
/// owed from earlier months. Hidden for people with no salary months.
class MySalaryCard extends ConsumerWidget {
  const MySalaryCard({super.key, required this.onOpen});

  /// Opens My payments.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(myContributionSummaryProvider).valueOrNull;
    if (summary == null) return const SizedBox.shrink();
    final salary = summary.imamSalary;
    if (salary.monthsShown == 0 && salary.currentMonth == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.l),
      child: FadeSlideIn(
        delay: const Duration(milliseconds: 100),
        child: _Body(salary: salary, onOpen: onOpen),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.salary, required this.onOpen});

  final ImamSalaryContributionSummary salary;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final now = salary.currentMonth;
    final nowDue = now?.dueAmount ?? 0;
    final earlierDue = (salary.totalDue - nowDue).clamp(0, double.infinity);
    final allPaid = salary.totalDue <= 0;
    final thisMonthPaid = now != null && now.status == SalaryStatus.paid;

    // The big line answers "do I owe anything?"; the small lines say for
    // which months.
    final tone = allPaid ? AppTones.done : AppTones.waiting;
    final headline = allPaid
        ? (thisMonthPaid ? l10n.salaryPaidThisMonth : l10n.allSalaryPaid)
        : l10n.salaryDueTotal(AppFormat.rupees(salary.totalDue));
    final title = now == null
        ? l10n.salary
        : l10n.mySalaryTitle(AppFormat.monthYear(now.month, now.year));
    final share = now == null || now.expectedAmount <= 0
        ? (allPaid ? 1.0 : 0.0)
        : (now.paidAmount / now.expectedAmount).clamp(0.0, 1.0);
    // Detail lines only when something is owed.
    final details = <(String, AppTone)>[
      if (!allPaid && now != null)
        thisMonthPaid
            ? (l10n.salaryPaidThisMonth, AppTones.done)
            : (
                l10n.salaryToPayThisMonth(AppFormat.rupees(nowDue)),
                AppTones.waiting,
              ),
      if (!allPaid && earlierDue > 0 && now != null)
        (l10n.olderMonthsDue(AppFormat.rupees(earlierDue)), AppTones.problem),
    ];

    final icon = tone == AppTones.done ? AppIcons.done : AppIcons.waiting;
    return Pressable(
      pressedScale: 0.97,
      child: Card(
        color: tone.container,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
          side: BorderSide(
            color: tone.color.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.l),
            child: Row(
              children: <Widget>[
                _StatusDisc(
                  tone: tone,
                  icon: icon,
                  pulse: tone != AppTones.done,
                ),
                const SizedBox(width: AppSpace.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        headline,
                        style: textTheme.titleLarge?.copyWith(
                          color: tone.color,
                        ),
                      ),
                      const SizedBox(height: AppSpace.s),
                      _AnimatedBar(value: share, tone: tone),
                      for (final (line, lineTone) in details) ...<Widget>[
                        const SizedBox(height: AppSpace.xs),
                        Row(
                          children: <Widget>[
                            Icon(
                              lineTone == AppTones.done
                                  ? AppIcons.done
                                  : AppIcons.waiting,
                              size: 18,
                              color: lineTone.color,
                            ),
                            const SizedBox(width: AppSpace.xs),
                            Expanded(
                              child: Text(
                                line,
                                style: textTheme.titleSmall?.copyWith(
                                  color: lineTone.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                ReadAloudButton(
                  text: <String>[
                    title,
                    headline,
                    for (final (line, _) in details) line,
                  ].join('. '),
                  color: tone.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The round picture: white disc with the status icon, glowing softly while
/// something is still to pay.
class _StatusDisc extends StatelessWidget {
  const _StatusDisc({
    required this.tone,
    required this.icon,
    required this.pulse,
  });

  final AppTone tone;
  final IconData icon;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final disc = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: tone.color,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: tone.color.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 34),
    );
    if (!pulse) {
      return FadeSlideIn(
        scale: 0.4,
        offset: 0,
        duration: const Duration(milliseconds: 700),
        child: disc,
      );
    }
    return Breathing(color: tone.color, size: 80, child: disc);
  }
}

/// A rounded bar that fills from empty to [value] when it appears.
class _AnimatedBar extends StatelessWidget {
  const _AnimatedBar({required this.value, required this.tone});

  final double value;
  final AppTone tone;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        height: 10,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value),
          duration: reduceMotion(context)
              ? Duration.zero
              : const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => LinearProgressIndicator(
            value: v,
            backgroundColor: Colors.white,
            color: tone.color,
          ),
        ),
      ),
    );
  }
}
