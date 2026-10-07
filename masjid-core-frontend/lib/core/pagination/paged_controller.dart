import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';

/// Items loaded so far for an infinite-scroll list.
class PagedState<T> {
  const PagedState({
    required this.items,
    required this.page,
    required this.hasMore,
    required this.total,
    this.loadingMore = false,
    this.loadMoreError,
  });

  final List<T> items;
  final int page;
  final bool hasMore;
  final int total;

  /// True while the next page is being fetched (show a footer spinner).
  final bool loadingMore;

  /// Error from the last "load more" (the already-loaded items stay visible).
  final Object? loadMoreError;

  PagedState<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasMore,
    int? total,
    bool? loadingMore,
    Object? loadMoreError,
  }) => PagedState<T>(
    items: items ?? this.items,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    total: total ?? this.total,
    loadingMore: loadingMore ?? this.loadingMore,
    loadMoreError: loadMoreError,
  );
}

/// Base class for paged lists. Implement [fetchPage]; first page loads in
/// [build], more with [loadMore], pull-to-refresh with [refresh].
///
/// Filters: keep them in a separate provider (e.g. a `StateProvider`), watch
/// it in an overridden [build] before calling `super.build()`, and read it with
/// `ref.read` inside [fetchPage]. Changing the filter reloads from page 1.
///
/// ```dart
/// final collectionsProvider = AsyncNotifierProvider.autoDispose<
///     CollectionsController, PagedState<CollectionEntry>>(CollectionsController.new);
///
/// class CollectionsController extends PagedController<CollectionEntry> {
///   @override
///   Future<PagedState<CollectionEntry>> build() {
///     ref.watch(collectionsFilterProvider);
///     ref.watch(dataVersionProvider(DataScope.finance));
///     return super.build();
///   }
///   @override
///   Future<PageResult<CollectionEntry>> fetchPage(int page) =>
///       ref.read(financeRepositoryProvider)
///          .collections(ref.read(collectionsFilterProvider), page: page);
/// }
/// ```
abstract class PagedController<T>
    extends AutoDisposeAsyncNotifier<PagedState<T>> {
  Future<PageResult<T>> fetchPage(int page);

  @override
  Future<PagedState<T>> build() async {
    final first = await fetchPage(1);
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
      final next = await fetchPage(current.page + 1);
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
