import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_contribution_summary.dart';
import 'package:masjid_core_frontend/shared/widgets/app_card.dart';

class ContributionSummaryCard extends StatelessWidget {
  const ContributionSummaryCard({super.key, required this.summary});

  final ImamSalaryContributionSummary summary;

  @override
  Widget build(BuildContext context) {
    final values = <(String, String)>[
      ('Total Expected', AppFormat.rupees(summary.totalExpected)),
      ('Total Paid', AppFormat.rupees(summary.totalPaid)),
      ('Total Due', AppFormat.rupees(summary.totalDue)),
      ('Paid Months', '${summary.paidMonths}'),
      ('Partial Months', '${summary.partialMonths}'),
      ('Unpaid Months', '${summary.unpaidMonths}'),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Imam Salary Summary',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width < 500 ? 2 : 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            children: values
                .map(
                  (value) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        value.$2,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        value.$1,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
