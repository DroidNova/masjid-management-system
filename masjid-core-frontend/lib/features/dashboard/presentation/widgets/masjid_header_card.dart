import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/imam_summary.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/masjid_summary.dart';
import 'package:platform_core_frontend/features/dashboard/presentation/widgets/dashboard_format.dart';

class MasjidHeaderCard extends StatelessWidget {
  const MasjidHeaderCard({
    super.key,
    required this.masjid,
    required this.imam,
    required this.membersCount,
  });

  final MasjidSummary? masjid;
  final ImamSummary? imam;
  final int membersCount;

  @override
  Widget build(BuildContext context) {
    final location = [masjid?.village, masjid?.city, masjid?.district]
        .where((item) => item != null && item.trim().isNotEmpty)
        .join(', ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Assalamu Alaikum',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              masjid?.name ?? 'Your Masjid',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (location.isNotEmpty) ...<Widget>[
              const SizedBox(height: 6),
              Text(location),
            ],
            if (masjid?.welcomeMsg != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(masjid!.welcomeMsg!),
            ],
            const Divider(height: 28),
            Text('Imam: ${valueOrDash(imam?.fullName)}'),
            if (imam?.phone != null) Text('Phone: ${imam!.phone}'),
            Text('Members: $membersCount'),
          ],
        ),
      ),
    );
  }
}
