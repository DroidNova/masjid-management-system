import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_controllers.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_request_model.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/widgets_common.dart';
import 'package:masjid_core_frontend/shared/widgets/error_view.dart';
import 'package:masjid_core_frontend/shared/widgets/loading_view.dart';

/// Request details, loaded by [id]. [initial] (from the list) is only shown
/// while the real data loads.
class AdminMasjidRequestDetailScreen extends ConsumerWidget {
  const AdminMasjidRequestDetailScreen({
    super.key,
    required this.id,
    this.initial,
  });

  final String id;
  final AdminMasjidRequestModel? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: ref
          .watch(adminRequestProvider(id))
          .when(
            skipLoadingOnRefresh: true,
            skipLoadingOnReload: true,
            loading: () {
              final preview = initial;
              return preview == null
                  ? const LoadingView()
                  : _RequestDetails(request: preview);
            },
            error: (error, _) => ErrorView(
              title: 'Unable to load request',
              message: userMessage(error),
              onRetry: () => ref.invalidate(adminRequestProvider(id)),
            ),
            data: (request) => _RequestDetails(request: request),
          ),
    );
  }
}

class _RequestDetails extends StatelessWidget {
  const _RequestDetails({required this.request});

  final AdminMasjidRequestModel request;

  @override
  Widget build(BuildContext context) {
    final r = request;
    final createdAt = r.createdAt;
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        AdminStatusChip(r.status),
        Text('Masjid Details', style: titleStyle),
        InfoRow('Masjid', r.masjidName),
        InfoRow('Country', r.country),
        InfoRow('State', r.state),
        InfoRow('District', r.district),
        InfoRow('City / Village / Town', r.locality),
        InfoRow('Address', r.address),
        InfoRow('Phone', r.contactNo),
        InfoRow('Welcome Message', r.welcomeMsg),
        InfoRow('Description', r.description),
        const Divider(),
        Text('Requester Details', style: titleStyle),
        InfoRow('Requester', r.requesterName),
        InfoRow('Phone', r.requesterPhone),
        InfoRow('Email', r.requesterEmail),
        const Divider(),
        Text('Imam Details', style: titleStyle),
        InfoRow('Imam', r.imamName),
        InfoRow('Phone', r.imamPhone),
        InfoRow('Email', r.imamEmail),
        InfoRow('Address', r.imamAddress),
        const Divider(),
        Text('Committee Members', style: titleStyle),
        for (final member in r.committeeMembers)
          InfoRow(
            'Member',
            <String?>[
              member.name,
              member.phone,
            ].whereType<String>().where((part) => part.isNotEmpty).join(' • '),
          ),
        InfoRow('Reason', r.rejectionReason),
        InfoRow(
          'Created',
          createdAt == null ? null : AppFormat.dateTime(createdAt),
        ),
      ],
    );
  }
}
