import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_model.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/widgets_common.dart';

class AdminMasjidCard extends StatelessWidget {
  const AdminMasjidCard({
    super.key,
    required this.item,
    this.onStatus,
    this.busy = false,
  });
  final AdminMasjidModel item;
  final VoidCallback? onStatus;

  /// A change to this item is in flight: actions are off.
  final bool busy;
  @override
  Widget build(BuildContext c) => Card(
    child: ListTile(
      title: Text(item.name),
      subtitle: Text(
        '${[item.address, item.locality, item.district, item.state, item.country].where((e) => e != null && e.isNotEmpty).join(', ')}\nContact: ${item.contactNo ?? '-'} • Imam: ${item.imamName ?? '-'} • Users: ${item.usersCount}',
      ),
      isThreeLine: true,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AdminStatusChip(item.status),
          TextButton(
            onPressed: () =>
                c.go('/super-admin/masjids/${item.id}', extra: item),
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
