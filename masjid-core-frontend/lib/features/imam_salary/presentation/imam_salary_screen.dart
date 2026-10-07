import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/imam_salary/application/imam_salary_controllers.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/models/imam_salary_models.dart';
import 'package:masjid_core_frontend/features/imam_salary/presentation/widgets/salary_dialogs.dart';
import 'package:masjid_core_frontend/features/imam_salary/presentation/widgets/salary_widgets.dart';
import 'package:masjid_core_frontend/shared/widgets/not_allowed_view.dart';

/// Imam salary ledger. Committee: full ledger with actions. Imam: month
/// summary, read only. Member: own last 6 months.
class ImamSalaryScreen extends ConsumerWidget {
  const ImamSalaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = salaryViewFor(ref.watch(currentPermissionsProvider));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          view == SalaryView.member ? 'My Imam Salary History' : 'Imam Salary',
        ),
      ),
      body: switch (view) {
        SalaryView.committee => const _CommitteeLedger(),
        SalaryView.imam => const _ReadOnlyLedger(),
        SalaryView.member => const _MemberHistory(),
        SalaryView.none => const NotAllowedView(
          message: 'You do not have permission to view the imam salary.',
        ),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Month section: start button / summary + increase, or load error.
// ---------------------------------------------------------------------------

class _MonthSection extends ConsumerWidget {
  const _MonthSection({required this.canManage});

  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(salaryMonthProvider);
    return month.when(
      skipLoadingOnRefresh: true,
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SalaryLoadError(
        message: userMessage(error),
        onRetry: () => ref.invalidate(salaryMonthProvider),
      ),
      data: (salary) {
        if (salary == null) {
          if (!canManage) return const Text('No salary month found.');
          return FilledButton(
            onPressed: () => showDialog<bool>(
              context: context,
              builder: (_) => const StartSalaryMonthDialog(),
            ),
            child: const Text('Start Salary Month'),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SalaryMonthSummaryCard(month: salary),
            if (canManage)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => showDialog<bool>(
                    context: context,
                    builder: (_) => IncreaseSalaryDialog(month: salary),
                  ),
                  child: const Text('Increase Salary'),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Imam: read-only month summary.
// ---------------------------------------------------------------------------

class _ReadOnlyLedger extends ConsumerWidget {
  const _ReadOnlyLedger();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.read(salaryMonthProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          SalaryPeriodPicker(),
          SizedBox(height: 12),
          _MonthSection(canManage: false),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Committee: month header, search, and Assignments / Transactions tabs.
// ---------------------------------------------------------------------------

class _CommitteeLedger extends ConsumerWidget {
  const _CommitteeLedger();

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(salaryAssignmentsProvider)
      ..invalidate(salaryPaymentsProvider);
    await ref.read(salaryMonthProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    const SalaryPeriodPicker(),
                    const SizedBox(height: 12),
                    const _MonthSection(canManage: true),
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Search member name or phone',
                      ),
                      onSubmitted: (value) => ref
                          .read(salaryLedgerFilterProvider.notifier)
                          .update(
                            (f) => (
                              search: value.trim(),
                              status: f.status,
                              paymentMode: f.paymentMode,
                            ),
                          ),
                    ),
                    const TabBar(
                      tabs: <Widget>[
                        Tab(text: 'Assignments'),
                        Tab(text: 'Transactions'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverFillRemaining(
              child: TabBarView(
                children: <Widget>[_AssignmentsTab(), _PaymentsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Calls [onNearEnd] when the list scrolls within 300px of its end.
mixin _LoadMoreOnScroll<W extends ConsumerStatefulWidget> on ConsumerState<W> {
  final ScrollController scrollController = ScrollController();

  void onNearEnd();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.hasClients &&
          scrollController.position.extentAfter < 300) {
        onNearEnd();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}

class _AssignmentsTab extends ConsumerStatefulWidget {
  const _AssignmentsTab();

  @override
  ConsumerState<_AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends ConsumerState<_AssignmentsTab>
    with _LoadMoreOnScroll<_AssignmentsTab> {
  @override
  void onNearEnd() => ref.read(salaryAssignmentsProvider.notifier).loadMore();

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(
      salaryLedgerFilterProvider.select((filter) => filter.status),
    );
    final assignments = ref.watch(salaryAssignmentsProvider);

    return Column(
      children: <Widget>[
        DropdownButton<String?>(
          value: status,
          items: const <DropdownMenuItem<String?>>[
            DropdownMenuItem<String?>(child: Text('All')),
            DropdownMenuItem<String?>(
              value: SalaryStatus.paid,
              child: Text('Paid'),
            ),
            DropdownMenuItem<String?>(
              value: SalaryStatus.partial,
              child: Text('Partial'),
            ),
            DropdownMenuItem<String?>(
              value: SalaryStatus.unpaid,
              child: Text('Unpaid'),
            ),
          ],
          onChanged: (value) => ref
              .read(salaryLedgerFilterProvider.notifier)
              .update(
                (f) => (
                  search: f.search,
                  status: value,
                  paymentMode: f.paymentMode,
                ),
              ),
        ),
        Expanded(
          child: assignments.when(
            skipLoadingOnRefresh: true,
            skipLoadingOnReload: true,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => SalaryLoadError(
              message: userMessage(error),
              onRetry: () => ref.invalidate(salaryAssignmentsProvider),
            ),
            data: (state) => ListView.builder(
              controller: scrollController,
              itemCount: state.items.length + 1,
              itemBuilder: (context, i) {
                if (i < state.items.length) {
                  final assignment = state.items[i];
                  return SalaryAssignmentTile(
                    assignment: assignment,
                    onAddPayment: assignment.dueAmount > 0
                        ? () => showDialog<bool>(
                            context: context,
                            builder: (_) =>
                                AddSalaryPaymentDialog(assignment: assignment),
                          )
                        : null,
                  );
                }
                return _ListFooter(
                  isEmpty: state.items.isEmpty,
                  emptyText: 'No family heads found.',
                  loadingMore: state.loadingMore,
                  loadMoreError: state.loadMoreError,
                  onRetry: onNearEnd,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentsTab extends ConsumerStatefulWidget {
  const _PaymentsTab();

  @override
  ConsumerState<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends ConsumerState<_PaymentsTab>
    with _LoadMoreOnScroll<_PaymentsTab> {
  @override
  void onNearEnd() => ref.read(salaryPaymentsProvider.notifier).loadMore();

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(
      salaryLedgerFilterProvider.select((filter) => filter.paymentMode),
    );
    final payments = ref.watch(salaryPaymentsProvider);

    return Column(
      children: <Widget>[
        DropdownButton<String?>(
          value: mode,
          items: const <DropdownMenuItem<String?>>[
            DropdownMenuItem<String?>(child: Text('All modes')),
            DropdownMenuItem<String?>(value: 'CASH', child: Text('Cash')),
            DropdownMenuItem<String?>(value: 'ONLINE', child: Text('Online')),
          ],
          onChanged: (value) => ref
              .read(salaryLedgerFilterProvider.notifier)
              .update(
                (f) => (search: f.search, status: f.status, paymentMode: value),
              ),
        ),
        Expanded(
          child: payments.when(
            skipLoadingOnRefresh: true,
            skipLoadingOnReload: true,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => SalaryLoadError(
              message: userMessage(error),
              onRetry: () => ref.invalidate(salaryPaymentsProvider),
            ),
            data: (state) => ListView.builder(
              controller: scrollController,
              itemCount: state.items.length + 1,
              itemBuilder: (context, i) {
                if (i < state.items.length) {
                  return SalaryPaymentTile(payment: state.items[i]);
                }
                return _ListFooter(
                  isEmpty: state.items.isEmpty,
                  emptyText: 'No payments recorded.',
                  loadingMore: state.loadingMore,
                  loadMoreError: state.loadMoreError,
                  onRetry: onNearEnd,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({
    required this.isEmpty,
    required this.emptyText,
    required this.loadingMore,
    required this.loadMoreError,
    required this.onRetry,
  });

  final bool isEmpty;
  final String emptyText;
  final bool loadingMore;
  final Object? loadMoreError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loadingMore) {
      return const Center(child: CircularProgressIndicator());
    }
    if (loadMoreError != null) {
      return SalaryLoadError(
        message: userMessage(loadMoreError!),
        onRetry: onRetry,
      );
    }
    if (isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(emptyText)),
      );
    }
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Member: own last 6 months.
// ---------------------------------------------------------------------------

class _MemberHistory extends ConsumerWidget {
  const _MemberHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(mySalaryHistoryProvider);
    return RefreshIndicator(
      onRefresh: () => ref.read(mySalaryHistoryProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'Your last 6 months',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...history.when(
            skipLoadingOnRefresh: true,
            loading: () => const <Widget>[
              Center(child: CircularProgressIndicator()),
            ],
            error: (error, _) => <Widget>[
              SalaryLoadError(
                message: userMessage(error),
                onRetry: () => ref.invalidate(mySalaryHistoryProvider),
              ),
            ],
            data: (months) => months.isEmpty
                ? const <Widget>[Text('No salary contribution history found.')]
                : months.map((month) => _HistoryTile(month: month)).toList(),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.month});

  final MySalaryHistoryMonth month;

  @override
  Widget build(BuildContext context) {
    final h = month;
    return Card(
      child: ListTile(
        title: Text(AppFormat.monthYear(h.month, h.year)),
        subtitle: Text(
          'Expected ${AppFormat.rupees(h.expectedAmount)}  •  '
          'Paid ${AppFormat.rupees(h.paidAmount)}\n'
          'Due ${AppFormat.rupees(h.dueAmount)}  •  '
          '${h.payments.length} payment(s)',
        ),
        trailing: SalaryStatusChip(status: h.status),
        isThreeLine: true,
      ),
    );
  }
}
