import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/community/application/community_controller.dart';
import 'package:masjid_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:masjid_core_frontend/features/community/data/models/update_community_user_request.dart';
import 'package:masjid_core_frontend/features/community/presentation/widgets/community_error_view.dart';
import 'package:masjid_core_frontend/features/community/presentation/widgets/community_section.dart';
import 'package:masjid_core_frontend/features/community/presentation/widgets/edit_community_user_dialog.dart';
import 'package:masjid_core_frontend/features/community/presentation/widgets/masjid_info_card.dart';
import 'package:masjid_core_frontend/features/community/presentation/widgets/user_status_dialog.dart';
import 'package:masjid_core_frontend/shared/widgets/loading_view.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityState = ref.watch(communityControllerProvider);

    return communityState.when(
      // Keep showing data while it reloads after an edit or pull-to-refresh.
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      loading: () => const LoadingView(),
      error: (error, _) {
        if (error is ApiException && error.isUnauthorized) {
          return CommunityErrorView(
            message: 'Session expired. Please login again.',
            buttonLabel: 'Back to Login',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          );
        }
        final noMasjid =
            error is ApiException &&
            error.code == ApiErrorCodes.userMasjidNotAssigned;
        return CommunityErrorView(
          message: noMasjid
              ? 'You are not assigned to any masjid yet.'
              : 'Unable to load community details.',
          detail: noMasjid ? null : userMessage(error),
          onPressed: () => ref.invalidate(communityControllerProvider),
        );
      },
      data: (data) => _CommunityContent(data: data),
    );
  }
}

class _CommunityContent extends ConsumerWidget {
  const _CommunityContent({required this.data});

  final CommunityData data;

  Future<void> _editUser(
    BuildContext context,
    WidgetRef ref,
    CommunityUserModel user,
  ) async {
    final result = await showDialog<UpdateCommunityUserRequest>(
      context: context,
      builder: (context) => EditCommunityUserDialog(user: user),
    );
    if (result == null || !context.mounted) return;
    await _run(
      context,
      () => ref
          .read(communityControllerProvider.notifier)
          .updateUser(user.id, result),
      success: 'User updated successfully.',
    );
  }

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    CommunityUserModel user,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => UserStatusDialog(currentStatus: user.status),
    );
    if (result == null || !context.mounted) return;
    await _run(
      context,
      () => ref
          .read(communityControllerProvider.notifier)
          .changeUserStatus(user.id, result),
      success: 'User status updated successfully.',
    );
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action, {
    required String success,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(success)));
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(userMessage(error))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(currentPermissionsProvider);
    final canAddUsers = PermissionHelper.canAddCommunityUser(permissions);
    final busyUserIds = ref.watch(communityBusyUserIdsProvider);

    Widget section(
      String title,
      List<CommunityUserModel> users,
      String emptyMessage,
    ) => CommunitySection(
      title: title,
      users: users,
      emptyMessage: emptyMessage,
      currentUserPermissions: permissions,
      onEditUser: (user) => _editUser(context, ref, user),
      onChangeUserStatus: (user) => _changeStatus(context, ref, user),
      busyUserIds: busyUserIds,
    );

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(communityControllerProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Community',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text('Masjid members and committee details'),
                    if (canAddUsers) ...<Widget>[
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                          onPressed: () => context.push('/community/add-user'),
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text('Add User'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    MasjidInfoCard(masjid: data.masjid),
                    const SizedBox(height: 12),
                    section('Imam', data.imamUsers, 'Imam is not added yet.'),
                    const SizedBox(height: 12),
                    section(
                      'Committee Members',
                      data.committeeUsers,
                      'No committee members added yet.',
                    ),
                    const SizedBox(height: 12),
                    section(
                      'Members',
                      data.memberUsers,
                      'No members added yet.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
