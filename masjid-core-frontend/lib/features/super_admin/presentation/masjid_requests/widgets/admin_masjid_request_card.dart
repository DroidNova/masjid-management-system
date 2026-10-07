import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_request_model.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/widgets_common.dart';

class AdminMasjidRequestCard extends StatelessWidget {
  const AdminMasjidRequestCard({
    super.key,
    required this.item,
    this.onApprove,
    this.onReject,
    this.busy = false,
  });
  final AdminMasjidRequestModel item;
  final VoidCallback? onApprove, onReject;

  /// A change to this request is in flight: actions are off.
  final bool busy;
  @override
  Widget build(BuildContext c) => Card(
    child: ListTile(
      title: Text(item.masjidName),
      subtitle: Text(
        '${item.requesterName ?? '-'} • ${item.requesterPhone ?? '-'}\n${[item.address, item.locality, item.district, item.state, item.country].where((e) => e != null && e.isNotEmpty).join(', ')}',
      ),
      isThreeLine: true,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AdminStatusChip(item.status),
          TextButton(
            onPressed: () =>
                c.go('/super-admin/requests/${item.id}', extra: item),
            child: const Text('View'),
          ),
          if (item.isPending)
            TextButton(
              onPressed: busy ? null : onApprove,
              child: const Text('Approve'),
            ),
          if (item.isPending)
            TextButton(
              onPressed: busy ? null : onReject,
              child: const Text('Reject'),
            ),
        ],
      ),
    ),
  );
}
