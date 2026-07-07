import 'package:flutter/material.dart';

class ListStateView extends StatelessWidget {
  const ListStateView.loading({super.key})
      : isLoading = true,
        errorMessage = null,
        onRetry = null,
        emptyMessage = null;

  const ListStateView.error({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  })  : isLoading = false,
        emptyMessage = null;

  const ListStateView.empty({
    super.key,
    required this.emptyMessage,
  })  : isLoading = false,
        errorMessage = null,
        onRetry = null;

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage!),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Center(child: Text(emptyMessage ?? 'No data available.'));
  }
}
