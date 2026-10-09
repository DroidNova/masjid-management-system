import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/giver_tile.dart';
import 'package:masjid_core_frontend/features/imam_salary/application/imam_salary_controllers.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/models/imam_salary_models.dart';
import 'package:masjid_core_frontend/features/imam_salary/presentation/widgets/salary_sheets.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// The imam's salary. The committee sees the month's progress ring, every
/// family with a paid / due badge (tap a family that owes to record its
/// payment, the amount already filled in), and the payments; the imam sees
/// the month's progress; a member sees their own months.
class ImamSalaryScreen extends ConsumerWidget {
  const ImamSalaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final view = salaryViewFor(ref.watch(currentPermissionsProvider));
    return Scaffold(
      appBar: AppBar(
        title: Text(view == SalaryView.member ? l10n.mySalary : l10n.salary),
      ),
      body: switch (view) {
        SalaryView.committee => const _CommitteeLedger(),
        SalaryView.imam => const _ImamView(),
        SalaryView.member => const _MemberHistory(),
        SalaryView.none => EmptyState(
          icon: AppIcons.password,
          title: l10n.notAllowedTitle,
          message: l10n.notAllowedMessage,
        ),
      },
    );
  }
}

/// The paid / due look of a salary status.
(StatusKind, String) salaryStatusLook(AppLocalizations l10n, String status) =>
    switch (status) {
      SalaryStatus.paid => (StatusKind.done, l10n.salaryPaid),
      SalaryStatus.partial => (StatusKind.waiting, l10n.salaryPartlyPaid),
      _ => (StatusKind.problem, l10n.salaryNotPaid),
    };

class _PeriodStrip extends ConsumerWidget {
  const _PeriodStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(salaryPeriodProvider);
    return MonthStrip(
      month: period.month,
      year: period.year,
      onSelected: (month, year) =>
          ref.read(salaryPeriodProvider.notifier).state = (
            month: month,
            year: year,
          ),
    );
  }
}

/// The month at a glance: a ring of how much is collected, the amounts, and
/// how many families paid, paid part, or did not pay yet.
class SalaryHero extends StatelessWidget {
  const SalaryHero({super.key, required this.month});

  final ImamSalaryMonth month;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final share = month.totalExpected <= 0
        ? 0.0
        : month.totalCollected / month.totalExpected;
    final collected = AppFormat.rupees(month.totalCollected);
    final expected = AppFormat.rupees(month.totalExpected);
    final due = AppFormat.rupees(month.totalDue);
    final white = textTheme.bodyLarge?.copyWith(color: Colors.white);

