import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/dashboard/application/dashboard_controller.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/dashboard_response.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/namaz_time_summary.dart';
import 'package:masjid_core_frontend/features/dashboard/presentation/widgets/announcement_preview_card.dart';
import 'package:masjid_core_frontend/features/dashboard/presentation/widgets/finance_summary_card.dart';
import 'package:masjid_core_frontend/features/dashboard/presentation/widgets/imam_salary_card.dart';
import 'package:masjid_core_frontend/features/dashboard/presentation/widgets/masjid_header_card.dart';
import 'package:masjid_core_frontend/features/dashboard/presentation/widgets/namaz_time_card.dart';
import 'package:masjid_core_frontend/features/dashboard/presentation/widgets/project_summary_card.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/widgets/app_button.dart';
import 'package:masjid_core_frontend/shared/widgets/loading_view.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dashboardState = ref.watch(dashboardControllerProvider);

    return dashboardState.when(
      // Keep showing data during pull-to-refresh.
      skipLoadingOnRefresh: true,
      loading: () => const LoadingView(),
      error: (error, _) {
        final noMasjid =
            error is ApiException &&
            error.code == ApiErrorCodes.userMasjidNotAssigned;
        return _DashboardErrorView(
          message: noMasjid ? l10n.noMasjidAssigned : l10n.dashboardLoadFailed,
          detail: noMasjid ? null : error.toString(),
          primaryButtonLabel: noMasjid ? 'Logout / Back to Login' : l10n.retry,
          onPrimaryPressed: noMasjid
              ? () => ref.read(authControllerProvider.notifier).signOut()
              : () => ref.invalidate(dashboardControllerProvider),
        );
      },
      data: (dashboard) => _DashboardContent(dashboard: dashboard),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.dashboard});

  final DashboardResponse dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(currentPermissionsProvider);
    final canUpdateNamazTime = PermissionHelper.canUpdateNamazTime(permissions);
    final canManageAnnouncements = PermissionHelper.canManageAnnouncements(
      permissions,
    );
    final canManageFinance = PermissionHelper.canManageFinance(permissions);
    final canManageProjects = PermissionHelper.canManageProjects(permissions);
    final canViewContributions = PermissionHelper.canViewOwnContributions(
      permissions,
    );

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(dashboardControllerProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  MasjidHeaderCard(
                    masjid: dashboard.masjid,
                    imam: dashboard.imam,
                    membersCount: dashboard.membersCount,
                  ),
                  const SizedBox(height: 12),
                  NamazTimeCard(namazTime: dashboard.namazTime),
                  if (canUpdateNamazTime) ...<Widget>[
                    const SizedBox(height: 8),
                    AppButton(
                      label: 'Update Namaz Time',
                      isOutlined: true,
                      onPressed: () async {
                        await context.push(
                          '/namaz-time/update',
                          // Prefills the form; no second request.
                          extra:
                              dashboard.namazTime ?? const NamazTimeSummary(),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  AnnouncementPreviewCard(
                    announcements: dashboard.latestAnnouncements,
                    onViewAll: () => context.push('/announcements'),
                    onAddAnnouncement: canManageAnnouncements
                        ? () => context.push('/announcements/add')
                        : null,
                  ),
                  const SizedBox(height: 12),
                  FinanceSummaryCard(financeSummary: dashboard.financeSummary),
                  if (canManageFinance) ...<Widget>[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        FilledButton.icon(
                          onPressed: () =>
                              context.push('/finance/add-collection'),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Collection'),
                        ),
                        FilledButton.icon(
                          onPressed: () => context.push('/finance/add-expense'),
                          icon: const Icon(Icons.remove),
                          label: const Text('Add Expense'),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  ProjectSummaryCard(
                    projectsSummary: dashboard.projectsSummary,
                  ),
                  if (canManageProjects) ...<Widget>[
                    const SizedBox(height: 8),
                    AppButton(
                      label: 'Add Project',
                      isOutlined: true,
                      onPressed: () => context.push('/projects/add'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ImamSalaryCard(salarySummary: dashboard.imamSalarySummary),
                  if (canViewContributions) ...<Widget>[
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.volunteer_activism_outlined),
                        title: const Text('My Contributions'),
                        subtitle: const Text(
                          'View your imam salary and donation history',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/contributions'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardErrorView extends StatelessWidget {
  const _DashboardErrorView({
    required this.message,
    required this.onPrimaryPressed,
    this.detail,
    this.primaryButtonLabel = 'Retry',
  });

  final String message;
  final String? detail;
  final String primaryButtonLabel;
  final VoidCallback onPrimaryPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.info_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (detail != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(detail!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 20),
                AppButton(
                  label: primaryButtonLabel,
                  onPressed: onPrimaryPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
