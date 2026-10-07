import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:masjid_core_frontend/features/community/presentation/widgets/community_empty_view.dart';
import 'package:masjid_core_frontend/features/community/presentation/widgets/community_user_card.dart';

class CommunitySection extends StatelessWidget {
  const CommunitySection({
    super.key,
    required this.title,
    required this.users,
    required this.emptyMessage,
    this.subtitle,
    this.currentUserPermissions = const <String>[],
    this.onEditUser,
    this.onChangeUserStatus,
    this.busyUserIds = const <String>{},
  });

  final String title;
  final String? subtitle;
  final List<CommunityUserModel> users;
  final String emptyMessage;
  final List<String> currentUserPermissions;
  final ValueChanged<CommunityUserModel>? onEditUser;
  final ValueChanged<CommunityUserModel>? onChangeUserStatus;

  /// Users with a change in flight.
  final Set<String> busyUserIds;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: 4),
              Text(subtitle!),
            ],
            const SizedBox(height: 12),
            if (users.isEmpty)
              CommunityEmptyView(message: emptyMessage)
            else
              ...users.map((user) {
                final canManage = PermissionHelper.canManageCommunityUser(
                  currentUserPermissions: currentUserPermissions,
                  targetUserRoles: user.roles,
                );
                return CommunityUserCard(
                  user: user,
                  busy: busyUserIds.contains(user.id),
                  onEdit: canManage ? () => onEditUser?.call(user) : null,
                  onChangeStatus: canManage
                      ? () => onChangeUserStatus?.call(user)
                      : null,
                );
              }),
          ],
        ),
      ),
    );
  }
}
