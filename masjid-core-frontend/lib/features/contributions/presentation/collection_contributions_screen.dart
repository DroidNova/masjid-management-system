import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/contributions/application/contribution_list_controllers.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/collection_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/giver_tile.dart';
import 'package:masjid_core_frontend/features/finance/presentation/money_categories.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Givers: who gave money to the masjid's collections, newest first and
/// grouped by day, with search by name or phone and picture chips by kind.
class CollectionContributionsScreen extends ConsumerWidget {
  const CollectionContributionsScreen({super.key});

  void _update(
    WidgetRef ref,
    CollectionContributionsFilter Function(CollectionContributionsFilter) next,
  ) => ref.read(collectionContributionsFilterProvider.notifier).update(next);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final canAdd = PermissionHelper.canRecordContributions(
      ref.watch(currentPermissionsProvider),
    );
    final filter = ref.watch(collectionContributionsFilterProvider);
    final controller = ref.read(collectionContributionsProvider.notifier);
    final filtered =
        filter.search.isNotEmpty ||
        filter.collectionType != null ||
        filter.paymentMode != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.givers)),
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              backgroundColor: AppTones.moneyIn.color,
              foregroundColor: Colors.white,
              onPressed: () => context.push('/contributions/new'),
              icon: const Icon(AppIcons.add),
              label: Text(l10n.addGiver),
            )
          : null,
      body: PagedListView<CollectionContribution>(
        value: ref.watch(collectionContributionsProvider),
        bottomPadding: canAdd ? 96 : AppSpace.xl,
        dayOf: (item) => item.paidAt,
        onRefresh: controller.refresh,
        onLoadMore: controller.loadMore,
        onRetry: () => ref.invalidate(collectionContributionsProvider),
        header: <Widget>[
          TextField(
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(AppIcons.search),
              hintText: l10n.searchPeople,
            ),
            onSubmitted: (value) => _update(
              ref,
              (f) => (
                search: value.trim(),
                paymentMode: f.paymentMode,
                collectionType: f.collectionType,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.m),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                ChoiceChip(
                  label: Text(l10n.all),
                  selected: filter.collectionType == null,
                  onSelected: (_) => _update(
                    ref,
                    (f) => (
                      search: f.search,
                      paymentMode: f.paymentMode,
                      collectionType: null,
                    ),
                  ),
                ),
                for (final category in moneyInCategories) ...<Widget>[
                  const SizedBox(width: AppSpace.s),
                  ChoiceChip(
                    avatar: Icon(category.icon, size: 20),
                    label: Text(category.label(l10n)),
                    selected: filter.collectionType == category.value,
                    onSelected: (_) => _update(
                      ref,
                      (f) => (
                        search: f.search,
                        paymentMode: f.paymentMode,
                        collectionType: f.collectionType == category.value
                            ? null
                            : category.value,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        empty: listEmptyState(
          l10n: l10n,
          icon: AppIcons.zakat,
          tone: AppTones.moneyIn,
          title: l10n.noGiversYet,
          filtered: filtered,
          actionLabel: canAdd ? l10n.addGiver : null,
          onAction: () => context.push('/contributions/new'),
        ),
        itemBuilder: (context, item) => GiverTile(
          name: item.contributorName,
          phone: item.contributorPhone,
          amount: item.amount,
          paymentMode: item.paymentMode,
          kind: item.collectionType,
          note: item.note,
        ),
      ),
    );
  }
}
