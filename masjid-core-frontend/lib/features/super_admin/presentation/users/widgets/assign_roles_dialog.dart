import 'package:flutter/material.dart';

Future<List<String>?> showAssignRolesDialog(
  BuildContext c,
  List<String> initial,
) {
  // Only roles the server lets an admin hand out (ASSIGNABLE_ROLES in
  // masjid-core/src/access/permissions.ts). SUPER_ADMIN is created by script
  // and MASJID_ADMIN is intentionally unused.
  final roles = ['IMAM', 'COMMITTEE_MEMBER', 'MEMBER'];
  final selected = initial.where(roles.contains).toSet();
  return showDialog<List<String>>(
    context: c,
    builder: (x) => StatefulBuilder(
      builder: (x, set) => AlertDialog(
        title: const Text('Assign roles'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final r in roles)
              CheckboxListTile(
                value: selected.contains(r),
                title: Text(r),
                onChanged: (v) =>
                    set(() => v == true ? selected.add(r) : selected.remove(r)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(x),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(x, selected.toList()),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
