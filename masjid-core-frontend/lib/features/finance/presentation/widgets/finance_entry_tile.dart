import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/finance/presentation/widgets/finance_labels.dart';

class FinanceEntryTile extends StatelessWidget {
  const FinanceEntryTile({
    super.key,
    required this.type,
    required this.amount,
    required this.isExpense,
    this.title,
    this.description,
    this.date,
    this.status,
    this.onCancel,
  });

  final String type;
  final double amount;
  final bool isExpense;
  final String? title;
  final String? description;
  final DateTime? date;
  final String? status;

  /// Long-press action, set only for users who may cancel this entry.
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final entryTitle = title?.trim();
    final displayTitle = entryTitle == null || entryTitle.isEmpty
        ? financeTypeLabel(type, isExpense: isExpense)
        : entryTitle;
    final showStatus = status != null && status != 'ACTIVE';
    final entryDate = date;
    final entryDescription = description;

    return Card(
      child: ListTile(
        onLongPress: onCancel,
        title: Text(
          displayTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (entryDate != null) Text(AppFormat.date(entryDate)),
            if (entryDescription != null && entryDescription.isNotEmpty)
              Text(entryDescription),
            if (showStatus) Text('Status: $status'),
          ],
        ),
        trailing: Text(
          AppFormat.rupees(amount),
          style: TextStyle(
            color: isExpense
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
