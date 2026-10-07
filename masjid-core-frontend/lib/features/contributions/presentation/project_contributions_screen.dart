import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/contributions/application/contribution_list_controllers.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/contribution_form_dialog.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/contribution_transaction_card.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/paged_list_parts.dart';

/// Contributions to one project. Loads by [projectId], so it works from a
/// fresh URL; [projectTitle] (from route `extra`) is only shown until the
/// real title loads.
class ProjectContributionsScreen extends ConsumerStatefulWidget {
  const ProjectContributionsScreen({
    super.key,
    required this.projectId,
    this.projectTitle,
  });

  final String projectId;
  final String? projectTitle;

  @override
  ConsumerState<ProjectContributionsScreen> createState() =>
      _ProjectContributionsScreenState();
}

class _ProjectContributionsScreenState
    extends ConsumerState<ProjectContributionsScreen> {
  final ScrollController _scrollController = ScrollController();
  String _search = '';
  String? _paymentMode;

  ProjectContributionsQuery get _query =>
      (projectId: widget.projectId, search: _search, paymentMode: _paymentMode);

  @override
  void initState() {
    super.initState();
    listenNearEnd(
      _scrollController,
      () => ref.read(projectContributionsProvider(_query).notifier).loadMore(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openAddContribution() async {
    await showDialog<bool>(
      context: context,
      builder: (context) =>
          ContributionFormDialog.project(projectId: widget.projectId),
    );
    // The list reloads itself: recording marks DataScope.contributions.
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = PermissionHelper.canRecordContributions(
      ref.watch(currentPermissionsProvider),
    );
    final title =
        ref.watch(projectTitleProvider(widget.projectId)).valueOrNull ??
        widget.projectTitle ??
        'Project';
    final provider = projectContributionsProvider(_query);
    final contributions = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: Text('$title Contributions')),
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              onPressed: _openAddContribution,
              icon: const Icon(Icons.add),
              label: const Text('Add Contribution'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => ref.read(provider.notifier).refresh(),
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search name or phone',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) => setState(() => _search = value.trim()),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _paymentMode,
              decoration: const InputDecoration(labelText: 'Payment mode'),
              items: const <DropdownMenuItem<String?>>[
                DropdownMenuItem<String?>(child: Text('All')),
                DropdownMenuItem<String?>(value: 'CASH', child: Text('Cash')),
                DropdownMenuItem<String?>(
                  value: 'ONLINE',
                  child: Text('Online'),
                ),
              ],
              onChanged: (value) => setState(() => _paymentMode = value),
            ),
            const SizedBox(height: 12),
            ...pagedSection(
              value: contributions,
              empty: const Center(child: Text('No project contributions yet.')),
              onRetry: () => ref.invalidate(provider),
              onLoadMore: () => ref.read(provider.notifier).loadMore(),
              itemBuilder: (contribution) => ContributionTransactionCard(
                title: contribution.contributorName,
                subtitle: contribution.contributorPhone,
                amount: contribution.amount,
                paymentMode: contribution.paymentMode,
                paidAt: contribution.paidAt,
                collectedByName: contribution.collectedByName,
                note: contribution.note,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
