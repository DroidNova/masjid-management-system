import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/announcement_summary.dart';

class AnnouncementPreviewCard extends StatelessWidget {
  const AnnouncementPreviewCard({
    super.key,
    required this.announcements,
    this.onViewAll,
    this.onAddAnnouncement,
  });

  final List<AnnouncementSummary> announcements;
  final VoidCallback? onViewAll;
  final VoidCallback? onAddAnnouncement;

  @override
  Widget build(BuildContext context) {
    final visibleAnnouncements = announcements.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Latest Announcements',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('View All'),
                ),
              ],
            ),
            if (onAddAnnouncement != null) ...<Widget>[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onAddAnnouncement,
                icon: const Icon(Icons.add),
                label: const Text('Add Announcement'),
              ),
            ],
            const SizedBox(height: 12),
            if (visibleAnnouncements.isEmpty)
              const Text('No announcements yet.')
            else
              ...visibleAnnouncements.map(
                (announcement) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        announcement.title ?? 'Announcement',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (announcement.message != null) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(announcement.message!),
                      ],
                      if (announcement.createdAt != null) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(
                          announcement.createdAt!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
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
