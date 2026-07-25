class PaginatedResponse<T> {
  const PaginatedResponse({required this.items, required this.total, required this.page, required this.limit, required this.totalPages, required this.hasNextPage});
  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) parser) {
    int number(String key, int fallback) => int.tryParse('${json[key] ?? fallback}') ?? fallback;
    final items = (json['items'] as List<dynamic>? ?? const <dynamic>[]).whereType<Map<String, dynamic>>().map(parser).toList();
    final page = number('page', 1); final limit = number('limit', 20); final total = number('total', items.length); final totalPages = number('totalPages', total == 0 ? 0 : (total / limit).ceil());
    return PaginatedResponse(items: items, total: total, page: page, limit: limit, totalPages: totalPages, hasNextPage: json['hasNextPage'] == true || page < totalPages);
  }
}
