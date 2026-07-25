import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/contributions/models/my_contribution_summary_model.dart';
import 'package:platform_core_frontend/features/finance/presentation/widgets/finance_labels.dart';
import 'package:platform_core_frontend/shared/widgets/app_card.dart';

class ContributionSummaryCard extends StatelessWidget {
  const ContributionSummaryCard({super.key, required this.summary});

  final ImamSalaryContributionSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final values = <(String, String)>[
      ('Total Expected', formatRupees(summary.totalExpected)),
      ('Total Paid', formatRupees(summary.totalPaid)),
      ('Total Due', formatRupees(summary.totalDue)),
      ('Paid Months', '${summary.paidMonths}'),
      ('Partial Months', '${summary.partialMonths}'),
      ('Unpaid Months', '${summary.unpaidMonths}'),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Imam Salary Summary', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width < 500 ? 2 : 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            children: values.map((value) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(value.$2, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(value.$1, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }
}
