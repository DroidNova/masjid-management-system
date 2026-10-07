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

/// Shared paging logic. [generation] goes up on every (re)build, so a "load
/// more" that finishes after a refresh or filter change is dropped instead of
/// appending stale items to the new list.
class PagedLoader<T> {
  int _generation = 0;
  bool _disposed = false;

  /// Call at the start of `build`.
  void onBuild(Ref ref) {
    _generation++;
    _disposed = false;
    ref.onDispose(() => _disposed = true);
  }

  Future<PagedState<T>> first(Future<PageResult<T>> Function(int) fetch) async {
    final first = await fetch(1);
    return PagedState<T>(
      items: first.items,
      page: 1,
      hasMore: first.meta.hasNextPage,
      total: first.meta.total,
    );
  }

  Future<void> loadMore({
    required AsyncValue<PagedState<T>> Function() read,
    required void Function(AsyncValue<PagedState<T>>) write,
    required Future<PageResult<T>> Function(int) fetch,
  }) async {
    final value = read();
    // While (re)loading page 1 the old items are only a placeholder.
    if (value.isLoading) return;
    final current = value.valueOrNull;
    if (current == null || !current.hasMore || current.loadingMore) return;

    final generation = _generation;
    // A rebuild (refresh, filter or scope change) disposes the old build and
    // bumps the generation: the page fetched meanwhile belongs to the old list.
    bool stale() => _disposed || generation != _generation || read().isLoading;

    write(AsyncData(current.copyWith(loadingMore: true)));
    try {
      final next = await fetch(current.page + 1);
      if (stale()) return;
      // Append to the latest state: an item may have been replaced meanwhile.
      final latest = read().valueOrNull ?? current;
      write(
        AsyncData(
          latest.copyWith(
            items: <T>[...latest.items, ...next.items],
            page: current.page + 1,
            hasMore: next.meta.hasNextPage,
            total: next.meta.total,
            loadingMore: false,
          ),
        ),
      );
    } catch (error) {
      if (stale()) return;
      final latest = read().valueOrNull ?? current;
      write(
        AsyncData(latest.copyWith(loadingMore: false, loadMoreError: error)),
      );
    }
  }
}

/// Base class for paged lists. Implement [fetchPage]; first page loads in
/// [build], more with [loadMore], pull-to-refresh with [refresh].
///
/// Filters: keep them in a separate provider (e.g. a `StateProvider`), watch
/// it in an overridden [build] before calling `super.build()`, and read it with
/// `ref.read` inside [fetchPage]. Changing the filter reloads from page 1, and
/// a "load more" still in flight for the old filter is dropped.
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
  final PagedLoader<T> _loader = PagedLoader<T>();

  Future<PageResult<T>> fetchPage(int page);

  @override
  Future<PagedState<T>> build() {
    _loader.onBuild(ref);
    return _loader.first(fetchPage);
  }

  /// Appends the next page. Safe to call repeatedly (e.g. on scroll).
  Future<void> loadMore() => _loader.loadMore(
    read: () => state,
    write: (value) => state = value,
    fetch: fetchPage,
  );

  /// Reloads from page 1, keeping the current items visible meanwhile.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
