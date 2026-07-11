class PaginationResult<T> {
  const PaginationResult({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
}

Object? unwrapData(Object? responseData) {
  if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
    return responseData['data'];
  }
  return responseData;
}

List<dynamic> unwrapList(Object? responseData) {
  final data = unwrapData(responseData);
  if (data is List<dynamic>) return data;
  if (data is Map<String, dynamic>) {
    final items = data['items'];
    if (items is List<dynamic>) return items;
  }
  return <dynamic>[];
}

Map<String, dynamic> unwrapMap(Object? responseData) {
  final data = unwrapData(responseData);
  return data is Map<String, dynamic> ? data : <String, dynamic>{};
}

PaginationResult<T> parsePaginatedList<T>(
  Object? responseData,
  T Function(Map<String, dynamic> json) fromJson,
) {
  final data = unwrapData(responseData);
  final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
  final rawItems = data is List<dynamic> ? data : (map['items'] as List<dynamic>? ?? const <dynamic>[]);
  final items = rawItems.whereType<Map<String, dynamic>>().map(fromJson).toList();
  int readInt(String key, int fallback) => int.tryParse('${map[key] ?? fallback}') ?? fallback;
  return PaginationResult<T>(
    items: items,
    total: readInt('total', items.length),
    page: readInt('page', 1),
    limit: readInt('limit', items.length),
    totalPages: readInt('totalPages', 1),
  );
}
