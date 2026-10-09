import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_controllers.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_dashboard_summary.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/super_admin_tab_controller.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// The super admin's first page: requests waiting (the main job), then
/// masjids and people in big numbers. Every card opens its tab.
class SuperAdminDashboardScreen extends ConsumerWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(adminDashboardProvider)
        .when(
          skipLoadingOnRefresh: true,
          skipLoadingOnReload: true,
          loading: () => const PageBody(child: SkeletonList(itemCount: 4)),
          error: (error, _) => ErrorState(
            error: error,
            onRetry: () => ref.invalidate(adminDashboardProvider),
          ),
          data: (summary) => RefreshIndicator(
            onRefresh: () =>
                ref.read(adminDashboardProvider.notifier).refresh(),
            child: _Content(summary: summary),
          ),
        );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.summary});

  final AdminDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final waiting = summary.pendingRequests;
    final white = textTheme.bodyLarge?.copyWith(color: Colors.white);
    final columns = ScreenSize.of(context) == ScreenSize.compact ? 2 : 4;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              HeroCard(
                tone: waiting > 0 ? AppTones.news : AppTones.done,
                onTap: () => selectSuperAdminTab(context, 1),
                child: Row(
                  children: <Widget>[
                    Icon(
                      waiting > 0 ? AppIcons.requests : AppIcons.done,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(width: AppSpace.l),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            waiting > 0
                                ? l10n.requestsWaiting(waiting)
                                : l10n.noRequestsWaiting,
                            style: textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${l10n.stepApproved} ${summary.approvedRequests}'
                            ' · ${l10n.stepRejected} ${summary.rejectedRequests}',
                            style: white,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              SectionHeader(title: l10n.tabMasjids, icon: AppIcons.mosque),
              _Numbers(
                columns: columns,
                onTap: () => selectSuperAdminTab(context, 2),
                numbers: <_Number>[
                  (l10n.all, summary.totalMasjids, AppTones.brand),
                  (l10n.stepApproved, summary.approvedMasjids, AppTones.done),
                  (
                    l10n.statusPending,
                    summary.pendingMasjids,
                    AppTones.waiting,
                  ),
                  (
                    l10n.statusSuspended,
                    summary.suspendedMasjids,
                    AppTones.problem,
                  ),
                ],
              ),
              SectionHeader(title: l10n.tabUsers, icon: AppIcons.people),
              _Numbers(
                columns: columns,
                onTap: () => selectSuperAdminTab(context, 3),
                numbers: <_Number>[
                  (l10n.all, summary.totalUsers, AppTones.people),
                  (l10n.statusActive, summary.activeUsers, AppTones.done),
                  (
                    l10n.statusInactive,
                    summary.inactiveUsers,
                    AppTones.neutral,
                  ),
                  (
                    l10n.statusSuspended,
                    summary.suspendedUsers,
                    AppTones.problem,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// (label, count, colour)
typedef _Number = (String, int, AppTone);

class _Numbers extends StatelessWidget {
  const _Numbers({
    required this.numbers,
    required this.columns,
    required this.onTap,
  });

  final List<_Number> numbers;
  final int columns;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            (constraints.maxWidth - AppSpace.m * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpace.m,
          runSpacing: AppSpace.m,
          children: <Widget>[
            for (final (label, count, tone) in numbers)
              SizedBox(
                width: width,
                child: Card(
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpace.l),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              '$count',
                              style: textTheme.headlineMedium?.copyWith(
                                color: tone.color,
                              ),
                            ),
                          ),
                          Text(label, style: textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
