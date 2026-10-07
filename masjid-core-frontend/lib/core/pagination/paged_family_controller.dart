import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';

/// [PagedController] for a `.family` provider: the argument (an id, or a
/// record of id + filters) selects the list. A new argument is a new provider
/// instance, so changing a filter reloads from page 1.
///
/// Same behaviour as [PagedController] in `paged_controller.dart`, including
/// dropping a "load more" that finishes after a refresh.
abstract class PagedFamilyController<T, A>
    extends AutoDisposeFamilyAsyncNotifier<PagedState<T>, A> {
  final PagedLoader<T> _loader = PagedLoader<T>();

  Future<PageResult<T>> fetchPage(A arg, int page);

  @override
  Future<PagedState<T>> build(A arg) {
    _loader.onBuild(ref);
    return _loader.first((page) => fetchPage(arg, page));
  }

  /// Appends the next page. Safe to call repeatedly (e.g. on scroll).
  Future<void> loadMore() => _loader.loadMore(
    read: () => state,
    write: (value) => state = value,
    fetch: (page) => fetchPage(arg, page),
  );

  /// Reloads from page 1, keeping the current items visible meanwhile.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
