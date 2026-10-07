import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_actions.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_controllers.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_user_model.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/users/widgets/assign_roles_dialog.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/users/widgets/update_user_status_dialog.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/widgets/admin_action_feedback.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/widgets_common.dart';
import 'package:masjid_core_frontend/shared/widgets/error_view.dart';
import 'package:masjid_core_frontend/shared/widgets/loading_view.dart';

/// User details, loaded by [id]. [initial] (from the list) is only shown
/// while the real data loads.
class AdminUserDetailScreen extends ConsumerWidget {
  const AdminUserDetailScreen({super.key, required this.id, this.initial});

  final String id;
  final AdminUserModel? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminUserProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: state.when(
        skipLoadingOnRefresh: true,
        skipLoadingOnReload: true,
        loading: () {
          final preview = initial;
          return preview == null
              ? const LoadingView()
              : _UserDetails(user: preview, enabled: false);
        },
        error: (error, _) => ErrorView(
          title: 'Unable to load user',
          message: userMessage(error),
          onRetry: () => ref.invalidate(adminUserProvider(id)),
        ),
        data: (user) => RefreshIndicator(
          onRefresh: () => ref.read(adminUserProvider(id).notifier).refresh(),
          child: _UserDetails(
            // The detail endpoint has no masjid; keep the list's value.
            user: user.masjidName == null && initial != null
                ? user.copyWith(
                    masjidId: initial!.masjidId,
                    masjidName: initial!.masjidName,
                  )
                : user,
          ),
        ),
      ),
    );
  }
}

class _UserDetails extends ConsumerWidget {
  const _UserDetails({required this.user, this.enabled = true});

  final AdminUserModel user;

  /// Actions are off while showing the preview.
  final bool enabled;

  Future<void> _changeStatus(BuildContext context, WidgetRef ref) async {
    final status = await showUpdateUserStatusDialog(context);
    if (status == null || !context.mounted) return;
    await runAdminAction(
      context,
      () =>
          ref.read(superAdminActionsProvider).updateUserStatus(user.id, status),
    );
  }

  Future<void> _assignRoles(BuildContext context, WidgetRef ref) async {
    final roles = await showAssignRolesDialog(context, user.roles);
    if (roles == null || !context.mounted) return;
    await runAdminAction(
      context,
      () => ref.read(superAdminActionsProvider).assignUserRoles(user.id, roles),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createdAt = user.createdAt;
    final busy = ref.watch(adminBusyIdsProvider).contains(user.id);
    final canAct = enabled && !busy;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        AdminStatusChip(user.status),
        InfoRow('Name', user.fullName),
        InfoRow('Phone', user.phone),
        InfoRow('Email', user.email),
        InfoRow('Roles', user.roles.join(', ')),
        InfoRow('Masjid', user.masjidName ?? user.masjidId),
        InfoRow(
          'Created',
          createdAt == null ? null : AppFormat.dateTime(createdAt),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          children: <Widget>[
            FilledButton(
              onPressed: canAct ? () => _changeStatus(context, ref) : null,
              child: const Text('Change Status'),
            ),
            FilledButton(
              onPressed: canAct ? () => _assignRoles(context, ref) : null,
              child: const Text('Assign Roles'),
            ),
          ],
        ),
      ],
    );
  }
}
