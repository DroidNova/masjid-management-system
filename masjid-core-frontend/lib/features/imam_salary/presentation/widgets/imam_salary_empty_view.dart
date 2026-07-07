import 'package:flutter/material.dart';

class ImamSalaryEmptyView extends StatelessWidget {
  const ImamSalaryEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.payments_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'No salary records added yet.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
