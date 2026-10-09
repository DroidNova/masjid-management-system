import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/features/super_admin/application/super_admin_controllers.dart';
import 'package:masjid_core_frontend/features/super_admin/data/models/admin_masjid_model.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/admin_parts.dart';
import 'package:masjid_core_frontend/features/super_admin/presentation/masjids/admin_masjid_detail_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Every masjid: search, status chips, and cards. Tapping one opens its
/// details (beside the list on desktop), where its status changes.
class AdminMasjidsScreen extends ConsumerStatefulWidget {
  const AdminMasjidsScreen({super.key});

  @override
  ConsumerState<AdminMasjidsScreen> createState() => _AdminMasjidsScreenState();
}

class _AdminMasjidsScreenState extends ConsumerState<AdminMasjidsScreen> {
  AdminMasjidModel? _picked;

  void _open(AdminMasjidModel item) {
    if (AdminSplitView.isSplit(context)) {
      setState(() => _picked = item);
    } else {
      context.go('/super-admin/masjids/${item.id}', extra: item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(adminMasjidsFilterProvider);
    final filterController = ref.read(adminMasjidsFilterProvider.notifier);
    final picked = _picked;
    final filtered = filter.search.isNotEmpty || filter.status != null;

    final list = PagedListView<AdminMasjidModel>(
      value: ref.watch(adminMasjidsProvider),
      header: <Widget>[
        AdminSearchField(
          hint: l10n.searchMasjids,
          initialValue: filter.search,
          onSearch: (search) => filterController.update(
            (current) => current.copyWith(search: search),
          ),
        ),
        const SizedBox(height: AppSpace.m),
        AdminFilterChips(
          options: <AdminFilter>[
            (value: null, label: l10n.all),
            (value: 'APPROVED', label: l10n.stepApproved),
            (value: 'PENDING', label: l10n.statusPending),
            (value: 'SUSPENDED', label: l10n.statusSuspended),
            (value: 'REJECTED', label: l10n.stepRejected),
          ],
          selected: filter.status,
          onSelected: (status) =>
              filterController.state = filter.copyWith(status: status),
        ),
        const SizedBox(height: AppSpace.s),
      ],
      onRefresh: () => ref.read(adminMasjidsProvider.notifier).refresh(),
      onLoadMore: () => ref.read(adminMasjidsProvider.notifier).loadMore(),
      onRetry: () => ref.invalidate(adminMasjidsProvider),
      empty: listEmptyState(
        icon: AppIcons.mosque,
        tone: AppTones.brand,
        title: l10n.noMasjids,
        filtered: filtered,
        l10n: l10n,
      ),
      itemBuilder: (context, item) => AdminListCard(
        leading: const ToneIcon(icon: AppIcons.mosque, tone: AppTones.brand),
        title: item.name,
        lines: <String>[
          placeLine(<String?>[item.locality, item.district, item.state]),
          placeLine(<String?>[
            if ((item.imamName ?? '').isNotEmpty)
              '${l10n.roleImam}: ${item.imamName}',
            l10n.peopleCount(item.usersCount),
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
          : AdminMasjidDetails(
              key: ValueKey<String>(picked.id),
              id: picked.id,
              initial: picked,
            ),
    );
  }
}
