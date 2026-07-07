import 'package:flutter/material.dart';

class AnnouncementEmptyView extends StatelessWidget {
  const AnnouncementEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: <Widget>[
            Icon(
              Icons.campaign_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            const Text('No announcements added yet.'),
          ],
        ),
      ),
    );
  }
}
