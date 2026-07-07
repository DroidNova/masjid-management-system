import 'package:platform_core_frontend/shared/types/json_types.dart';

enum SortOrder { asc, desc }

class ListQueryParams {
  const ListQueryParams({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.sortBy,
    this.sortOrder,
    this.filters = const <String, String>{},
  });

  final int page;
  final int limit;
  final String? search;
  final String? sortBy;
  final SortOrder? sortOrder;
  final Map<String, String> filters;

  JsonMap toQueryMap() {
    return {
      'page': page,
      'limit': limit,
      if (search != null && search!.trim().isNotEmpty) 'search': search,
      if (sortBy != null && sortBy!.trim().isNotEmpty) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder!.name,
      ...filters,
    };
  }

  ListQueryParams copyWith({
    int? page,
    int? limit,
    String? search,
    bool clearSearch = false,
    String? sortBy,
    SortOrder? sortOrder,
    Map<String, String>? filters,
  }) {
    return ListQueryParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: clearSearch ? null : (search ?? this.search),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      filters: filters ?? this.filters,
    );
  }
}
