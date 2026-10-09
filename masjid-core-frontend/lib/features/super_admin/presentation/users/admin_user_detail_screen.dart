import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_actions.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_controllers.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_user_model.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/admin_parts.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Only roles the server lets an admin hand out (ASSIGNABLE_ROLES in
/// masjid-core/src/access/permissions.ts). SUPER_ADMIN is created by script
/// and MASJID_ADMIN is intentionally unused.
const List<String> assignableRoles = <String>[
  PermissionHelper.imam,
  PermissionHelper.committeeMember,
  PermissionHelper.member,
];

/// A user, as their own page (phones and tablets).
class AdminUserDetailScreen extends StatelessWidget {
  const AdminUserDetailScreen({super.key, required this.id, this.initial});

  final String id;
  final AdminUserModel? initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).person)),
      body: AdminUserDetails(id: id, initial: initial),
    );
  }
}

/// A user's contact, roles, and masjid, with Change status and Change
/// roles. Loaded by [id]; [initial] (from the list) shows while it loads.
class AdminUserDetails extends ConsumerWidget {
  const AdminUserDetails({super.key, required this.id, this.initial});

  final String id;
  final AdminUserModel? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = adminUserProvider(id);
    final preview = initial;
    return ref
        .watch(provider)
        .when(
          skipLoadingOnRefresh: true,
          skipLoadingOnReload: true,
          loading: () => preview == null
              ? const SkeletonList()
              : _Content(user: preview, enabled: false),
          error: (error, _) =>
              ErrorState(error: error, onRetry: () => ref.invalidate(provider)),
          data: (user) => RefreshIndicator(
            onRefresh: () => ref.read(provider.notifier).refresh(),
            child: _Content(
              // The detail endpoint has no masjid; keep the list's value.
              user: user.masjidName == null && preview != null
                  ? user.copyWith(
                      masjidId: preview.masjidId,
                      masjidName: preview.masjidName,
                    )
                  : user,
            ),
          ),
        );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.user, this.enabled = true});

  final AdminUserModel user;

  /// Actions are off while showing the preview.
  final bool enabled;

  Future<void> _changeStatus(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final status = await pickOption(
      context,
      title: l10n.changeStatus,
      current: user.status,
      options: <AdminOption>[
        (value: 'ACTIVE', label: l10n.statusActive, icon: AppIcons.done),
        (value: 'INACTIVE', label: l10n.statusInactive, icon: AppIcons.close),
        (value: 'SUSPENDED', label: l10n.statusSuspended, icon: AppIcons.lock),
      ],
    );
    if (status == null || status == user.status || !context.mounted) return;
    final done = await runAdminAction(
      context,
      () =>
          ref.read(superAdminActionsProvider).updateUserStatus(user.id, status),
    );
    if (done && context.mounted) {
      await showSuccess(
        context,
        title: l10n.statusChanged,
        detail: adminStatusLabel(l10n, status),
      );
    }
  }

  Future<void> _changeRoles(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final roles = await showAppSheet<List<String>>(
      context,
      builder: (sheetContext) => _RolesPicker(
        initial: user.roles.where(assignableRoles.contains).toSet(),
      ),
    );
    if (roles == null || !context.mounted) return;
    final done = await runAdminAction(
      context,
      () => ref.read(superAdminActionsProvider).assignUserRoles(user.id, roles),
    );
    if (done && context.mounted) {
      await showSuccess(context, title: l10n.rolesChanged);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(adminBusyIdsProvider).contains(user.id);
    final canAct = enabled && !busy;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpace.l),
      children: <Widget>[
        AdminDetailHeader(
          icon: AppIcons.person,
          tone: AppTones.people,
          title: user.fullName,
          subtitle: user.roles
              .map((role) => adminRoleLabel(l10n, role))
              .join(', '),
          status: user.status,
        ),
        const SizedBox(height: AppSpace.l),
        Wrap(
          spacing: AppSpace.m,
          runSpacing: AppSpace.s,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: canAct ? () => _changeStatus(context, ref) : null,
              icon: const Icon(AppIcons.edit),
              label: Text(l10n.changeStatus),
            ),
            OutlinedButton.icon(
              onPressed: canAct ? () => _changeRoles(context, ref) : null,
              icon: const Icon(AppIcons.roles),
              label: Text(l10n.changeRoles),
            ),
          ],
        ),
        InfoSection(
          title: l10n.details,
          icon: AppIcons.person,
          lines: <InfoLine>[
            InfoLine(
              icon: AppIcons.phone,
              label: l10n.phone,
              value: user.phone,
            ),
            InfoLine(
              icon: AppIcons.email,
              label: l10n.email,
              value: user.email,
            ),
            InfoLine(
              icon: AppIcons.mosque,
              label: l10n.masjid,
              value: user.masjidName ?? user.masjidId,
            ),
            InfoLine(
              icon: AppIcons.family,
              label: l10n.fatherName,
              value: user.fatherName,
            ),
            InfoLine(
              icon: AppIcons.age,
              label: l10n.age,
              value: user.age?.toString(),
            ),
            InfoLine(
              icon: AppIcons.calendar,
              label: l10n.joinedOn,
              value: dateOrNull(user.createdAt),
            ),
          ],
        ),
      ],
    );
  }
}

/// Tick the roles to give; Save returns them.
class _RolesPicker extends StatefulWidget {
  const _RolesPicker({required this.initial});

  final Set<String> initial;

  @override
  State<_RolesPicker> createState() => _RolesPickerState();
}

class _RolesPickerState extends State<_RolesPicker> {
  late final Set<String> _selected = <String>{...widget.initial};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(l10n.changeRoles, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpace.m),
        for (final role in assignableRoles)
          CheckboxListTile(
            value: _selected.contains(role),
            title: Text(adminRoleLabel(l10n, role)),
            onChanged: (value) => setState(
              () =>
                  value == true ? _selected.add(role) : _selected.remove(role),
            ),
          ),
        const SizedBox(height: AppSpace.l),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(<String>[
            for (final role in assignableRoles)
              if (_selected.contains(role)) role,
          ]),
          child: Text(l10n.save),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
