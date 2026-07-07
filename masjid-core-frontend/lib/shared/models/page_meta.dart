class PageMeta {
  const PageMeta({
    required this.page,
    required this.limit,
    required this.total,
  });

  final int page;
  final int limit;
  final int total;

  bool get hasNext => page * limit < total;
  bool get hasPrevious => page > 1;

  int get totalPages {
    if (limit <= 0) {
      return 1;
    }
    final rawPages = (total / limit).ceil();
    return rawPages <= 0 ? 1 : rawPages;
  }
}