    return HeroCard(
      tone: AppTones.salary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              ProgressRing(value: share, size: 104),
              const SizedBox(width: AppSpace.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(l10n.collected, style: white),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: AmountText(
                        month.totalCollected,
                        size: AmountSize.large,
                        color: Colors.white,
                      ),
                    ),
                    Text(l10n.outOf(expected), style: white),
                    if (month.totalDue > 0)
                      Text(
                        l10n.stillToPay(due),
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
              ReadAloudButton(
                text: l10n.salarySpoken(collected, expected, due),
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.l),
          Text(
            l10n.perFamily(AppFormat.rupees(month.amountPerHead)),
            style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpace.s),
          Wrap(
            spacing: AppSpace.s,
            runSpacing: AppSpace.s,
            children: <Widget>[
              _CountPill(
                icon: AppIcons.done,
                text: l10n.paidCount(month.paidCount),
              ),
              _CountPill(
                icon: AppIcons.waiting,
                text: l10n.partlyPaidCount(month.partialCount),
              ),
              _CountPill(
                icon: AppIcons.problem,
                text: l10n.notPaidCount(month.unpaidCount),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.m,
        vertical: AppSpace.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18),
          const SizedBox(width: AppSpace.xs),
          Flexible(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// The month's state for the header: loading, error, not started, or the
/// hero (with "Raise amount" for the committee).
List<Widget> _monthHeader(
  BuildContext context,
  WidgetRef ref, {
  required bool canManage,
}) {
  final l10n = AppLocalizations.of(context);
  final month = ref.watch(salaryMonthProvider);
  return month.when(
    skipLoadingOnRefresh: true,
    skipLoadingOnReload: true,
    loading: () => const <Widget>[
      SkeletonBox(height: 200, radius: AppRadius.l),
    ],
    error: (error, _) => <Widget>[
      MessageBanner(
        text: errorText(l10n, error),
        action: TextButton(
          onPressed: () => ref.invalidate(salaryMonthProvider),
          child: Text(l10n.tryAgain),
        ),
      ),
    ],
    data: (salary) {
      if (salary == null) {
        return <Widget>[
          SizedBox(
            height: 340,
            child: EmptyState(
              icon: AppIcons.salary,
              tone: AppTones.salary,
              title: l10n.salaryNotStarted,
              actionLabel: canManage ? l10n.startSalaryMonth : null,
              actionIcon: AppIcons.add,
              onAction: () => showStartMonthSheet(context),
            ),
          ),
        ];
      }
      return <Widget>[
        SalaryHero(month: salary),
        if (canManage)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: () => showRaiseAmountSheet(context, salary),
              icon: const Icon(Icons.trending_up_rounded),
              label: Text(l10n.raiseAmount),
            ),
          ),
      ];
    },
  );
}

class _ImamView extends ConsumerWidget {
  const _ImamView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(salaryMonthProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          PageBody.form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const _PeriodStrip(),
                const SizedBox(height: AppSpace.m),
                ..._monthHeader(context, ref, canManage: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommitteeLedger extends ConsumerStatefulWidget {
  const _CommitteeLedger();

  @override
  ConsumerState<_CommitteeLedger> createState() => _CommitteeLedgerState();
}

class _CommitteeLedgerState extends ConsumerState<_CommitteeLedger> {
  bool _showPayments = false;

  void _filter(SalaryLedgerFilter Function(SalaryLedgerFilter) next) =>
      ref.read(salaryLedgerFilterProvider.notifier).update(next);

  Future<void> _refresh() async {
    ref
      ..invalidate(salaryAssignmentsProvider)
      ..invalidate(salaryPaymentsProvider);
    await ref.read(salaryMonthProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final started = ref.watch(salaryMonthProvider).valueOrNull != null;
    final filter = ref.watch(salaryLedgerFilterProvider);

    final header = <Widget>[
      const _PeriodStrip(),
      const SizedBox(height: AppSpace.m),
      ..._monthHeader(context, ref, canManage: true),
      if (started) ...<Widget>[
        const SizedBox(height: AppSpace.m),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: <ButtonSegment<bool>>[
            ButtonSegment<bool>(
              value: false,
              icon: const Icon(AppIcons.people),
              label: Text(l10n.families),
            ),
            ButtonSegment<bool>(
              value: true,
              icon: const Icon(AppIcons.myPayments),
              label: Text(l10n.payments),
            ),
          ],
          selected: <bool>{_showPayments},
          onSelectionChanged: (selection) =>
              setState(() => _showPayments = selection.first),
        ),
        const SizedBox(height: AppSpace.m),
        TextField(
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            prefixIcon: const Icon(AppIcons.search),
            hintText: l10n.searchPeople,
          ),
          onSubmitted: (value) => _filter(
            (f) => (
              search: value.trim(),
              status: f.status,
              paymentMode: f.paymentMode,
            ),
          ),
        ),
        if (!_showPayments) ...<Widget>[
          const SizedBox(height: AppSpace.s),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                for (final (status, label) in <(String?, String)>[
                  (null, l10n.all),
                  (SalaryStatus.unpaid, l10n.salaryNotPaid),
                  (SalaryStatus.partial, l10n.salaryPartlyPaid),
                  (SalaryStatus.paid, l10n.salaryPaid),
                ]) ...<Widget>[
                  ChoiceChip(
                    avatar: status == null
                        ? null
                        : Icon(
                            salaryStatusLook(l10n, status).$1.icon,
                            size: 20,
                          ),
                    label: Text(label),
                    selected: filter.status == status,
                    onSelected: (_) => _filter(
                      (f) => (
                        search: f.search,
                        status: status,
                        paymentMode: f.paymentMode,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s),
                ],
              ],
            ),
          ),
        ],
      ],
    ];

    if (!started) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: <Widget>[PageBody.form(child: Column(children: header))],
        ),
      );
    }

    if (_showPayments) {
      final controller = ref.read(salaryPaymentsProvider.notifier);
      return PagedListView<SalaryPayment>(
        value: ref.watch(salaryPaymentsProvider),
        header: header,
        dayOf: (payment) => payment.paidAt,
        onRefresh: _refresh,
        onLoadMore: controller.loadMore,
        onRetry: () => ref.invalidate(salaryPaymentsProvider),
        empty: listEmptyState(
          l10n: l10n,
          icon: AppIcons.myPayments,
          tone: AppTones.salary,
          title: l10n.noPaymentsYet,
          filtered: filter.search.isNotEmpty,
        ),
        itemBuilder: (context, payment) => GiverTile(
          name: payment.memberName,
          phone: payment.memberPhone,
          amount: payment.amount,
          paymentMode: payment.paymentMode,
          note: payment.note,
        ),
      );
    }

    final controller = ref.read(salaryAssignmentsProvider.notifier);
    return PagedListView<SalaryAssignment>(
      value: ref.watch(salaryAssignmentsProvider),
      header: header,
      onRefresh: _refresh,
      onLoadMore: controller.loadMore,
      onRetry: () => ref.invalidate(salaryAssignmentsProvider),
      empty: listEmptyState(
        l10n: l10n,
        icon: AppIcons.people,
        tone: AppTones.salary,
        title: l10n.noFamiliesYet,
        filtered: filter.search.isNotEmpty || filter.status != null,
      ),
      itemBuilder: (context, assignment) => FamilyDueTile(
        assignment: assignment,
        onTap: assignment.dueAmount > 0
            ? () => showSalaryPaymentSheet(context, assignment)
            : null,
      ),
    );
  }
}

/// One family head: name, paid / due badge, and what is still owed. Tapping
/// a family that owes records its payment.
class FamilyDueTile extends StatelessWidget {
  const FamilyDueTile({super.key, required this.assignment, this.onTap});

  final SalaryAssignment assignment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final (kind, label) = salaryStatusLook(l10n, assignment.status);
    final owes = assignment.dueAmount > 0;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.m),
          child: Row(
            children: <Widget>[
              PersonAvatar(name: assignment.memberName),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(assignment.memberName, style: textTheme.titleMedium),
                    const SizedBox(height: AppSpace.xs),
                    StatusBadge(kind: kind, label: label),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.s),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      AppFormat.rupees(
                        owes ? assignment.dueAmount : assignment.paidAmount,
                      ),
                      textDirection: TextDirection.ltr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        color: owes
                            ? AppTones.waiting.color
                            : AppTones.done.color,
                      ),
                    ),
                    Text(
                      owes ? l10n.due : l10n.salaryPaid,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...<Widget>[
                const SizedBox(width: AppSpace.xs),
                Icon(Icons.chevron_right_rounded, color: AppTones.salary.color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberHistory extends ConsumerWidget {
  const _MemberHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(mySalaryHistoryProvider);
    return RefreshIndicator(
      onRefresh: () => ref.read(mySalaryHistoryProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          PageBody.form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: history.when(
                skipLoadingOnRefresh: true,
                loading: () => const <Widget>[SkeletonList(itemCount: 4)],
                error: (error, _) => <Widget>[
                  MessageBanner(
                    text: errorText(l10n, error),
                    action: TextButton(
                      onPressed: () => ref.invalidate(mySalaryHistoryProvider),
                      child: Text(l10n.tryAgain),
                    ),
                  ),
                ],
                data: (months) => months.isEmpty
                    ? <Widget>[
                        SizedBox(
                          height: 360,
                          child: EmptyState(
                            icon: AppIcons.salary,
                            tone: AppTones.salary,
                            title: l10n.noSalaryHistory,
                          ),
                        ),
                      ]
                    : months
                          .map((month) => MySalaryMonthCard(month: month))
                          .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One month of the member's own salary share: badge, a bar of how much
/// is paid, and each payment.
class MySalaryMonthCard extends StatelessWidget {
  const MySalaryMonthCard({super.key, required this.month});

  final MySalaryHistoryMonth month;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final (kind, label) = salaryStatusLook(l10n, month.status);
    final share = month.expectedAmount <= 0
        ? 0.0
        : month.paidAmount / month.expectedAmount;
    final secondary = textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.m),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      AppFormat.monthYear(month.month, month.year),
                      style: textTheme.titleLarge,
                    ),
                  ),
                  StatusBadge(kind: kind, label: label),
                ],
              ),
              const SizedBox(height: AppSpace.m),
              ProgressBar(value: share, tone: AppTones.salary),
              const SizedBox(height: AppSpace.s),
              Text(
                l10n.paidOutOf(
                  AppFormat.rupees(month.paidAmount),
                  AppFormat.rupees(month.expectedAmount),
                ),
                style: textTheme.bodyLarge,
              ),
              if (month.dueAmount > 0)
                Text(
                  l10n.stillToPay(AppFormat.rupees(month.dueAmount)),
                  style: textTheme.titleMedium?.copyWith(
                    color: AppTones.waiting.color,
                  ),
                ),
              for (final payment in month.payments)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.s),
                  child: Row(
                    children: <Widget>[
                      Icon(AppIcons.done, size: 18, color: AppTones.done.color),
                      const SizedBox(width: AppSpace.s),
                      Expanded(
                        child: Text(
                          payment.paidAt == null
                              ? AppFormat.rupees(payment.amount)
                              : '${AppFormat.rupees(payment.amount)} · ${AppFormat.date(payment.paidAt!)}',
                          style: secondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
