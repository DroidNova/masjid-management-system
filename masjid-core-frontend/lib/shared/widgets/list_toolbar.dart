import 'package:flutter/material.dart';
import 'package:platform_core_frontend/shared/widgets/search_field.dart';

class ListToolbar extends StatelessWidget {
  const ListToolbar({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onRefresh,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchField(
            controller: searchController,
            hintText: 'Search users (if supported by backend)',
            onSubmitted: onSearch,
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
      ],
    );
  }
}
