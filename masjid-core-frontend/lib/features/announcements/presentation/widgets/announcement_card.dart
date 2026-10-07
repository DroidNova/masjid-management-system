import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.onEdit,
    this.onDelete,
    this.deleting = false,
  });

  final AnnouncementModel announcement;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// A delete is in flight: the buttons are off and Delete shows progress.
  final bool deleting;

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
                AppFormat.dateTime(announcement.createdAt!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (onEdit != null || onDelete != null) ...<Widget>[
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: deleting ? null : onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                  if (onDelete != null)
                    TextButton.icon(
                      onPressed: deleting ? null : onDelete,
                      icon: deleting
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_outline),
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
