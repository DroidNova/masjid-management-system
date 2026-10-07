import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/features/contributions/application/my_contributions_controllers.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/imam_salary_month_card.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/paged_list_parts.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/payment_transaction_card.dart';
import 'package:masjid_core_frontend/shared/widgets/app_card.dart';

/// The signed-in member's imam salary payments for one month.
class ImamSalaryPaymentHistoryScreen extends ConsumerStatefulWidget {
  const ImamSalaryPaymentHistoryScreen({
    super.key,
    required this.month,
    required this.year,
  });

  final int month;
  final int year;

  @override
  ConsumerState<ImamSalaryPaymentHistoryScreen> createState() =>
      _ImamSalaryPaymentHistoryScreenState();
}

class _ImamSalaryPaymentHistoryScreenState
    extends ConsumerState<ImamSalaryPaymentHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  SalaryMonthRef get _period => (month: widget.month, year: widget.year);

  @override
  void initState() {
    super.initState();
    listenNearEnd(
      _scrollController,
      () => ref.read(myImamSalaryPaymentsProvider(_period).notifier).loadMore(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = myImamSalaryPaymentsProvider(_period);
    final payments = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: const Text('Imam Salary Payments')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(provider.notifier).refresh(),
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              monthLabel(widget.month, widget.year),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...pagedSection(
              value: payments,
              empty: const AppCard(
                child: Text(
                  'No payments found for this month.',
                  textAlign: TextAlign.center,
                ),
              ),
              onRetry: () => ref.invalidate(provider),
              onLoadMore: () => ref.read(provider.notifier).loadMore(),
              itemBuilder: (payment) =>
                  PaymentTransactionCard(payment: payment),
            ),
          ],
        ),
      ),
    );
  }
}
