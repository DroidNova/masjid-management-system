import 'package:flutter/material.dart';

class UserStatusChip extends StatelessWidget {
  const UserStatusChip({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final colorScheme = Theme.of(context).colorScheme;

    Color bg;
    Color fg;

    switch (normalized) {
      case 'ACTIVE':
        bg = colorScheme.primaryContainer;
        fg = colorScheme.onPrimaryContainer;
      case 'SUSPENDED':
      case 'DISABLED':
        bg = colorScheme.errorContainer;
        fg = colorScheme.onErrorContainer;
      default:
        bg = colorScheme.surfaceContainerHighest;
        fg = colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        normalized,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
