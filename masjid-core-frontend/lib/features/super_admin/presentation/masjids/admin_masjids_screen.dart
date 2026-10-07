import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_actions.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_controllers.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_model.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjids/widgets/admin_masjid_card.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjids/widgets/update_masjid_status_dialog.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/widgets/admin_action_feedback.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/widgets/admin_paged_list.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/widgets/admin_search_field.dart';

class AdminMasjidsScreen extends ConsumerWidget {
  const AdminMasjidsScreen({super.key});

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    AdminMasjidModel item,
  ) async {
    final status = await showUpdateMasjidStatusDialog(context);
    if (status == null || !context.mounted) return;
    await runAdminAction(
      context,
      () => ref
          .read(superAdminActionsProvider)
          .updateMasjidStatus(item.id, status),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(adminMasjidsFilterProvider);
    final filterController = ref.read(adminMasjidsFilterProvider.notifier);

    Widget statusChip(String label, String? status) => FilterChip(
      label: Text(label),
      selected: filter.status == status,
      onSelected: (_) =>
          filterController.state = filter.copyWith(status: status),
    );

    return Column(
      children: <Widget>[
        AdminSearchField(
          label: 'Search masjids',
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
            statusChip('Suspended', 'SUSPENDED'),
          ],
        ),
        Expanded(
          child: AdminPagedList<AdminMasjidModel>(
            state: ref.watch(adminMasjidsProvider),
            emptyText: 'No masjids found',
            onRefresh: () => ref.read(adminMasjidsProvider.notifier).refresh(),
            onLoadMore: () =>
                ref.read(adminMasjidsProvider.notifier).loadMore(),
            onRetry: () => ref.invalidate(adminMasjidsProvider),
            itemBuilder: (context, item) => AdminMasjidCard(
              item: item,
              onStatus: () => _changeStatus(context, ref, item),
            ),
          ),
        ),
      ],
    );
  }
}
