import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/contributions/application/my_contributions_controllers.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/collection_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_contribution_summary.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_imam_salary_month.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/project_contribution.dart';
import 'package:masjid_core_frontend/features/finance/presentation/money_categories.dart';
import 'package:masjid_core_frontend/features/imam_salary/presentation/imam_salary_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

enum _Section { salary, projects, donations }

/// My payments: everything this person gave, in big numbers, then their
/// imam salary months (with what is still due), project gifts, and
/// donations. The My payments tab shows it inside the app frame;
/// [showAppBar] is for the stand-alone page (`/contributions`).
class MyContributionsScreen extends ConsumerStatefulWidget {
  const MyContributionsScreen({super.key, this.showAppBar = false});

  final bool showAppBar;

  @override
  ConsumerState<MyContributionsScreen> createState() =>
      _MyContributionsScreenState();
}

class _MyContributionsScreenState extends ConsumerState<MyContributionsScreen> {
  _Section _section = _Section.salary;

  Future<void> _refresh() async {
    ref
      ..invalidate(myContributionSummaryProvider)
      ..invalidate(myImamSalaryMonthsProvider)
      ..invalidate(myProjectContributionsProvider)
      ..invalidate(myCollectionContributionsProvider);
    await ref.read(myContributionSummaryProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(myContributionSummaryProvider);

    final header = <Widget>[
      summary.when(
        skipLoadingOnRefresh: true,
        loading: () => const SkeletonBox(height: 200, radius: AppRadius.l),
        error: (_, _) => MessageBanner(
          text: l10n.myPaymentsLoadFailed,
          action: TextButton(
            onPressed: () => ref.invalidate(myContributionSummaryProvider),
            child: Text(l10n.tryAgain),
          ),
        ),
        data: (data) => _TotalsHero(summary: data),
      ),
      const SizedBox(height: AppSpace.l),
      SegmentedButton<_Section>(
        showSelectedIcon: false,
        segments: <ButtonSegment<_Section>>[
          ButtonSegment<_Section>(
            value: _Section.salary,
            icon: const Icon(AppIcons.salary),
            label: Text(l10n.salary),
          ),
          ButtonSegment<_Section>(
            value: _Section.projects,
            icon: const Icon(AppIcons.projects),
            label: Text(l10n.tabProjects),
          ),
          ButtonSegment<_Section>(
            value: _Section.donations,
            icon: const Icon(AppIcons.zakat),
            label: Text(l10n.donations),
          ),
        ],
        selected: <_Section>{_section},
        onSelectionChanged: (selection) =>
            setState(() => _section = selection.first),
      ),
      const SizedBox(height: AppSpace.s),
    ];

    final Widget list = switch (_section) {
      _Section.salary => PagedListView<MyImamSalaryMonth>(
        value: ref.watch(myImamSalaryMonthsProvider),
        header: header,
        onRefresh: _refresh,
        onLoadMore: ref.read(myImamSalaryMonthsProvider.notifier).loadMore,
        onRetry: () => ref.invalidate(myImamSalaryMonthsProvider),
        empty: EmptyState(
          icon: AppIcons.salary,
          tone: AppTones.salary,
          title: l10n.noSalaryHistory,
        ),
        itemBuilder: (context, month) => _SalaryMonthTile(
          month: month,
          onTap: month.paymentsCount > 0
              ? () => context.push(
                  '/contributions/imam-salary/${month.month}/${month.year}/payments',
                )
              : null,
        ),
      ),
      _Section.projects => PagedListView<ProjectContribution>(
        value: ref.watch(myProjectContributionsProvider),
        header: header,
        dayOf: (item) => item.paidAt,
        onRefresh: _refresh,
        onLoadMore: ref.read(myProjectContributionsProvider.notifier).loadMore,
        onRetry: () => ref.invalidate(myProjectContributionsProvider),
        empty: EmptyState(
          icon: AppIcons.projects,
          tone: AppTones.projects,
          title: l10n.noGiftsYet,
        ),
        itemBuilder: (context, item) => _GiftTile(
          icon: AppIcons.projects,
          tone: AppTones.projects,
          title: item.project?.title ?? l10n.tabProjects,
          amount: item.amount,
          paymentMode: item.paymentMode,
        ),
      ),
      _Section.donations => PagedListView<CollectionContribution>(
        value: ref.watch(myCollectionContributionsProvider),
        header: header,
        dayOf: (item) => item.paidAt,
        onRefresh: _refresh,
        onLoadMore: ref
            .read(myCollectionContributionsProvider.notifier)
            .loadMore,
        onRetry: () => ref.invalidate(myCollectionContributionsProvider),
        empty: EmptyState(
          icon: AppIcons.zakat,
          tone: AppTones.moneyIn,
          title: l10n.noGiftsYet,
        ),
        itemBuilder: (context, item) => _GiftTile(
          icon: moneyCategoryIcon(item.collectionType, isExpense: false),
          tone: AppTones.moneyIn,
          title: moneyCategoryLabel(l10n, item.collectionType),
          amount: item.amount,
          paymentMode: item.paymentMode,
        ),
      ),
    };

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: Text(l10n.tabMyPayments))
          : null,
      body: list,
    );
  }
}

