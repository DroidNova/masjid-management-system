import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_controllers.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_user_model.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/admin_parts.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/users/admin_user_detail_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Roles the users list can filter by. MASJID_ADMIN is intentionally unused.
const List<String> _filterRoles = <String>[
  PermissionHelper.superAdmin,
  PermissionHelper.imam,
  PermissionHelper.committeeMember,
  PermissionHelper.member,
];

/// Every user: search, status and role chips, and cards. Tapping one opens
/// their details (beside the list on desktop), where status and roles
/// change.
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  AdminUserModel? _picked;

  void _open(AdminUserModel item) {
    if (AdminSplitView.isSplit(context)) {
      setState(() => _picked = item);
    } else {
      context.go('/super-admin/users/${item.id}', extra: item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(adminUsersFilterProvider);
    final filterController = ref.read(adminUsersFilterProvider.notifier);
    final picked = _picked;
    final filtered =
        filter.search.isNotEmpty ||
        filter.status != null ||
        filter.role != null;

    final list = PagedListView<AdminUserModel>(
      value: ref.watch(adminUsersProvider),
      header: <Widget>[
        AdminSearchField(
          hint: l10n.searchUsers,
          initialValue: filter.search,
          onSearch: (search) => filterController.update(
            (current) => current.copyWith(search: search),
          ),
        ),
        const SizedBox(height: AppSpace.m),
        AdminFilterChips(
          options: <AdminFilter>[
            (value: null, label: l10n.all),
            (value: 'ACTIVE', label: l10n.statusActive),
            (value: 'INACTIVE', label: l10n.statusInactive),
            (value: 'SUSPENDED', label: l10n.statusSuspended),
          ],
          selected: filter.status,
          onSelected: (status) =>
              filterController.state = filter.copyWith(status: status),
        ),
        const SizedBox(height: AppSpace.s),
        AdminFilterChips(
          options: <AdminFilter>[
            (value: null, label: l10n.allRoles),
            for (final role in _filterRoles)
              (value: role, label: adminRoleLabel(l10n, role)),
          ],
          selected: filter.role,
          onSelected: (role) =>
              filterController.state = filter.copyWith(role: role),
        ),
        const SizedBox(height: AppSpace.s),
      ],
      onRefresh: () => ref.read(adminUsersProvider.notifier).refresh(),
      onLoadMore: () => ref.read(adminUsersProvider.notifier).loadMore(),
      onRetry: () => ref.invalidate(adminUsersProvider),
      empty: listEmptyState(
        icon: AppIcons.people,
        tone: AppTones.people,
        title: l10n.noUsers,
        filtered: filtered,
        l10n: l10n,
      ),
      itemBuilder: (context, item) => AdminListCard(
        leading: PersonAvatar(name: item.fullName),
        title: item.fullName.isEmpty ? l10n.roleMember : item.fullName,
        lines: <String>[
          placeLine(<String?>[item.phone, item.email]),
          placeLine(<String?>[
            ...item.roles.map((role) => adminRoleLabel(l10n, role)),
            item.masjidName,
          ]),
        ],
        status: item.status,
        selected: picked?.id == item.id,
        onTap: () => _open(item),
      ),
    );

    return AdminSplitView(
      list: list,
      detail: picked == null
          ? null
          : AdminUserDetails(
              key: ValueKey<String>(picked.id),
              id: picked.id,
              initial: picked,
            ),
    );
  }
}
