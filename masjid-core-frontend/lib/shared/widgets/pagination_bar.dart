import 'package:flutter/material.dart';
import 'package:platform_core_frontend/shared/models/page_meta.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.meta,
    required this.onPrevious,
    required this.onNext,
  });

  final PageMeta meta;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Page ${meta.page} of ${meta.totalPages}'),
        const SizedBox(width: 8),
        IconButton(
          onPressed: meta.hasPrevious ? onPrevious : null,
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Previous page',
        ),
        IconButton(
          onPressed: meta.hasNext ? onNext : null,
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Next page',
        ),
      ],
    );
  }
}
