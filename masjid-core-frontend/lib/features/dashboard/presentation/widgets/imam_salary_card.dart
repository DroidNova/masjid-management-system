import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/imam_salary_summary.dart';
import 'package:platform_core_frontend/features/dashboard/presentation/widgets/dashboard_format.dart';

class ImamSalaryCard extends StatelessWidget {
  const ImamSalaryCard({super.key, required this.salarySummary});

  final ImamSalarySummary? salarySummary;

  @override
  Widget build(BuildContext context) {
    final summary = salarySummary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Imam Salary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (summary == null)
              const Text('Salary record not added yet.')
            else ...<Widget>[
              Text('Month/Year: ${summary.latestMonth}/${summary.latestYear}'),
              Text('Salary: ${formatRupees(summary.salaryAmount)}'),
              Text('Paid: ${formatRupees(summary.paidAmount)}'),
              Text('Due: ${formatRupees(summary.dueAmount)}'),
              if (summary.status != null) Text('Status: ${summary.status}'),
            ],
          ],
        ),
      ),
    );
  }
}
