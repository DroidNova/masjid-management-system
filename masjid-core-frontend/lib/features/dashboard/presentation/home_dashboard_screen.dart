import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/dashboard/application/dashboard_controller.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/announcement_summary.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/finance_summary.dart';
import 'package:masjid_core_frontend/features/dashboard/presentation/widgets/next_namaz_card.dart';
import 'package:masjid_core_frontend/features/main_shell/main_tabs.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Home (UI_REDESIGN_PLAN.md, section 4): the next namaz, big picture
/// tiles for what this person may do, the latest news, and the balance.
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dashboard = ref.watch(dashboardControllerProvider);

    return dashboard.when(
      // Keep showing data during pull-to-refresh.
      skipLoadingOnRefresh: true,
      loading: () => const _HomeSkeleton(),
      error: (error, _) {
        final noMasjid =
            error is ApiException &&
            error.code == ApiErrorCodes.userMasjidNotAssigned;
        if (noMasjid) {
          return EmptyState(
            icon: AppIcons.mosque,
            title: l10n.noMasjidAssigned,
            actionLabel: l10n.logout,
            actionIcon: AppIcons.logout,
            onAction: () => ref.read(authControllerProvider.notifier).signOut(),
          );
        }
        return EmptyState(
          icon: AppIcons.problem,
          tone: AppTones.problem,
          title: l10n.dashboardLoadFailed,
          actionLabel: l10n.tryAgain,
          onAction: () => ref.invalidate(dashboardControllerProvider),
        );
      },
      data: (data) => _HomeContent(dashboard: data),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.dashboard});

  final DashboardResponse dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final permissions = ref.watch(currentPermissionsProvider);
    final canUpdateTimes = PermissionHelper.canUpdateNamazTime(permissions);
    final finance = dashboard.financeSummary;
    final news = dashboard.latestAnnouncements;

    final hero = NextNamazCard(
      times: dashboard.namazTime,
      canUpdate: canUpdateTimes,
      onOpen: () => context.go(MainTab.times.path),
    );
    final latest = news.isEmpty ? null : _LatestNewsCard(item: news.first);

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: PageBody(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 840;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (wide && latest != null)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(child: hero),
                          const SizedBox(width: AppSpace.l),
                          Expanded(child: latest),
                        ],
                      ),
                    )
                  else
                    hero,
                  const SizedBox(height: AppSpace.xl),
                  ActionTileGrid(
                    tiles: homeActions(context, permissions)
                        .map(
                          (action) => ActionTile(
                            icon: action.icon,
                            label: action.label,
                            tone: action.tone,
                            onTap: action.onTap,
                          ),
                        )
                        .toList(),
                  ),
                  if (!wide && latest != null) ...<Widget>[
                    SectionHeader(
                      title: l10n.latestNews,
                      icon: AppIcons.announcements,
                      actionLabel: l10n.seeAll,
                      onAction: () => context.go(MainTab.news.path),
                    ),
                    latest,
                  ],
                  if (finance != null) ...<Widget>[
                    SectionHeader(
                      title: l10n.masjidBalance,
                      icon: AppIcons.money,
                    ),
                    _BalanceCard(
                      finance: finance,
                      onTap: PermissionHelper.canManageFinance(permissions)
                          ? () => context.go(MainTab.money.path)
                          : null,
                    ),
                  ],
                  const SizedBox(height: AppSpace.xl),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// One Home tile.
