import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_controllers.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_request_model.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/admin_parts.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjid_requests/admin_masjid_request_detail_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Requests to add a masjid: search, status chips, and cards. Tapping one
/// opens its details (beside the list on desktop), where it is approved
/// or rejected.
class AdminMasjidRequestsScreen extends ConsumerStatefulWidget {
  const AdminMasjidRequestsScreen({super.key});

  @override
  ConsumerState<AdminMasjidRequestsScreen> createState() =>
      _AdminMasjidRequestsScreenState();
}

class _AdminMasjidRequestsScreenState
    extends ConsumerState<AdminMasjidRequestsScreen> {
  AdminMasjidRequestModel? _picked;

  void _open(AdminMasjidRequestModel item) {
    if (AdminSplitView.isSplit(context)) {
      setState(() => _picked = item);
    } else {
      context.go('/super-admin/requests/${item.id}', extra: item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(adminRequestsFilterProvider);
    final filterController = ref.read(adminRequestsFilterProvider.notifier);
    final picked = _picked;
    final filtered = filter.search.isNotEmpty || filter.status != null;

    final list = PagedListView<AdminMasjidRequestModel>(
      value: ref.watch(adminRequestsProvider),
      header: <Widget>[
        AdminSearchField(
          hint: l10n.searchRequests,
          initialValue: filter.search,
          onSearch: (search) => filterController.update(
            (current) => current.copyWith(search: search),
          ),
        ),
        const SizedBox(height: AppSpace.m),
        AdminFilterChips(
          options: <AdminFilter>[
            (value: null, label: l10n.all),
            (value: 'PENDING', label: l10n.statusPending),
            (value: 'APPROVED', label: l10n.stepApproved),
            (value: 'REJECTED', label: l10n.stepRejected),
          ],
          selected: filter.status,
          onSelected: (status) =>
              filterController.state = filter.copyWith(status: status),
        ),
        const SizedBox(height: AppSpace.s),
      ],
      onRefresh: () => ref.read(adminRequestsProvider.notifier).refresh(),
      onLoadMore: () => ref.read(adminRequestsProvider.notifier).loadMore(),
      onRetry: () => ref.invalidate(adminRequestsProvider),
      empty: listEmptyState(
        icon: AppIcons.requests,
        tone: AppTones.news,
        title: l10n.noRequests,
        filtered: filtered,
        l10n: l10n,
      ),
      itemBuilder: (context, item) => AdminListCard(
        leading: const ToneIcon(icon: AppIcons.mosque, tone: AppTones.brand),
        title: item.masjidName,
        lines: <String>[
          placeLine(<String?>[item.locality, item.district, item.state]),
          placeLine(<String?>[
            item.requesterName,
            AppFormat.phoneOrNull(item.requesterPhone),
          ]),
        ],
        status: item.status,
        selected: picked?.id == item.id,
        onTap: () => _open(item),
      ),
    );

    return AdminSplitView(
      list: list,
      detail: picked == null
          ? null
          : AdminMasjidRequestDetails(
              key: ValueKey<String>(picked.id),
              id: picked.id,
              initial: picked,
            ),
    );
  }
}
