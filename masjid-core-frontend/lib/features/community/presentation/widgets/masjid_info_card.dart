import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/community/data/models/masjid_detail_model.dart';

class MasjidInfoCard extends StatelessWidget {
  const MasjidInfoCard({super.key, required this.masjid});

  final MasjidDetailModel masjid;

  @override
  Widget build(BuildContext context) {
    final location = [
      masjid.address,
      masjid.locality,
      masjid.district,
      masjid.state,
      masjid.country,
    ].where((value) => value != null && value.trim().isNotEmpty).join(', ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              masjid.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (location.isNotEmpty) ...<Widget>[
              const SizedBox(height: 6),
              Text(location),
            ],
            if (masjid.contactNo != null) Text('Contact: ${masjid.contactNo}'),
            if (masjid.address != null) Text('Address: ${masjid.address}'),
            if (masjid.welcomeMsg != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(masjid.welcomeMsg!),
            ],
            if (masjid.status != null) ...<Widget>[
              const SizedBox(height: 8),
              Chip(label: Text(masjid.status!)),
            ],
          ],
        ),
      ),
    );
  }
}