@immutable
class HomeAction {
  const HomeAction({
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final AppTone tone;
  final VoidCallback onTap;
}

/// The Home tiles this person may use, in a fixed order, by permission
/// (never role names).
List<HomeAction> homeActions(BuildContext context, List<String> permissions) {
  final l10n = AppLocalizations.of(context);
  bool can(bool Function(List<String>) check) => check(permissions);

  return <HomeAction>[
    if (can(PermissionHelper.canManageCollections))
      HomeAction(
        icon: AppIcons.moneyIn,
        label: l10n.moneyIn,
        tone: AppTones.moneyIn,
        onTap: () => context.push('/finance/add-collection'),
      ),
    if (can(PermissionHelper.canManageExpenses))
      HomeAction(
        icon: AppIcons.moneyOut,
        label: l10n.moneyOut,
        tone: AppTones.moneyOut,
        onTap: () => context.push('/finance/add-expense'),
      ),
    if (can(PermissionHelper.canViewImamSalary))
      HomeAction(
        icon: AppIcons.salary,
        label: l10n.salary,
        tone: AppTones.salary,
        onTap: () => context.push('/imam-salaries'),
      ),
    if (can(PermissionHelper.canUpdateNamazTime))
      HomeAction(
        icon: AppIcons.fajr,
        label: l10n.tabTimes,
        tone: AppTones.namaz,
        onTap: () => context.go(MainTab.times.path),
      ),
    HomeAction(
      icon: AppIcons.announcements,
      label: l10n.tabNews,
      tone: AppTones.news,
      onTap: () => context.go(MainTab.news.path),
    ),
    HomeAction(
      icon: AppIcons.projects,
      label: l10n.tabProjects,
      tone: AppTones.projects,
      onTap: () => context.go(MainTab.projects.path),
    ),
    if (can(PermissionHelper.canViewOwnContributions))
      HomeAction(
        icon: AppIcons.myPayments,
        label: l10n.tabMyPayments,
        tone: AppTones.people,
        onTap: () => context.go(MainTab.myPayments.path),
      ),
  ];
}

class _LatestNewsCard extends StatelessWidget {
  const _LatestNewsCard({required this.item});

  final AnnouncementSummary item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final title = item.title?.trim() ?? '';
    final message = item.message?.trim() ?? '';
    final date = DateTime.tryParse(item.createdAt ?? '');

    return Card(
      color: AppTones.news.container,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.l),
      ),
      child: InkWell(
        onTap: () => context.go(MainTab.news.path),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(AppIcons.announcements, color: AppTones.news.color),
                  const SizedBox(width: AppSpace.s),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                  ),
                  ReadAloudButton(
                    text: <String>[
                      title,
                      message,
                    ].where((part) => part.isNotEmpty).join('. '),
                    color: AppTones.news.color,
                  ),
                ],
              ),
              if (message.isNotEmpty)
                Text(
                  message,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyLarge,
                ),
              if (date != null) ...<Widget>[
                const SizedBox(height: AppSpace.s),
                Text(
                  AppFormat.date(date),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.finance, this.onTap});

  final FinanceSummary finance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final balance = finance.currentBalance;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AmountText(
                balance,
                size: AmountSize.hero,
                color: balance < 0
                    ? AppTones.moneyOut.color
                    : AppTones.moneyIn.color,
              ),
              const SizedBox(height: AppSpace.m),
              Text(
                l10n.thisMonth,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpace.xs),
              Wrap(
                spacing: AppSpace.xl,
                runSpacing: AppSpace.s,
                children: <Widget>[
                  _MonthFigure(
                    icon: AppIcons.moneyIn,
                    tone: AppTones.moneyIn,
                    amount: finance.thisMonthCollection,
                    kind: AmountKind.moneyIn,
                  ),
                  _MonthFigure(
                    icon: AppIcons.moneyOut,
                    tone: AppTones.moneyOut,
                    amount: finance.thisMonthExpense,
                    kind: AmountKind.moneyOut,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthFigure extends StatelessWidget {
  const _MonthFigure({
    required this.icon,
    required this.tone,
    required this.amount,
    required this.kind,
  });

  final IconData icon;
  final AppTone tone;
  final double amount;
  final AmountKind kind;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: tone.color),
        const SizedBox(width: AppSpace.xs),
        Flexible(
          child: AmountText(amount, kind: kind, size: AmountSize.small),
        ),
      ],
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SkeletonBox(height: 220, radius: AppRadius.l),
            SizedBox(height: AppSpace.xl),
            Row(
              children: <Widget>[
                Expanded(child: SkeletonBox(height: 150, radius: AppRadius.l)),
                SizedBox(width: AppSpace.m),
                Expanded(child: SkeletonBox(height: 150, radius: AppRadius.l)),
              ],
            ),
            SizedBox(height: AppSpace.xl),
            SkeletonBox(height: 120, radius: AppRadius.l),
          ],
        ),
      ),
    );
  }
}
