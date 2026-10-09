import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_actions.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_controllers.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_request_model.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/admin_parts.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// A request to add a masjid, as its own page (phones and tablets).
class AdminMasjidRequestDetailScreen extends StatelessWidget {
  const AdminMasjidRequestDetailScreen({
    super.key,
    required this.id,
    this.initial,
  });

  final String id;
  final AdminMasjidRequestModel? initial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).request)),
      body: AdminMasjidRequestDetails(id: id, initial: initial),
    );
  }
}

/// The request's masjid, requester, imam, and committee, with Approve
/// and Reject while it waits. Loaded by [id]; [initial] (from the list)
/// shows while it loads.
class AdminMasjidRequestDetails extends ConsumerWidget {
  const AdminMasjidRequestDetails({super.key, required this.id, this.initial});

  final String id;
  final AdminMasjidRequestModel? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = adminRequestProvider(id);
    return ref
        .watch(provider)
        .when(
          skipLoadingOnRefresh: true,
          skipLoadingOnReload: true,
          loading: () {
            final preview = initial;
            return preview == null
                ? const SkeletonList()
                : _Content(request: preview, enabled: false);
          },
          error: (error, _) =>
              ErrorState(error: error, onRetry: () => ref.invalidate(provider)),
          data: (request) => RefreshIndicator(
            onRefresh: () => ref.read(provider.notifier).refresh(),
            child: _Content(request: request),
          ),
        );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.request, this.enabled = true});

  final AdminMasjidRequestModel request;

  /// Actions are off while showing the preview.
  final bool enabled;

  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      icon: AppIcons.done,
      tone: AppTones.done,
      title: l10n.approveQuestion,
      message: '${request.masjidName}\n${l10n.approveHelp}',
      confirmLabel: l10n.approve,
    );
    if (!confirmed || !context.mounted) return;
    final done = await runAdminAction(
      context,
      () =>
          ref.read(superAdminActionsProvider).approveMasjidRequest(request.id),
    );
    if (done && context.mounted) {
      await showSuccess(
        context,
        title: l10n.requestApproved,
        detail: request.masjidName,
      );
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final reason = await askReason(
      context,
      title: l10n.rejectQuestion,
      confirmLabel: l10n.reject,
    );
    if (reason == null || !context.mounted) return;
    final done = await runAdminAction(
      context,
      () => ref
          .read(superAdminActionsProvider)
          .rejectMasjidRequest(
            request.id,
            reason: reason.isEmpty ? null : reason,
          ),
    );
    if (done && context.mounted) {
      await showSuccess(
        context,
        title: l10n.requestRejected,
        detail: request.masjidName,
        icon: AppIcons.close,
        tone: AppTones.neutral,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final r = request;
    final busy = ref.watch(adminBusyIdsProvider).contains(r.id);
    final canAct = enabled && !busy && r.isPending;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpace.l),
      children: <Widget>[
        AdminDetailHeader(
          icon: AppIcons.mosque,
          tone: AppTones.brand,
          title: r.masjidName,
          subtitle: placeLine(<String?>[r.locality, r.district, r.state]),
          status: r.status,
        ),
        if ((r.rejectionReason ?? '').isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpace.l),
          MessageBanner(text: '${l10n.reason}: ${r.rejectionReason}'),
        ],
        if (r.isPending) ...<Widget>[
          const SizedBox(height: AppSpace.l),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTones.done.color,
                  ),
                  onPressed: canAct ? () => _approve(context, ref) : null,
                  icon: const Icon(AppIcons.done),
                  label: Text(l10n.approve),
                ),
              ),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTones.problem.color,
                  ),
                  onPressed: canAct ? () => _reject(context, ref) : null,
                  icon: const Icon(AppIcons.close),
                  label: Text(l10n.reject),
                ),
              ),
            ],
          ),
        ],
        InfoSection(
          title: l10n.stepMasjid,
          icon: AppIcons.mosque,
          lines: <InfoLine>[
            InfoLine(
              icon: AppIcons.place,
              label: l10n.address,
              value: placeLine(<String?>[
                r.address,
                r.locality,
                r.district,
                r.state,
                r.country,
              ]),
            ),
            InfoLine(
              icon: AppIcons.phone,
              label: l10n.phone,
              value: r.contactNo,
            ),
            InfoLine(
              icon: AppIcons.announcements,
              label: l10n.welcomeMessage,
              value: r.welcomeMsg,
            ),
            InfoLine(
              icon: AppIcons.info,
              label: l10n.aboutMasjid,
              value: r.description,
            ),
            InfoLine(
              icon: AppIcons.calendar,
              label: l10n.sentOn,
              value: dateOrNull(r.createdAt),
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
              value: r.requesterName,
            ),
            InfoLine(
              icon: AppIcons.phone,
              label: l10n.phone,
              value: r.requesterPhone,
            ),
            InfoLine(
              icon: AppIcons.email,
              label: l10n.email,
              value: r.requesterEmail,
            ),
          ],
        ),
        InfoSection(
          title: l10n.stepImam,
          icon: AppIcons.imam,
          lines: <InfoLine>[
            InfoLine(
              icon: AppIcons.person,
              label: l10n.fullName,
              value: r.imamName,
            ),
            InfoLine(
              icon: AppIcons.phone,
              label: l10n.phone,
              value: r.imamPhone,
            ),
            InfoLine(
              icon: AppIcons.email,
              label: l10n.email,
              value: r.imamEmail,
            ),
            InfoLine(
              icon: AppIcons.family,
              label: l10n.fatherName,
              value: r.imamFatherName,
            ),
            InfoLine(
              icon: AppIcons.age,
              label: l10n.age,
              value: r.imamAge?.toString(),
            ),
            InfoLine(
              icon: AppIcons.place,
              label: l10n.address,
              value: r.imamAddress,
            ),
          ],
        ),
        InfoSection(
          title: l10n.stepCommittee,
          icon: AppIcons.people,
          lines: <InfoLine>[
            for (final member in r.committeeMembers)
              InfoLine(
                icon: AppIcons.person,
                label: member.name ?? '',
                value: placeLine(<String?>[member.phone, member.fatherName]),
              ),
          ],
        ),
      ],
    );
  }
}
