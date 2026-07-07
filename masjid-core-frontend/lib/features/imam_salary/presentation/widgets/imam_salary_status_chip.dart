import 'package:flutter/material.dart';

class ImamSalaryStatusChip extends StatelessWidget {
  const ImamSalaryStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalized = status.toUpperCase();
    final Color color = switch (normalized) {
      'PAID' => Colors.green,
      'PARTIAL' => Colors.orange,
      _ => colorScheme.error,
    };

    return Chip(
      label: Text(_statusLabel(normalized)),
      backgroundColor: color.withOpacity(0.12),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
      side: BorderSide(color: color.withOpacity(0.24)),
    );
  }

  String _statusLabel(String value) {
    return switch (value) {
      'PAID' => 'Paid',
      'PARTIAL' => 'Partial',
      'UNPAID' => 'Unpaid',
      _ => value.replaceAll('_', ' '),
    };
  }
}
