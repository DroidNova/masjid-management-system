import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/community/data/models/community_user_model.dart';

class CommunityUserCard extends StatelessWidget {
  const CommunityUserCard({
    super.key,
    required this.user,
    this.onEdit,
    this.onChangeStatus,
  });

  final CommunityUserModel user;
  final VoidCallback? onEdit;
  final VoidCallback? onChangeStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person_outline),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(user.primaryRoleLabel),
            if (user.phone != null) Text('Phone: ${user.phone}'),
            if (user.email != null) Text('Email: ${user.email}'),
            if (user.status != null) Text('Status: ${user.status}'),
            if (onEdit != null || onChangeStatus != null) ...<Widget>[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  if (onEdit != null)
                    OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                  if (onChangeStatus != null)
                    OutlinedButton.icon(
                      onPressed: onChangeStatus,
                      icon: const Icon(Icons.toggle_on_outlined),
                      label: const Text('Status'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
