import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_controllers.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_dashboard_summary.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/super_admin_tab_controller.dart';
import 'package:masjid_core_frontend/shared/widgets/error_view.dart';
import 'package:masjid_core_frontend/shared/widgets/loading_view.dart';

class SuperAdminDashboardScreen extends ConsumerWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(adminDashboardProvider)
        .when(
          skipLoadingOnRefresh: true,
          skipLoadingOnReload: true,
          loading: () => const LoadingView(),
          error: (error, _) => ErrorView(
            title: 'Unable to load',
            message: userMessage(error),
            onRetry: () => ref.invalidate(adminDashboardProvider),
          ),
          data: (summary) => RefreshIndicator(
            onRefresh: () =>
                ref.read(adminDashboardProvider.notifier).refresh(),
            child: _DashboardContent(summary: summary),
          ),
        );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.summary});

  final AdminDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _card('Total Users', summary.totalUsers),
            _card('Active Users', summary.activeUsers),
            _card(
              'Inactive Users',
              summary.inactiveUsers + summary.suspendedUsers,
            ),
            _card('Total Masjids', summary.totalMasjids),
            _card('Pending Requests', summary.pendingRequests),
            _card('Approved Requests', summary.approvedRequests),
            _card('Rejected Requests', summary.rejectedRequests),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            FilledButton(
              onPressed: () => selectSuperAdminTab(context, 1),
              child: const Text('Masjid Requests'),
            ),
            FilledButton(
              onPressed: () => selectSuperAdminTab(context, 2),
              child: const Text('Masjids'),
            ),
            FilledButton(
              onPressed: () => selectSuperAdminTab(context, 3),
              child: const Text('Users'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _card(String title, int value) {
    return SizedBox(
      width: 190,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title),
              const SizedBox(height: 8),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
