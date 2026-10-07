import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/imam_salary/application/imam_salary_controllers.dart';
import 'package:masjid_core_frontend/features/imam_salary/data/models/imam_salary_models.dart';

const List<String> _shortMonths = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// PAID / PARTIAL / UNPAID.
class SalaryStatusChip extends StatelessWidget {
  const SalaryStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(status),
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

/// Month and year dropdowns bound to [salaryPeriodProvider].
class SalaryPeriodPicker extends ConsumerWidget {
  const SalaryPeriodPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(salaryPeriodProvider);
    final currentYear = DateTime.now().year;
    final years = <int>{
      for (var i = 0; i < 3; i++) currentYear - i,
      period.year,
    }.toList();
    final notifier = ref.read(salaryPeriodProvider.notifier);

    return Row(
      children: <Widget>[
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: period.month,
            items: List<DropdownMenuItem<int>>.generate(
              12,
              (i) => DropdownMenuItem<int>(
                value: i + 1,
                child: Text(_shortMonths[i]),
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                notifier.state = (month: value, year: period.year);
              }
            },
            decoration: const InputDecoration(labelText: 'Month'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<int>(
            initialValue: period.year,
            items: years
                .map(
                  (year) =>
                      DropdownMenuItem<int>(value: year, child: Text('$year')),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                notifier.state = (month: period.month, year: value);
              }
            },
            decoration: const InputDecoration(labelText: 'Year'),
          ),
        ),
      ],
    );
  }
}

/// Totals and head counts for one salary month.
class SalaryMonthSummaryCard extends StatelessWidget {
  const SalaryMonthSummaryCard({super.key, required this.month});

  final ImamSalaryMonth month;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: <Widget>[
            Text(
              AppFormat.monthYear(month.month, month.year),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: <Widget>[
                Text('Expected ${AppFormat.rupees(month.totalExpected)}'),
                Text('Collected ${AppFormat.rupees(month.totalCollected)}'),
                Text('Due ${AppFormat.rupees(month.totalDue)}'),
                Text('Paid ${month.paidCount}'),
                Text('Partial ${month.partialCount}'),
                Text('Unpaid ${month.unpaidCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One family head's dues for the month.
class SalaryAssignmentTile extends StatelessWidget {
  const SalaryAssignmentTile({
    super.key,
    required this.assignment,
    this.onAddPayment,
  });

  final SalaryAssignment assignment;

  /// Null hides the button (read-only, or nothing due).
  final VoidCallback? onAddPayment;

  @override
  Widget build(BuildContext context) {
    final a = assignment;
    return Card(
      child: ListTile(
        title: Text(a.memberName),
        subtitle: Text(
          '${a.memberPhone}\n'
          'Expected ${AppFormat.rupees(a.expectedAmount)} • '
          'Paid ${AppFormat.rupees(a.paidAmount)} • '
          'Due ${AppFormat.rupees(a.dueAmount)}',
        ),
        isThreeLine: true,
        // Compact chip + button so both fit the tile's trailing height.
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SalaryStatusChip(status: a.status),
            if (onAddPayment != null)
              TextButton(
                onPressed: onAddPayment,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: const Size(0, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Add Payment'),
              ),
          ],
        ),
      ),
    );
  }
}

/// One recorded payment.
class SalaryPaymentTile extends StatelessWidget {
  const SalaryPaymentTile({super.key, required this.payment});

  final SalaryPayment payment;

  @override
  Widget build(BuildContext context) {
    final p = payment;
    final paidOn = p.paidAt == null
        ? 'Not available'
        : AppFormat.date(p.paidAt!);
    return Card(
      child: ListTile(
        title: Text('${p.memberName} • ${AppFormat.rupees(p.amount)}'),
        subtitle: Text(
          '${p.paymentMode} • $paidOn\n'
          'Collected by ${p.collectedByName}'
          '${p.note == null ? '' : '\n${p.note}'}',
        ),
        isThreeLine: true,
      ),
    );
  }
}

/// Error text with a retry button, for a failed list or month load.
class SalaryLoadError extends StatelessWidget {
  const SalaryLoadError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message, textAlign: TextAlign.center),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
