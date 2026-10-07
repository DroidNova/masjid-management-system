import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_controllers.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_model.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/widgets_common.dart';
import 'package:masjid_core_frontend/shared/widgets/error_view.dart';
import 'package:masjid_core_frontend/shared/widgets/loading_view.dart';

/// Masjid details, loaded by [id]. [initial] (from the list) is only shown
/// while the real data loads.
class AdminMasjidDetailScreen extends ConsumerWidget {
  const AdminMasjidDetailScreen({super.key, required this.id, this.initial});

  final String id;
  final AdminMasjidModel? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masjid Details')),
      body: ref
          .watch(adminMasjidProvider(id))
          .when(
            skipLoadingOnRefresh: true,
            skipLoadingOnReload: true,
            loading: () {
              final preview = initial;
              return preview == null
                  ? const LoadingView()
                  : _MasjidDetails(masjid: preview);
            },
            error: (error, _) => ErrorView(
              title: 'Unable to load masjid',
              message: userMessage(error),
              onRetry: () => ref.invalidate(adminMasjidProvider(id)),
            ),
            data: (masjid) => RefreshIndicator(
              onRefresh: () =>
                  ref.read(adminMasjidProvider(id).notifier).refresh(),
              child: _MasjidDetails(masjid: masjid),
            ),
          ),
    );
  }
}

class _MasjidDetails extends StatelessWidget {
  const _MasjidDetails({required this.masjid});

  final AdminMasjidModel masjid;

  @override
  Widget build(BuildContext context) {
    final m = masjid;
    final createdAt = m.createdAt;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        AdminStatusChip(m.status),
        InfoRow('Name', m.name),
        InfoRow('Country', m.country),
        InfoRow('State', m.state),
        InfoRow('District', m.district),
        InfoRow('City / Village / Town', m.locality),
        InfoRow('Address', m.address),
        InfoRow('Contact', m.contactNo),
        InfoRow('Requester', m.requestedByName),
        InfoRow('Requester Phone', m.requestedByPhone),
        InfoRow('Requester Email', m.requestedByEmail),
        InfoRow('Imam', m.imamName),
        InfoRow('Users', m.usersCount),
        InfoRow('Welcome Message', m.welcomeMsg),
        InfoRow('Description', m.description),
        if (m.rejectionReason != null) InfoRow('Reason', m.rejectionReason),
        InfoRow(
          'Created',
          createdAt == null ? null : AppFormat.dateTime(createdAt),
        ),
      ],
    );
  }
}
