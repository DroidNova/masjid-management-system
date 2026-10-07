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
List<Widget> pagedSection<T>({
  required AsyncValue<PagedState<T>> value,
  required Widget Function(T item) itemBuilder,
  required Widget empty,
  required VoidCallback onRetry,
  required VoidCallback onLoadMore,
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
