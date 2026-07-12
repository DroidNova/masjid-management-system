import 'package:flutter/material.dart';
import 'package:platform_core_frontend/shared/utils/date_format_utils.dart';
import 'package:platform_core_frontend/features/finance/presentation/widgets/finance_labels.dart';
import 'package:platform_core_frontend/features/imam_salary/models/imam_salary_model.dart';
import 'package:platform_core_frontend/features/imam_salary/presentation/widgets/imam_salary_status_chip.dart';

class ImamSalaryCard extends StatelessWidget {
  const ImamSalaryCard({
    super.key,
    required this.salary,
    this.onTap,
  });

  final ImamSalaryModel salary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${salary.monthName} ${salary.year}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ImamSalaryStatusChip(status: salary.status),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  _AmountLabel(
                    label: 'Salary',
                    amount: salary.salaryAmount,
                  ),
                  _AmountLabel(
                    label: 'Paid',
                    amount: salary.paidAmount,
                  ),
                  _AmountLabel(
                    label: 'Due',
                    amount: salary.dueAmount == 0
                        ? salary.calculatedDueAmount
                        : salary.dueAmount,
                  ),
                ],
              ),
              if (salary.paidDate != null) ...<Widget>[
                const SizedBox(height: 10),
                Text('Paid date: ${formatReadableDate(parseApiDate(salary.paidDate))}'),
              ],
              if (salary.note != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(salary.note!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountLabel extends StatelessWidget {
  const _AmountLabel({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            formatRupees(amount),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
