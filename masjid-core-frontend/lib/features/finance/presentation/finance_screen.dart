import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
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
import 'package:masjid_core_frontend/features/finance/presentation/widgets/finance_entry_tile.dart';
import 'package:masjid_core_frontend/features/finance/presentation/widgets/finance_labels.dart';
import 'package:masjid_core_frontend/features/finance/presentation/widgets/finance_paged_entries.dart';
import 'package:masjid_core_frontend/features/finance/presentation/widgets/finance_summary_card.dart';
import 'package:masjid_core_frontend/shared/widgets/app_button.dart';
import 'package:masjid_core_frontend/shared/widgets/loading_view.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  int _selectedTab = 0;

  bool get _showingCollections => _selectedTab == 0;

  Future<void> _refresh() async {
    await Future.wait<void>(<Future<void>>[
      ref.read(financeSummaryProvider.notifier).refresh(),
      if (_showingCollections)
        ref.read(collectionsControllerProvider.notifier).refresh()
      else
        ref.read(expensesControllerProvider.notifier).refresh(),
    ]);
  }

  void _loadMore() {
    if (_showingCollections) {
      ref.read(collectionsControllerProvider.notifier).loadMore();
    } else {
      ref.read(expensesControllerProvider.notifier).loadMore();
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.extentAfter < 300) _loadMore();
    return false;
  }

  Future<void> _confirmCancel({
    required bool isExpense,
    required String id,
  }) async {
    final label = isExpense ? 'expense' : 'collection';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel ${isExpense ? 'Expense' : 'Collection'}'),
        content: Text(
          'This $label will be marked as cancelled and no longer counted '
          'in the totals.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Cancel ${isExpense ? 'Expense' : 'Collection'}'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final controller = ref.read(financeEntryControllerProvider.notifier);
    final ok = isExpense
        ? await controller.cancelExpense(id)
        : await controller.cancelCollection(id);
    if (!mounted) return;
    final error = ref.read(financeEntryControllerProvider).error;
    // Not ok and no error: another save was already running.
    if (!ok && error == null) return;
    final message = ok
        ? '${isExpense ? 'Expense' : 'Collection'} cancelled.'
        : userMessage(error!);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the mutation controller alive while a cancel is in flight.
    ref.watch(financeEntryControllerProvider);
    final summaryState = ref.watch(financeSummaryProvider);

    return summaryState.when(
      skipLoadingOnReload: true,
      loading: () => const LoadingView(),
      error: (error, _) {
        final noMasjid =
            error is ApiException &&
            error.code == ApiErrorCodes.userMasjidNotAssigned;
        if (noMasjid) {
          return _FinanceErrorView(
            message: 'You are not assigned to any masjid yet.',
            buttonLabel: 'Logout / Back to Login',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          );
        }
        return _FinanceErrorView(
          message: 'Unable to load finance data.',
          detail: userMessage(error),
          onPressed: () => ref.invalidate(financeSummaryProvider),
        );
      },
      data: _buildContent,
    );
  }

  Widget _buildContent(FinanceSummaryModel summary) {
    final permissions = ref.watch(currentPermissionsProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    FinanceSummaryCard(summary: summary),
                    const SizedBox(height: 12),
                    _ImamSalaryNavigationCard(
                      subtitle:
                          PermissionHelper.canManageImamSalary(permissions)
                          ? 'Manage salary paid/unpaid records'
                          : 'View salary paid/unpaid records',
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.volunteer_activism_outlined),
                        title: const Text('Collection Contributions'),
                        subtitle: const Text(
                          'View donations and contributor transactions',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            context.push('/finance/collection-contributions'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<int>(
                      segments: const <ButtonSegment<int>>[
                        ButtonSegment<int>(
                          value: 0,
                          label: Text('Collections'),
                        ),
                        ButtonSegment<int>(value: 1, label: Text('Expenses')),
                      ],
                      selected: <int>{_selectedTab},
                      onSelectionChanged: (selection) {
                        setState(() => _selectedTab = selection.first);
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_showingCollections)
                      _collectionsSection(permissions)
                    else
                      _expensesSection(permissions),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _collectionsSection(List<String> permissions) {
    final canManage = PermissionHelper.canManageCollections(permissions);
    final filter = ref.watch(collectionsFilterProvider);

    return _FinanceEntriesSection(
      title: 'Collections',
      buttonLabel: 'Add Collection',
      onAddPressed: canManage
          ? () => context.push('/finance/add-collection')
          : null,
      filter: _TypeFilter(
        labels: collectionTypeLabels,
        value: filter.type,
        onChanged: (type) => ref
            .read(collectionsFilterProvider.notifier)
            .update((current) => current.copyWith(type: type)),
      ),
      body: FinancePagedEntries<CollectionEntryModel>(
        state: ref.watch(collectionsControllerProvider),
        emptyMessage: _emptyMessage(filter, 'No collections added yet.'),
        onRetry: () => ref.invalidate(collectionsControllerProvider),
        onLoadMore: _loadMore,
        itemBuilder: (entry) => FinanceEntryTile(
          key: ValueKey<String>(entry.id),
          type: entry.type,
          amount: entry.amount,
          title: entry.title,
          description: entry.description,
          date: entry.collectedAt ?? entry.createdAt,
          status: entry.status,
          isExpense: false,
          onCancel: canManage && !entry.isCancelled
              ? () => _confirmCancel(isExpense: false, id: entry.id)
              : null,
        ),
      ),
    );
  }

  Widget _expensesSection(List<String> permissions) {
    final canManage = PermissionHelper.canManageExpenses(permissions);
    final filter = ref.watch(expensesFilterProvider);

    return _FinanceEntriesSection(
      title: 'Expenses',
      buttonLabel: 'Add Expense',
      onAddPressed: canManage
          ? () => context.push('/finance/add-expense')
          : null,
      filter: _TypeFilter(
        labels: expenseTypeLabels,
        value: filter.type,
        onChanged: (type) => ref
            .read(expensesFilterProvider.notifier)
            .update((current) => current.copyWith(type: type)),
      ),
      body: FinancePagedEntries<ExpenseEntryModel>(
        state: ref.watch(expensesControllerProvider),
        emptyMessage: _emptyMessage(filter, 'No expenses added yet.'),
        onRetry: () => ref.invalidate(expensesControllerProvider),
        onLoadMore: _loadMore,
        itemBuilder: (entry) => FinanceEntryTile(
          key: ValueKey<String>(entry.id),
          type: entry.type,
          amount: entry.amount,
          title: entry.title,
          description: entry.description,
          date: entry.spentAt ?? entry.createdAt,
          status: entry.status,
          isExpense: true,
          onCancel: canManage && !entry.isCancelled
              ? () => _confirmCancel(isExpense: true, id: entry.id)
              : null,
        ),
      ),
    );
  }

  String _emptyMessage(FinanceEntryFilter filter, String noEntries) =>
      filter == const FinanceEntryFilter()
      ? noEntries
      : 'No entries match this filter.';
}

/// "All types" plus one item per type.
class _TypeFilter extends StatelessWidget {
  const _TypeFilter({
    required this.labels,
    required this.value,
    required this.onChanged,
  });

  final Map<String, String> labels;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String?>(
      value: value,
      isExpanded: true,
      items: <DropdownMenuItem<String?>>[
        const DropdownMenuItem<String?>(child: Text('All types')),
        ...labels.entries.map(
          (entry) => DropdownMenuItem<String?>(
            value: entry.key,
            child: Text(entry.value),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _ImamSalaryNavigationCard extends StatelessWidget {
  const _ImamSalaryNavigationCard({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/imam-salaries'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.payments_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Imam Salary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinanceEntriesSection extends StatelessWidget {
  const _FinanceEntriesSection({
    required this.title,
    required this.buttonLabel,
    required this.filter,
    required this.body,
    this.onAddPressed,
  });

  final String title;
  final String buttonLabel;
  final VoidCallback? onAddPressed;
  final Widget filter;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onAddPressed != null)
                  FilledButton(
                    onPressed: onAddPressed,
                    child: Text(buttonLabel),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            filter,
            const SizedBox(height: 12),
            body,
          ],
        ),
      ),
    );
  }
}

class _FinanceErrorView extends StatelessWidget {
  const _FinanceErrorView({
    required this.message,
    required this.onPressed,
    this.detail,
    this.buttonLabel = 'Retry',
  });

  final String message;
  final String? detail;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final detailText = detail;
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
                  Icons.account_balance_wallet_outlined,
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
                if (detailText != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(detailText, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 20),
                AppButton(label: buttonLabel, onPressed: onPressed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
