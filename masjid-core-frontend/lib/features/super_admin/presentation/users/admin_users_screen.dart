import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_actions.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_controllers.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_user_model.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/users/widgets/admin_user_card.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/users/widgets/update_user_status_dialog.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/widgets/admin_action_feedback.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/widgets/admin_paged_list.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/widgets/admin_search_field.dart';

/// Roles the users list can filter by. MASJID_ADMIN is intentionally unused.
const List<String> _filterRoles = <String>[
  'SUPER_ADMIN',
  'IMAM',
  'COMMITTEE_MEMBER',
  'MEMBER',
];

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    AdminUserModel item,
  ) async {
    final status = await showUpdateUserStatusDialog(context);
    if (status == null || !context.mounted) return;
    await runAdminAction(
      context,
      () =>
          ref.read(superAdminActionsProvider).updateUserStatus(item.id, status),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(adminUsersFilterProvider);
    final busyIds = ref.watch(adminBusyIdsProvider);
    final filterController = ref.read(adminUsersFilterProvider.notifier);

    Widget statusChip(String label, String? status) => FilterChip(
      label: Text(label),
      selected: filter.status == status,
      onSelected: (_) =>
          filterController.state = filter.copyWith(status: status),
    );

    return Column(
      children: <Widget>[
        AdminSearchField(
          label: 'Search users',
          hint: 'Search by name, phone, or email',
          initialValue: filter.search,
          onSearch: (search) => filterController.update(
            (current) => current.copyWith(search: search),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            statusChip('All', null),
            statusChip('Active', 'ACTIVE'),
            statusChip('Inactive', 'INACTIVE'),
            statusChip('Suspended', 'SUSPENDED'),
            DropdownButton<String?>(
              value: filter.role,
              hint: const Text('All Roles'),
              items: <String?>[null, ..._filterRoles]
                  .map(
                    (role) => DropdownMenuItem<String?>(
                      value: role,
                      child: Text(role ?? 'All Roles'),
                    ),
                  )
                  .toList(),
              onChanged: (role) =>
                  filterController.state = filter.copyWith(role: role),
            ),
          ],
        ),
        Expanded(
          child: AdminPagedList<AdminUserModel>(
            state: ref.watch(adminUsersProvider),
            emptyText: 'No users found',
            onRefresh: () => ref.read(adminUsersProvider.notifier).refresh(),
            onLoadMore: () => ref.read(adminUsersProvider.notifier).loadMore(),
            onRetry: () => ref.invalidate(adminUsersProvider),
            itemBuilder: (context, item) => AdminUserCard(
              item: item,
              onStatus: () => _changeStatus(context, ref, item),
              busy: busyIds.contains(item.id),
            ),
          ),
        ),
      ],
    );
  }
}
