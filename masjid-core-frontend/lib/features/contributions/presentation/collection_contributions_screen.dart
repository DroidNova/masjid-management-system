import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/contributions/application/contribution_list_controllers.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/collection_contribution.dart';
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

/// One gift: the giver's avatar and name, what it was for, cash or online,
/// and the amount in green.
class GiverTile extends StatelessWidget {
  const GiverTile({
    super.key,
    required this.name,
    required this.amount,
    required this.paymentMode,
    this.phone,
    this.kind,
    this.note,
  });

  final String name;
  final String? phone;
  final double amount;
  final String paymentMode;

  /// The collection kind; null for project contributions.
  final String? kind;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final type = kind;
    final text = note?.trim() ?? '';
    final secondary = textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.m),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PersonAvatar(name: name),
            const SizedBox(width: AppSpace.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(name, style: textTheme.titleMedium),
                  Wrap(
                    spacing: AppSpace.m,
                    runSpacing: AppSpace.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      if (type != null && type.isNotEmpty)
                        _IconText(
                          icon: moneyCategoryIcon(type, isExpense: false),
                          text: moneyCategoryLabel(l10n, type),
                          style: secondary,
                        ),
                      _IconText(
                        icon: paymentModeIcon(paymentMode),
                        text: paymentModeLabel(l10n, paymentMode),
                        style: secondary,
                      ),
                    ],
                  ),
                  if (text.isNotEmpty)
                    Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: secondary,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.s),
            // At the end of the row; shrinks only for very big amounts.
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

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text, this.style});

  final IconData icon;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpace.xs),
        Flexible(child: Text(text, style: style)),
      ],
    );
  }
}
