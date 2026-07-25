import 'package:flutter/foundation.dart';
import 'package:platform_core_frontend/shared/models/paginated_response.dart';

typedef PageLoader<T> = Future<PaginatedResponse<T>> Function(
  int page,
  int limit,
);

class PaginatedListController<T> extends ChangeNotifier {
  PaginatedListController({
    required this.loader,
    this.limit = 20,
    this.errorMapper,
  });

  final PageLoader<T> loader;
  final int limit;
  final String Function(Object error)? errorMapper;
  final List<T> items = <T>[];

  int _page = 0;
  bool isLoading = false;
  bool hasNextPage = true;
  String? error;

  Future<void> refresh() async {
    items.clear();
    _page = 0;
    hasNextPage = true;
    error = null;
    notifyListeners();
    await loadNext();
  }

  Future<void> loadNext() async {
    if (isLoading || !hasNextPage) return;

    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await loader(_page + 1, limit);
      items.addAll(result.items);
      _page = result.page;
      hasNextPage = result.hasNextPage;
    } catch (exception) {
      error = errorMapper?.call(exception) ??
          exception.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
