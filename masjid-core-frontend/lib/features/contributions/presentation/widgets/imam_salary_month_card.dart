import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/contributions/models/my_imam_salary_contribution_model.dart';
import 'package:platform_core_frontend/features/contributions/presentation/widgets/contribution_status_chip.dart';
import 'package:platform_core_frontend/features/finance/presentation/widgets/finance_labels.dart';
import 'package:platform_core_frontend/shared/utils/date_format_utils.dart';
import 'package:platform_core_frontend/shared/widgets/app_card.dart';

class ImamSalaryMonthCard extends StatelessWidget {
  const ImamSalaryMonthCard({super.key, required this.item, required this.onViewPayments});
  final MyImamSalaryContributionModel item;
  final VoidCallback onViewPayments;

  static const months = <String>['January','February','March','April','May','June','July','August','September','October','November','December'];

  @override
  Widget build(BuildContext context) {
    final month = item.month >= 1 && item.month <= 12 ? months[item.month - 1] : 'Month ${item.month}';
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Row(children: <Widget>[
          Expanded(child: Text('$month ${item.year}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
          ContributionStatusChip(status: item.status),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 16, runSpacing: 6, children: <Widget>[
          Text('Expected ${formatRupees(item.expectedAmount)}'),
          Text('Paid ${formatRupees(item.paidAmount)}'),
          Text('Due ${formatRupees(item.dueAmount)}'),
        ]),
        const SizedBox(height: 8),
        Text('${item.paymentsCount} payment(s) • Last paid: ${formatReadableDate(item.lastPaidAt, nullText: 'Not available')}'),
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: onViewPayments, child: const Text('View Payments'))),
      ]),
    );
  }
}
