import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_user_model.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/widgets_common.dart';

class AdminUserCard extends StatelessWidget {
  const AdminUserCard({
    super.key,
    required this.item,
    this.onStatus,
    this.busy = false,
  });
  final AdminUserModel item;
  final VoidCallback? onStatus;

  /// A change to this item is in flight: actions are off.
  final bool busy;
  @override
  Widget build(BuildContext c) => Card(
    child: ListTile(
      title: Text(item.fullName.isEmpty ? 'User' : item.fullName),
      subtitle: Text(
        '${item.phone ?? '-'} • ${item.email ?? '-'}\n${item.roles.join(', ')} • ${item.masjidName ?? item.masjidId ?? '-'}',
      ),
      isThreeLine: true,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AdminStatusChip(item.status),
          TextButton(
            onPressed: () => c.go('/super-admin/users/${item.id}', extra: item),
            child: const Text('View'),
          ),
          TextButton(
            onPressed: busy ? null : onStatus,
            child: const Text('Change Status'),
          ),
        ],
      ),
    ),
  );
}
