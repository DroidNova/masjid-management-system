import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/finance/data/models/finance_summary_model.dart';

class FinanceSummaryCard extends StatelessWidget {
  const FinanceSummaryCard({super.key, required this.summary});

  final FinanceSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final total = summary.breakdown.total;
    final period = summary.breakdown.period;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Finance Summary',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              'Current Balance',
              summary.currentBalance,
              isStrong: true,
            ),
            _SummaryRow('Total Collection', summary.totalCollection),
            ..._breakdownRows(total),
            _SummaryRow('Total Expense', summary.totalExpense),
            const Divider(),
            _SummaryRow('This Month Collection', summary.thisMonthCollection),
            ..._breakdownRows(period),
            _SummaryRow('This Month Expense', summary.thisMonthExpense),
          ],
        ),
      ),
    );
  }

  /// Where a collection total comes from (the API's `breakdown`).
  List<Widget> _breakdownRows(FinanceTotals totals) => <Widget>[
    _SummaryRow(
      'General Collections',
      totals.generalCollections,
      isDetail: true,
    ),
    _SummaryRow(
      'Project Contributions',
      totals.projectContributions,
      isDetail: true,
    ),
    _SummaryRow(
      'Imam Salary Collected',
      totals.imamSalaryCollected,
      isDetail: true,
    ),
  ];
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
    this.label,
    this.amount, {
    this.isStrong = false,
    this.isDetail = false,
  });

  final String label;
  final double amount;
  final bool isStrong;

  /// An indented, smaller line that explains the row above it.
  final bool isDetail;

  @override
  Widget build(BuildContext context) {
    if (isDetail) {
      final detailStyle = Theme.of(context).textTheme.bodySmall;
      return Padding(
        padding: const EdgeInsets.only(left: 16, top: 2, bottom: 2),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label, style: detailStyle)),
            Text(AppFormat.rupees(amount), style: detailStyle),
          ],
        ),
      );
    }

    final style = TextStyle(
      fontWeight: isStrong ? FontWeight.bold : FontWeight.w600,
      fontSize: isStrong ? 18 : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(AppFormat.rupees(amount), style: style),
        ],
      ),
    );
  }
}
