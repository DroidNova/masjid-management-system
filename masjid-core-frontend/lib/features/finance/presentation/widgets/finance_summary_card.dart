import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/finance/data/models/finance_summary_model.dart';
import 'package:platform_core_frontend/features/finance/presentation/widgets/finance_labels.dart';

class FinanceSummaryCard extends StatelessWidget {
  const FinanceSummaryCard({super.key, required this.summary});

  final FinanceSummaryModel summary;

  @override
  Widget build(BuildContext context) {
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
            _SummaryRow('Current Balance', summary.currentBalance, isStrong: true),
            _SummaryRow('Total Collection', summary.totalCollection),
            _SummaryRow('Total Expense', summary.totalExpense),
            const Divider(),
            _SummaryRow('This Month Collection', summary.thisMonthCollection),
            _SummaryRow('This Month Expense', summary.thisMonthExpense),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.amount, {this.isStrong = false});

  final String label;
  final double amount;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isStrong ? FontWeight.bold : FontWeight.w600,
      fontSize: isStrong ? 18 : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(formatRupees(amount), style: style),
        ],
      ),
    );
  }
}
