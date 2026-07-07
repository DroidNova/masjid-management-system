import 'package:platform_core_frontend/shared/models/page_meta.dart';

class PaginatedData<T> {
  const PaginatedData({
    required this.items,
    required this.meta,
  });

  final List<T> items;
  final PageMeta meta;
}
