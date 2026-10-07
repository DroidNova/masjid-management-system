import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_actions.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_controllers.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_request_model.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjid_requests/widgets/admin_masjid_request_card.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjid_requests/widgets/approve_reject_request_dialog.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/widgets/admin_action_feedback.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/widgets/admin_paged_list.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/widgets/admin_search_field.dart';

class AdminMasjidRequestsScreen extends ConsumerWidget {
  const AdminMasjidRequestsScreen({super.key});

  Future<void> _approve(
    BuildContext context,
    WidgetRef ref,
    AdminMasjidRequestModel item,
  ) => runAdminAction(
    context,
    () => ref.read(superAdminActionsProvider).approveMasjidRequest(item.id),
  );

  Future<void> _reject(
    BuildContext context,
    WidgetRef ref,
    AdminMasjidRequestModel item,
  ) async {
    final reason = await showRejectReasonDialog(context);
    if (reason == null || !context.mounted) return;
    await runAdminAction(
      context,
      () => ref
          .read(superAdminActionsProvider)
          .rejectMasjidRequest(item.id, reason: reason.isEmpty ? null : reason),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(adminRequestsFilterProvider);
    final filterController = ref.read(adminRequestsFilterProvider.notifier);

    Widget statusChip(String label, String? status) => FilterChip(
      label: Text(label),
      selected: filter.status == status,
      onSelected: (_) =>
          filterController.state = filter.copyWith(status: status),
    );

    return Column(
      children: <Widget>[
        AdminSearchField(
          label: 'Search requests',
          hint: 'Search by masjid, locality, district, state, or phone',
          initialValue: filter.search,
          onSearch: (search) => filterController.update(
            (current) => current.copyWith(search: search),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            statusChip('All', null),
            statusChip('Pending', 'PENDING'),
            statusChip('Approved', 'APPROVED'),
            statusChip('Rejected', 'REJECTED'),
          ],
        ),
        Expanded(
          child: AdminPagedList<AdminMasjidRequestModel>(
            state: ref.watch(adminRequestsProvider),
            emptyText: 'No requests found',
            onRefresh: () => ref.read(adminRequestsProvider.notifier).refresh(),
            onLoadMore: () =>
                ref.read(adminRequestsProvider.notifier).loadMore(),
            onRetry: () => ref.invalidate(adminRequestsProvider),
            itemBuilder: (context, item) => AdminMasjidRequestCard(
              item: item,
              onApprove: () => _approve(context, ref, item),
              onReject: () => _reject(context, ref, item),
            ),
          ),
        ),
      ],
    );
  }
}
