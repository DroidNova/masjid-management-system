/// One page of a list, as every paged API endpoint returns it:
/// `{ items: [...], meta: { page, limit, total, totalPages, hasNextPage } }`
/// (see masjid-core/src/common/pagination.ts).
class Page<T> {
  const Page({required this.items, required this.meta});

  factory Page.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) parseItem,
  ) {
    final rawItems = json['items'];
    return Page<T>(
      items: rawItems is List
          ? rawItems.whereType<Map<String, dynamic>>().map(parseItem).toList()
          : <T>[],
      meta: PageMeta.fromJson(
        json['meta'] is Map<String, dynamic>
            ? json['meta'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
    );
  }

  final List<T> items;
  final PageMeta meta;
}

class PageMeta {
  const PageMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNextPage,
  });

  factory PageMeta.fromJson(Map<String, dynamic> json) {
    int read(String key, int fallback) {
      final value = json[key];
      return value is num ? value.toInt() : fallback;
    }

    final page = read('page', 1);
    final totalPages = read('totalPages', 0);
    return PageMeta(
      page: page,
      limit: read('limit', 20),
      total: read('total', 0),
      totalPages: totalPages,
      hasNextPage: json['hasNextPage'] is bool
          ? json['hasNextPage'] as bool
          : page < totalPages,
    );
  }

  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
}
