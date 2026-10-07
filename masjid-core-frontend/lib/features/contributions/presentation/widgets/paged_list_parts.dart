import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/shared/widgets/app_card.dart';

/// Calls [onNearEnd] when [controller] scrolls within 300px of the end.
void listenNearEnd(ScrollController controller, VoidCallback onNearEnd) {
  controller.addListener(() {
    if (controller.hasClients && controller.position.extentAfter < 300) {
      onNearEnd();
    }
  });
}

/// Rows for one paged section inside a ListView: items, empty text,
/// first-load spinner, first-load error with retry, "load more" footer.
///
/// With [loadMoreNearEnd], the section loads its next page by itself when
/// its last row is built, i.e. when the lazy ListView scrolls near the end of
/// this section (for screens with several paged sections in one list).
List<Widget> pagedSection<T>({
  required AsyncValue<PagedState<T>> value,
  required Widget Function(T item) itemBuilder,
  required Widget empty,
  required VoidCallback onRetry,
  required VoidCallback onLoadMore,
  bool loadMoreNearEnd = false,
}) {
  const spinner = Padding(
    padding: EdgeInsets.all(16),
    child: Center(child: CircularProgressIndicator()),
  );
  return value.when(
    skipLoadingOnRefresh: true,
    skipLoadingOnReload: true,
    loading: () => const <Widget>[spinner],
    error: (error, _) => <Widget>[
      ErrorCard(message: userMessage(error), onRetry: onRetry),
    ],
    data: (state) => <Widget>[
      if (state.items.isEmpty) empty,
      ...state.items.map(itemBuilder),
      if (loadMoreNearEnd &&
          state.hasMore &&
          !state.loadingMore &&
          state.loadMoreError == null)
        // A new key per page, so it fires again if still in view.
        _LoadMoreTrigger(
          key: ValueKey<int>(state.items.length),
          onLoadMore: onLoadMore,
        ),
      if (state.loadingMore) spinner,
      if (state.loadMoreError != null)
        ErrorCard(
          message: userMessage(state.loadMoreError!),
          onRetry: onLoadMore,
        ),
    ],
  );
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: <Widget>[
          Text(message, textAlign: TextAlign.center),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

/// Invisible row that asks for the next page once it is first built.
class _LoadMoreTrigger extends StatefulWidget {
  const _LoadMoreTrigger({super.key, required this.onLoadMore});

  final VoidCallback onLoadMore;

  @override
  State<_LoadMoreTrigger> createState() => _LoadMoreTriggerState();
}

class _LoadMoreTriggerState extends State<_LoadMoreTrigger> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onLoadMore();
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
