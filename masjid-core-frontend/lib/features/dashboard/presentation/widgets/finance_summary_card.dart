import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/finance_summary.dart';
import 'package:platform_core_frontend/features/dashboard/presentation/widgets/dashboard_format.dart';

class FinanceSummaryCard extends StatelessWidget {
  const FinanceSummaryCard({super.key, required this.financeSummary});

  final FinanceSummary? financeSummary;

  @override
  Widget build(BuildContext context) {
    final summary = financeSummary ?? FinanceSummary.empty();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Finance Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _AmountRow('Total Collection', summary.totalCollection),
            _AmountRow('Total Expense', summary.totalExpense),
            _AmountRow('Current Balance', summary.currentBalance),
            const Divider(),
            _AmountRow('This Month Collection', summary.thisMonthCollection),
            _AmountRow('This Month Expense', summary.thisMonthExpense),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow(this.label, this.amount);

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(
            formatRupees(amount),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