/// Everything given, in big numbers, with the parts and what is due.
class _TotalsHero extends StatelessWidget {
  const _TotalsHero({required this.summary});

  final MyContributionSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final salary = summary.imamSalary;
    final total = AppFormat.rupees(summary.totalContributionAmount);
    final due = salary.totalDue;
    final white = textTheme.bodyLarge?.copyWith(color: Colors.white);

    return HeroCard(
      tone: AppTones.people,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(l10n.youGaveInTotal, style: white)),
              ReadAloudButton(
                text: due > 0
                    ? '${l10n.youGaveInTotal}: $total. ${l10n.salaryStillDue(AppFormat.rupees(due))}'
                    : '${l10n.youGaveInTotal}: $total',
                color: Colors.white,
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: AmountText(
              summary.totalContributionAmount,
              size: AmountSize.hero,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpace.m),
          Wrap(
            spacing: AppSpace.l,
            runSpacing: AppSpace.s,
            children: <Widget>[
              _Part(
                icon: AppIcons.salary,
                label: l10n.salary,
                amount: salary.totalPaid,
              ),
              _Part(
                icon: AppIcons.projects,
                label: l10n.tabProjects,
                amount: summary.projectContributionTotal,
              ),
              _Part(
                icon: AppIcons.zakat,
                label: l10n.donations,
                amount: summary.collectionContributionTotal,
              ),
            ],
          ),
          if (due > 0) ...<Widget>[
            const SizedBox(height: AppSpace.m),
            Container(
              padding: const EdgeInsets.all(AppSpace.m),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(AppRadius.s),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(AppIcons.waiting),
                  const SizedBox(width: AppSpace.s),
                  Expanded(
                    child: Text(
                      l10n.salaryStillDue(AppFormat.rupees(due)),
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Part extends StatelessWidget {
  const _Part({required this.icon, required this.label, required this.amount});

  final IconData icon;
  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 20),
        const SizedBox(width: AppSpace.xs),
        Flexible(
          child: Text(
            '$label ${AppFormat.rupees(amount)}',
            style: textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// One salary month of mine: badge, a bar, and what is still due.
class _SalaryMonthTile extends StatelessWidget {
  const _SalaryMonthTile({required this.month, this.onTap});

  final MyImamSalaryMonth month;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final (kind, label) = salaryStatusLook(l10n, month.status);
    final share = month.expectedAmount <= 0
        ? 0.0
        : month.paidAmount / month.expectedAmount;

    return Card(
      child: InkWell(
        onTap: onTap,
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
                      style: textTheme.titleMedium,
                    ),
                  ),
                  StatusBadge(kind: kind, label: label),
                  if (onTap != null) const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: AppSpace.s),
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
                  style: textTheme.titleSmall?.copyWith(
                    color: AppTones.waiting.color,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One gift of mine: what it was for, cash or online, and the amount.
class _GiftTile extends StatelessWidget {
  const _GiftTile({
    required this.icon,
    required this.tone,
    required this.title,
    required this.amount,
    required this.paymentMode,
  });

  final IconData icon;
  final AppTone tone;
  final String title;
  final double amount;
  final String paymentMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.m),
        child: Row(
          children: <Widget>[
            ToneIcon(icon: icon, tone: tone),
            const SizedBox(width: AppSpace.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: textTheme.titleMedium),
                  Text(
                    paymentModeLabel(l10n, paymentMode),
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.s),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: AmountText(
                amount,
                kind: AmountKind.moneyIn,
                size: AmountSize.small,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
