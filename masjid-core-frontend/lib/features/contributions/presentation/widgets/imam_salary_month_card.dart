import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/my_imam_salary_month.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/contribution_status_chip.dart';
import 'package:masjid_core_frontend/shared/widgets/app_card.dart';

class ImamSalaryMonthCard extends StatelessWidget {
  const ImamSalaryMonthCard({
    super.key,
    required this.item,
    required this.onViewPayments,
  });

  final MyImamSalaryMonth item;
  final VoidCallback onViewPayments;

  @override
  Widget build(BuildContext context) {
    final lastPaid = item.lastPaidAt == null
        ? 'Not available'
        : AppFormat.date(item.lastPaidAt!);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  monthLabel(item.month, item.year),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ContributionStatusChip(status: item.status),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: <Widget>[
              Text('Expected ${AppFormat.rupees(item.expectedAmount)}'),
              Text('Paid ${AppFormat.rupees(item.paidAmount)}'),
              Text('Due ${AppFormat.rupees(item.dueAmount)}'),
            ],
          ),
          const SizedBox(height: 8),
          Text('${item.paymentsCount} payment(s) • Last paid: $lastPaid'),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onViewPayments,
              child: const Text('View Payments'),
            ),
          ),
        ],
      ),
    );
  }
}

/// "September 2026", or "Month 13 2026" for an out-of-range month.
String monthLabel(int month, int year) => month >= 1 && month <= 12
    ? AppFormat.monthYear(month, year)
    : 'Month $month $year';
