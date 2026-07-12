import 'package:flutter/material.dart';
import 'package:platform_core_frontend/shared/models/audit_info.dart';
import 'package:platform_core_frontend/shared/utils/date_format_utils.dart';

class AuditInfoButton extends StatelessWidget {
  const AuditInfoButton({super.key, required this.auditInfo});

  final AuditInfo auditInfo;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Audit info',
      icon: const Icon(Icons.info_outline),
      onPressed: () => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Audit Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _AuditRow(label: 'Created by', value: auditInfo.createdByName ?? 'Not available'),
              _AuditRow(label: 'Created at', value: formatReadableDateTime(auditInfo.createdAt, nullText: 'Not available')),
              _AuditRow(label: 'Updated by', value: auditInfo.updatedByName ?? 'Not updated yet'),
              _AuditRow(label: 'Updated at', value: formatReadableDateTime(auditInfo.updatedAt, nullText: 'Not updated yet')),
            ],
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ],
        ),
      ),
    );
  }
}

class _AuditRow extends StatelessWidget {
  const _AuditRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 92, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(child: Text(value)),
          ],
        ),
      );
}
