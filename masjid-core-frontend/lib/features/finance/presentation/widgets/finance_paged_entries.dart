import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/features/finance/presentation/widgets/finance_empty_view.dart';

/// Renders a paged list inside a card: first-load spinner or error, the
/// items, and a footer (spinner, "load more" retry, or a "Load more" button
/// for when the page is too short to scroll).
class FinancePagedEntries<T> extends StatelessWidget {
  const FinancePagedEntries({
    super.key,
    required this.state,
    required this.itemBuilder,
    required this.emptyMessage,
    required this.onRetry,
    required this.onLoadMore,
  });

  final AsyncValue<PagedState<T>> state;
  final Widget Function(T item) itemBuilder;
  final String emptyMessage;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: <Widget>[
            Text(userMessage(error), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
      data: (paged) {
        if (paged.items.isEmpty) return FinanceEmptyView(message: emptyMessage);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[...paged.items.map(itemBuilder), _footer(paged)],
        );
      },
    );
  }

  Widget _footer(PagedState<T> paged) {
    if (paged.loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final loadMoreError = paged.loadMoreError;
    if (loadMoreError != null) {
      return Column(
        children: <Widget>[
          Text(userMessage(loadMoreError), textAlign: TextAlign.center),
          TextButton(onPressed: onLoadMore, child: const Text('Retry')),
        ],
      );
    }
    if (paged.hasMore) {
      return TextButton(onPressed: onLoadMore, child: const Text('Load more'));
    }
    return const SizedBox.shrink();
  }
}
