import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/shared/widgets/error_view.dart';
import 'package:masjid_core_frontend/shared/widgets/loading_view.dart';

/// Infinite-scroll body for a [PagedController] list: loading, error with
/// retry, pull-to-refresh, "load more" near the end and an empty message.
class AdminPagedList<T> extends StatelessWidget {
  const AdminPagedList({
    super.key,
    required this.state,
    required this.itemBuilder,
    required this.emptyText,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onRetry,
  });

  final AsyncValue<PagedState<T>> state;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String emptyText;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return state.when(
      // Keep the list visible while it reloads after a change.
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        title: 'Unable to load',
        message: userMessage(error),
        onRetry: onRetry,
      ),
      data: (paged) => NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (paged.hasMore && notification.metrics.extentAfter < 300) {
            onLoadMore();
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              for (final item in paged.items) itemBuilder(context, item),
              if (paged.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text(emptyText)),
                ),
              if (paged.loadingMore)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (paged.loadMoreError != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: TextButton(
                      onPressed: onLoadMore,
                      child: Text(
                        '${userMessage(paged.loadMoreError!)} Tap to retry.',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
