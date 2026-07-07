import 'package:flutter/material.dart';
import 'package:platform_core_frontend/core/permissions/permission_helper.dart';
import 'package:platform_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:platform_core_frontend/features/community/presentation/widgets/community_empty_view.dart';
import 'package:platform_core_frontend/features/community/presentation/widgets/community_user_card.dart';

class CommunitySection extends StatelessWidget {
  const CommunitySection({
    super.key,
    required this.title,
    required this.users,
    required this.emptyMessage,
    this.subtitle,
    this.currentUserRoles = const <String>[],
    this.onEditUser,
    this.onChangeUserStatus,
  });

  final String title;
  final String? subtitle;
  final List<CommunityUserModel> users;
  final String emptyMessage;
  final List<String> currentUserRoles;
  final ValueChanged<CommunityUserModel>? onEditUser;
  final ValueChanged<CommunityUserModel>? onChangeUserStatus;

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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                  currentUserRoles: currentUserRoles,
                  targetUserRoles: user.roles,
                );
                return CommunityUserCard(
                  user: user,
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
