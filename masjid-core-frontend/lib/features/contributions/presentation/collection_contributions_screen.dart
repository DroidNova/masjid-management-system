import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/contributions/application/contribution_list_controllers.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/contribution_form_dialog.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/contribution_transaction_card.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/paged_list_parts.dart';

class CollectionContributionsScreen extends ConsumerStatefulWidget {
  const CollectionContributionsScreen({super.key});

  @override
  ConsumerState<CollectionContributionsScreen> createState() =>
      _CollectionContributionsScreenState();
}

class _CollectionContributionsScreenState
    extends ConsumerState<CollectionContributionsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    listenNearEnd(
      _scrollController,
      () => ref.read(collectionContributionsProvider.notifier).loadMore(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateFilter(
    CollectionContributionsFilter Function(CollectionContributionsFilter) next,
  ) {
    ref
        .read(collectionContributionsFilterProvider.notifier)
        .update((filter) => next(filter));
  }

  Future<void> _openAddContribution() async {
    await showDialog<bool>(
      context: context,
      builder: (context) => const ContributionFormDialog.collection(),
    );
    // The list reloads itself: recording marks DataScope.contributions.
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = PermissionHelper.canRecordContributions(
      ref.watch(currentPermissionsProvider),
    );
    final filter = ref.watch(collectionContributionsFilterProvider);
    final contributions = ref.watch(collectionContributionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Collection Contributions')),
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              onPressed: _openAddContribution,
              icon: const Icon(Icons.add),
              label: const Text('Add Contribution'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(collectionContributionsProvider.notifier).refresh(),
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
              onSubmitted: (value) => _updateFilter(
                (f) => (
                  search: value.trim(),
                  paymentMode: f.paymentMode,
                  collectionType: f.collectionType,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: filter.collectionType,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: <DropdownMenuItem<String?>>[
                      const DropdownMenuItem<String?>(child: Text('All types')),
                      ...collectionTypes.map(
                        (type) => DropdownMenuItem<String?>(
                          value: type,
                          child: Text(collectionTypeLabel(type)),
                        ),
                      ),
                    ],
                    onChanged: (value) => _updateFilter(
                      (f) => (
                        search: f.search,
                        paymentMode: f.paymentMode,
                        collectionType: value,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: filter.paymentMode,
                    decoration: const InputDecoration(labelText: 'Mode'),
                    items: const <DropdownMenuItem<String?>>[
                      DropdownMenuItem<String?>(child: Text('All')),
                      DropdownMenuItem<String?>(
                        value: 'CASH',
                        child: Text('Cash'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'ONLINE',
                        child: Text('Online'),
                      ),
                    ],
                    onChanged: (value) => _updateFilter(
                      (f) => (
                        search: f.search,
                        paymentMode: value,
                        collectionType: f.collectionType,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...pagedSection(
              value: contributions,
              empty: const Center(
                child: Text('No collection contributions yet.'),
              ),
              onRetry: () => ref.invalidate(collectionContributionsProvider),
              onLoadMore: () =>
                  ref.read(collectionContributionsProvider.notifier).loadMore(),
              itemBuilder: (contribution) => ContributionTransactionCard(
                title: contribution.contributorName,
                subtitle: collectionTypeLabel(contribution.collectionType),
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
