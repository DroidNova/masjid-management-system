import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/announcements/data/models/announcement_model.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.onEdit,
    this.onDelete,
  });

  final AnnouncementModel announcement;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    announcement.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Chip(
                  label: Text(announcement.isActive ? 'Active' : 'Inactive'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(announcement.message),
            if (announcement.createdAt != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                announcement.createdAt!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (onEdit != null || onDelete != null) ...<Widget>[
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
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
