import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_actions.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_controllers.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_model.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/admin_parts.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// The server needs a reason for these masjid statuses.
bool masjidStatusNeedsReason(String status) =>
    status == 'REJECTED' || status == 'SUSPENDED';

/// A masjid, as its own page (phones and tablets).
class AdminMasjidDetailScreen extends StatelessWidget {
  const AdminMasjidDetailScreen({super.key, required this.id, this.initial});

  final String id;
  final AdminMasjidModel? initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).stepMasjid)),
      body: AdminMasjidDetails(id: id, initial: initial),
    );
  }
}

/// A masjid's place, contact, imam, and who asked for it, with Change
/// status. Loaded by [id]; [initial] (from the list) shows while it loads.
class AdminMasjidDetails extends ConsumerWidget {
  const AdminMasjidDetails({super.key, required this.id, this.initial});

  final String id;
  final AdminMasjidModel? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = adminMasjidProvider(id);
    return ref
        .watch(provider)
        .when(
          skipLoadingOnRefresh: true,
          skipLoadingOnReload: true,
          loading: () {
            final preview = initial;
            return preview == null
                ? const SkeletonList()
                : _Content(masjid: preview, enabled: false);
          },
          error: (error, _) =>
              ErrorState(error: error, onRetry: () => ref.invalidate(provider)),
          data: (masjid) => RefreshIndicator(
            onRefresh: () => ref.read(provider.notifier).refresh(),
            child: _Content(masjid: masjid),
          ),
        );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.masjid, this.enabled = true});

  final AdminMasjidModel masjid;

  /// Actions are off while showing the preview.
  final bool enabled;

  Future<void> _changeStatus(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final status = await pickOption(
      context,
      title: l10n.changeStatus,
      current: masjid.status,
      options: <AdminOption>[
        (value: 'APPROVED', label: l10n.stepApproved, icon: AppIcons.done),
        (value: 'PENDING', label: l10n.statusPending, icon: AppIcons.waiting),
        (value: 'SUSPENDED', label: l10n.statusSuspended, icon: AppIcons.lock),
        (value: 'REJECTED', label: l10n.stepRejected, icon: AppIcons.close),
      ],
    );
    if (status == null || status == masjid.status || !context.mounted) return;
    String? reason;
    if (masjidStatusNeedsReason(status)) {
      reason = await askReason(
        context,
        title: '${l10n.reason}: ${adminStatusLabel(l10n, status)}',
        confirmLabel: l10n.save,
        required: true,
      );
      if (reason == null || !context.mounted) return;
    }
    final done = await runAdminAction(
      context,
      () => ref
          .read(superAdminActionsProvider)
          .updateMasjidStatus(masjid.id, status, reason: reason),
    );
    if (done && context.mounted) {
      await showSuccess(
        context,
        title: l10n.statusChanged,
        detail: adminStatusLabel(l10n, status),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final m = masjid;
    final busy = ref.watch(adminBusyIdsProvider).contains(m.id);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpace.l),
      children: <Widget>[
        AdminDetailHeader(
          icon: AppIcons.mosque,
          tone: AppTones.brand,
          title: m.name,
          subtitle: placeLine(<String?>[m.locality, m.district, m.state]),
          status: m.status,
        ),
        if ((m.rejectionReason ?? '').isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpace.l),
          MessageBanner(text: '${l10n.reason}: ${m.rejectionReason}'),
        ],
        const SizedBox(height: AppSpace.l),
        OutlinedButton.icon(
          onPressed: enabled && !busy
              ? () => _changeStatus(context, ref)
              : null,
          icon: const Icon(AppIcons.edit),
          label: Text(l10n.changeStatus),
        ),
        InfoSection(
          title: l10n.stepMasjid,
          icon: AppIcons.mosque,
          lines: <InfoLine>[
            InfoLine(
              icon: AppIcons.people,
              label: l10n.tabPeople,
              value: l10n.peopleCount(m.usersCount),
            ),
            InfoLine(
              icon: AppIcons.imam,
              label: l10n.roleImam,
              value: m.imamName,
            ),
            InfoLine(
              icon: AppIcons.place,
              label: l10n.address,
              value: placeLine(<String?>[
                m.address,
                m.locality,
                m.district,
                m.state,
                m.country,
              ]),
            ),
            InfoLine(
              icon: AppIcons.phone,
              label: l10n.phone,
              value: m.contactNo,
            ),
            InfoLine(
              icon: AppIcons.announcements,
              label: l10n.welcomeMessage,
              value: m.welcomeMsg,
            ),
            InfoLine(
              icon: AppIcons.info,
              label: l10n.aboutMasjid,
              value: m.description,
            ),
            InfoLine(
              icon: AppIcons.calendar,
              label: l10n.sentOn,
              value: dateOrNull(m.createdAt),
            ),
          ],
        ),
        InfoSection(
          title: l10n.requester,
          icon: AppIcons.send,
          lines: <InfoLine>[
            InfoLine(
              icon: AppIcons.person,
              label: l10n.fullName,
              value: m.requestedByName,
            ),
            InfoLine(
              icon: AppIcons.phone,
              label: l10n.phone,
              value: m.requestedByPhone,
            ),
            InfoLine(
              icon: AppIcons.email,
              label: l10n.email,
              value: m.requestedByEmail,
            ),
          ],
        ),
      ],
    );
  }
}
