import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/finance/application/finance_entries_controller.dart';
import 'package:masjid_core_frontend/features/finance/application/finance_entry_controller.dart';
import 'package:masjid_core_frontend/features/finance/application/finance_summary_controller.dart';
import 'package:masjid_core_frontend/features/finance/data/models/collection_entry_model.dart';
import 'package:masjid_core_frontend/features/finance/data/models/expense_entry_model.dart';
import 'package:masjid_core_frontend/features/finance/data/models/finance_entry_filter.dart';
import 'package:masjid_core_frontend/features/finance/data/models/finance_summary_model.dart';
import 'package:masjid_core_frontend/features/finance/presentation/money_categories.dart';
import 'package:masjid_core_frontend/features/finance/presentation/widgets/money_entry_tile.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// The Money tab: the balance, big "Money in" / "Money out" buttons, links
/// to givers and the imam's salary, and the money in or out list grouped by
/// day, filtered by kind with picture chips.
class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  bool _showingOut = false;

  /// Money out is loaded the first time it is shown, then kept.
  bool _outOpened = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Both lists (and their filters) stay loaded while this screen is
    // open, so switching between money in and out is instant.
    ref.listen(collectionsFilterProvider, (_, _) {});
    ref.listen(expensesFilterProvider, (_, _) {});
    ref.listen(collectionsControllerProvider, (_, _) {});
    if (_outOpened) ref.listen(expensesControllerProvider, (_, _) {});
    // Kept alive so a failed cancel's error can be read and shown.
    ref.listen(financeEntryControllerProvider, (_, _) {});

    final summary = ref.watch(financeSummaryProvider);
    final summaryError = summary.hasError && !summary.isLoading
        ? summary.error
        : null;
    if (summaryError is ApiException &&
        summaryError.code == ApiErrorCodes.userMasjidNotAssigned) {
      return EmptyState(
        icon: AppIcons.mosque,
        title: l10n.noMasjidAssigned,
        actionLabel: l10n.logout,
        actionIcon: AppIcons.logout,
        onAction: () => ref.read(authControllerProvider.notifier).signOut(),
      );
    }

    final permissions = ref.watch(currentPermissionsProvider);
    final canIn = PermissionHelper.canManageCollections(permissions);
    final canOut = PermissionHelper.canManageExpenses(permissions);

    final header = <Widget>[
      _BalanceHero(summary: summary),
      if (canIn || canOut) ...<Widget>[
        const SizedBox(height: AppSpace.l),
        Row(
          children: <Widget>[
            if (canIn)
              Expanded(
                child: _BigMoneyButton(
                  label: l10n.moneyIn,
                  icon: AppIcons.moneyIn,
                  tone: AppTones.moneyIn,
                  onTap: () => context.push('/finance/add-collection'),
                ),
              ),
            if (canIn && canOut) const SizedBox(width: AppSpace.m),
            if (canOut)
              Expanded(
                child: _BigMoneyButton(
                  label: l10n.moneyOut,
                  icon: AppIcons.moneyOut,
                  tone: AppTones.moneyOut,
                  onTap: () => context.push('/finance/add-expense'),
                ),
              ),
          ],
        ),
      ],
      const SizedBox(height: AppSpace.l),
      Row(
        children: <Widget>[
          Expanded(
            child: _LinkCard(
              icon: AppIcons.zakat,
              label: l10n.givers,
              tone: AppTones.moneyIn,
              onTap: () => context.push('/finance/collection-contributions'),
            ),
          ),
          if (PermissionHelper.canViewImamSalary(permissions)) ...<Widget>[
            const SizedBox(width: AppSpace.m),
            Expanded(
              child: _LinkCard(
                icon: AppIcons.salary,
                label: l10n.salary,
                tone: AppTones.salary,
                onTap: () => context.push('/imam-salaries'),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: AppSpace.xl),
      SegmentedButton<bool>(
        showSelectedIcon: false,
        segments: <ButtonSegment<bool>>[
          ButtonSegment<bool>(
            value: false,
            icon: Icon(AppIcons.moneyIn, color: AppTones.moneyIn.color),
            label: Text(l10n.moneyIn),
          ),
          ButtonSegment<bool>(
            value: true,
            icon: Icon(AppIcons.moneyOut, color: AppTones.moneyOut.color),
            label: Text(l10n.moneyOut),
          ),
        ],
        selected: <bool>{_showingOut},
        onSelectionChanged: (selection) => setState(() {
          _showingOut = selection.first;
          if (_showingOut) _outOpened = true;
        }),
      ),
      const SizedBox(height: AppSpace.m),
      _KindChips(isExpense: _showingOut),
    ];

    return _showingOut
        ? _expenses(context, header, canOut)
        : _collections(context, header, canIn);
  }

  Widget _collections(BuildContext context, List<Widget> header, bool canAdd) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(collectionsControllerProvider.notifier);
    final filter = ref.watch(collectionsFilterProvider);
    return PagedListView<CollectionEntryModel>(
      value: ref.watch(collectionsControllerProvider),
      header: header,
      dayOf: (entry) => entry.collectedAt ?? entry.createdAt,
      onRefresh: _refresh,
      onLoadMore: controller.loadMore,
      onRetry: () => ref.invalidate(collectionsControllerProvider),
      empty: listEmptyState(
        l10n: l10n,
        icon: AppIcons.moneyIn,
        tone: AppTones.moneyIn,
        title: l10n.noMoneyInYet,
        filtered: filter != const FinanceEntryFilter(),
        actionLabel: canAdd ? l10n.moneyIn : null,
        onAction: () => context.push('/finance/add-collection'),
      ),
      itemBuilder: (context, entry) => MoneyEntryTile(
        type: entry.type,
        title: entry.title,
        note: entry.description,
        amount: entry.amount,
        date: entry.collectedAt ?? entry.createdAt,
        isExpense: false,
        cancelled: entry.isCancelled,
        onCancel: canAdd && !entry.isCancelled
            ? () => _cancel((notifier) => notifier.cancelCollection(entry.id))
            : null,
      ),
    );
  }

  Widget _expenses(BuildContext context, List<Widget> header, bool canAdd) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(expensesControllerProvider.notifier);
    final filter = ref.watch(expensesFilterProvider);
    return PagedListView<ExpenseEntryModel>(
      value: ref.watch(expensesControllerProvider),
      header: header,
      dayOf: (entry) => entry.spentAt ?? entry.createdAt,
      onRefresh: _refresh,
      onLoadMore: controller.loadMore,
      onRetry: () => ref.invalidate(expensesControllerProvider),
      empty: listEmptyState(
        l10n: l10n,
        icon: AppIcons.moneyOut,
        tone: AppTones.moneyOut,
        title: l10n.noMoneyOutYet,
        filtered: filter != const FinanceEntryFilter(),
        actionLabel: canAdd ? l10n.moneyOut : null,
        onAction: () => context.push('/finance/add-expense'),
      ),
      itemBuilder: (context, entry) => MoneyEntryTile(
        type: entry.type,
        title: entry.title,
        note: entry.description,
        amount: entry.amount,
        date: entry.spentAt ?? entry.createdAt,
        isExpense: true,
        cancelled: entry.isCancelled,
        onCancel: canAdd && !entry.isCancelled
            ? () => _cancel((notifier) => notifier.cancelExpense(entry.id))
            : null,
      ),
    );
  }

  /// Runs a cancel; on failure throws the server's error for the dialog.
  Future<void> _cancel(
    Future<bool> Function(FinanceEntryController notifier) action,
  ) async {
    final done = await action(
      ref.read(financeEntryControllerProvider.notifier),
    );
    if (!done) {
      throw ref.read(financeEntryControllerProvider).error ??
          StateError('cancel failed');
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(financeSummaryProvider);
    await (_showingOut
        ? ref.read(expensesControllerProvider.notifier).refresh()
        : ref.read(collectionsControllerProvider.notifier).refresh());
  }
}

/// The balance in big numbers, with this month's money in and out.
class _BalanceHero extends StatelessWidget {
  const _BalanceHero({required this.summary});

  final AsyncValue<FinanceSummaryModel> summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final data = summary.valueOrNull;

    if (data == null) {
      return summary.hasError
          ? MessageBanner(text: l10n.moneyLoadFailed)
          : const SkeletonBox(height: 180, radius: AppRadius.l);
    }

    final balance = data.currentBalance;
    final spoken =
        '${l10n.masjidBalance}: ${AmountText.format(balance)}. '
        '${l10n.thisMonth}: ${l10n.moneyIn} ${AmountText.format(data.thisMonthCollection)}, '
        '${l10n.moneyOut} ${AmountText.format(data.thisMonthExpense)}';

    return HeroCard(
      tone: balance < 0 ? AppTones.moneyOut : AppTones.brand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(AppIcons.money, size: 28),
              const SizedBox(width: AppSpace.s),
              Expanded(
                child: Text(
                  l10n.masjidBalance,
                  style: textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
              ReadAloudButton(text: spoken, color: Colors.white),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: AmountText(
              balance,
              size: AmountSize.hero,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpace.m),
          Text(
            l10n.thisMonth,
            style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpace.xs),
          Wrap(
            spacing: AppSpace.xl,
            runSpacing: AppSpace.s,
            children: <Widget>[
              _HeroFigure(
                icon: AppIcons.moneyIn,
                amount: data.thisMonthCollection,
                kind: AmountKind.moneyIn,
              ),
              _HeroFigure(
                icon: AppIcons.moneyOut,
                amount: data.thisMonthExpense,
                kind: AmountKind.moneyOut,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroFigure extends StatelessWidget {
  const _HeroFigure({
    required this.icon,
    required this.amount,
    required this.kind,
  });

  final IconData icon;
  final double amount;
  final AmountKind kind;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 22),
        const SizedBox(width: AppSpace.xs),
        Flexible(
          child: AmountText(amount, kind: kind, color: Colors.white),
        ),
      ],
    );
  }
}

/// A big coloured button with a picture: "Money in" (green), "Money out"
/// (red).
class _BigMoneyButton extends StatelessWidget {
  const _BigMoneyButton({
    required this.label,
    required this.icon,
    required this.tone,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final AppTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: tone.color,
        minimumSize: const Size.fromHeight(88),
        padding: const EdgeInsets.all(AppSpace.m),
      ),
      onPressed: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 36),
          const SizedBox(height: AppSpace.xs),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// A short card linking to another money page (givers, salary).
class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final AppTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.m),
          child: Row(
            children: <Widget>[
              ToneIcon(icon: icon, tone: tone, size: 44),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

/// "All" plus one chip per kind, each with its picture.
class _KindChips extends ConsumerWidget {
  const _KindChips({required this.isExpense});

  final bool isExpense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final provider = isExpense
        ? expensesFilterProvider
        : collectionsFilterProvider;
    final selected = ref.watch(provider).type;
    final categories = isExpense ? moneyOutCategories : moneyInCategories;

    void choose(String? type) => ref
        .read(provider.notifier)
        .update((filter) => filter.copyWith(type: type));

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          ChoiceChip(
            label: Text(l10n.all),
            selected: selected == null,
            onSelected: (_) => choose(null),
          ),
          for (final category in categories) ...<Widget>[
            const SizedBox(width: AppSpace.s),
            ChoiceChip(
              avatar: Icon(category.icon, size: 20),
              label: Text(category.label(l10n)),
              selected: selected == category.value,
              onSelected: (_) =>
                  choose(selected == category.value ? null : category.value),
            ),
          ],
        ],
      ),
    );
  }
}
