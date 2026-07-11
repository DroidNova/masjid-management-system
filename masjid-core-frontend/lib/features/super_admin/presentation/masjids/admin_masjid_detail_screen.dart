import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/super_admin/data/super_admin_repository.dart';
import 'package:platform_core_frontend/features/super_admin/models/admin_masjid_model.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/widgets_common.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';

class AdminMasjidDetailScreen extends StatelessWidget {
  const AdminMasjidDetailScreen({super.key, required this.id, this.initial});

  final String id;
  final AdminMasjidModel? initial;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Masjid Details')),
        body: FutureBuilder(
          future: SuperAdminRepository().getMasjid(id),
          initialData: initial,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LoadingView();
            final masjid = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                AdminStatusChip(masjid.status),
                InfoRow('Name', masjid.name),
                InfoRow('Location', [masjid.village, masjid.city, masjid.district, masjid.state, masjid.country].where((value) => value != null && value.isNotEmpty).join(', ')),
                InfoRow('Address', masjid.address),
                InfoRow('Requested By', masjid.requestedByName),
                InfoRow('Requester Phone', masjid.requestedByPhone),
                InfoRow('Requester Email', masjid.requestedByEmail),
                InfoRow('Contact', masjid.contactNo),
                InfoRow('Imam', masjid.imamName),
                InfoRow('Users', masjid.usersCount),
                InfoRow('Description', masjid.description),
                InfoRow('Created', masjid.createdAt),
              ],
            );
          },
        ),
      );
}
