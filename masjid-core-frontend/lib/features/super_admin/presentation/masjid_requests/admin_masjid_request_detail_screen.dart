import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/super_admin/data/super_admin_repository.dart';
import 'package:platform_core_frontend/features/super_admin/models/admin_masjid_request_model.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/widgets_common.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';

class AdminMasjidRequestDetailScreen extends StatelessWidget {
  const AdminMasjidRequestDetailScreen({super.key, required this.id, this.initial});

  final String id;
  final AdminMasjidRequestModel? initial;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Request Details')),
        body: FutureBuilder(
          future: SuperAdminRepository().getMasjidRequest(id),
          initialData: initial,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LoadingView();
            final request = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                AdminStatusChip(request.status),
                InfoRow('Masjid', request.masjidName),
                InfoRow('Requester', request.requesterName),
                InfoRow('Requester Phone', request.requesterPhone),
                InfoRow('Requester Email', request.requesterEmail),
                InfoRow('Location', [request.village, request.city, request.district, request.state, request.country].where((value) => value != null && value.isNotEmpty).join(', ')),
                InfoRow('Address', request.address),
                InfoRow('Contact', request.contactNo),
                InfoRow('Imam', request.imamName),
                InfoRow('Imam Phone', request.imamPhone),
                InfoRow('Reason', request.rejectionReason),
                InfoRow('Created', request.createdAt),
              ],
            );
          },
        ),
      );
}
