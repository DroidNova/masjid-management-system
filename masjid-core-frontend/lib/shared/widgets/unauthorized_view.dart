import 'package:flutter/material.dart';

class UnauthorizedView extends StatelessWidget {
  const UnauthorizedView({
    super.key,
    this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Unauthorized',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'You do not have access to this section.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
