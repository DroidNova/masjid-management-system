import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';

/// [PagedController] for a `.family` provider: the argument (an id, or a
/// record of id + filters) selects the list. A new argument is a new provider
/// instance, so changing a filter reloads from page 1.
///
/// Same behaviour as [PagedController] in `paged_controller.dart`.
abstract class PagedFamilyController<T, A>
    extends AutoDisposeFamilyAsyncNotifier<PagedState<T>, A> {
  Future<PageResult<T>> fetchPage(A arg, int page);

  @override
  Future<PagedState<T>> build(A arg) async {
    final first = await fetchPage(arg, 1);
    return PagedState<T>(
      items: first.items,
      page: 1,
      hasMore: first.meta.hasNextPage,
      total: first.meta.total,
    );
  }

  /// Appends the next page. Safe to call repeatedly (e.g. on scroll).
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.loadingMore) return;

    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await fetchPage(arg, current.page + 1);
      state = AsyncData(
        current.copyWith(
          items: <T>[...current.items, ...next.items],
          page: current.page + 1,
          hasMore: next.meta.hasNextPage,
          total: next.meta.total,
          loadingMore: false,
        ),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(loadingMore: false, loadMoreError: error),
      );
    }
  }

  /// Reloads from page 1, keeping the current items visible meanwhile.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
