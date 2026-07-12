import 'package:flutter/material.dart';
import 'package:platform_core_frontend/shared/models/audit_info.dart';
import 'package:platform_core_frontend/shared/utils/date_format_utils.dart';
import 'package:platform_core_frontend/shared/widgets/audit_info_button.dart';
import 'package:platform_core_frontend/features/finance/presentation/widgets/finance_labels.dart';

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
    this.auditInfo = const AuditInfo(),
  });

  final String type;
  final double amount;
  final bool isExpense;
  final String? title;
  final String? description;
  final String? date;
  final String? status;
  final AuditInfo auditInfo;

  @override
  Widget build(BuildContext context) {
    final displayTitle = title == null || title!.trim().isEmpty
        ? financeTypeLabel(type, isExpense: isExpense)
        : title!;
    final showStatus = status != null && status != 'ACTIVE';

    return Card(
      child: ListTile(
        title: Text(
          displayTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (date != null) Text(formatReadableDate(parseApiDate(date))),
            if (description != null) Text(description!),
            if (showStatus) Text('Status: $status'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              formatRupees(amount),
              style: TextStyle(
                color: isExpense
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            AuditInfoButton(auditInfo: auditInfo),
          ],
        ),
      ),
    );
  }
}
