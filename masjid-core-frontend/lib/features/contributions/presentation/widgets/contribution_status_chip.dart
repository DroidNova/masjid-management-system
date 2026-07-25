import 'package:flutter/material.dart';

class ContributionStatusChip extends StatelessWidget {
  const ContributionStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final color = switch (normalized) {
      'PAID' => Colors.green,
      'PARTIAL' => Colors.orange,
      _ => Colors.red,
    };
    return Chip(
      label: Text(normalized),
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      labelStyle: TextStyle(color: color.shade700, fontWeight: FontWeight.w700),
    );
  }
}
