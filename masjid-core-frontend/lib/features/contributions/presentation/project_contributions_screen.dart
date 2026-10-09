import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/contributions/application/contribution_list_controllers.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/project_contribution.dart';
import 'package:masjid_core_frontend/features/contributions/presentation/widgets/giver_tile.dart';
import 'package:masjid_core_frontend/features/finance/presentation/money_categories.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Who gave to one project, by [projectId] (works from a fresh URL), grouped
/// by day, with search and cash / online chips. [projectTitle] comes from
/// route `extra`; without it the title is loaded.
class ProjectContributionsScreen extends ConsumerStatefulWidget {
  const ProjectContributionsScreen({
    super.key,
    required this.projectId,
    this.projectTitle,
  });

  final String projectId;
  final String? projectTitle;

  @override
  ConsumerState<ProjectContributionsScreen> createState() =>
      _ProjectContributionsScreenState();
}

class _ProjectContributionsScreenState
    extends ConsumerState<ProjectContributionsScreen> {
  String _search = '';
  String? _paymentMode;

  ProjectContributionsQuery get _query =>
      (projectId: widget.projectId, search: _search, paymentMode: _paymentMode);

  void _add() => context.push(
    Uri(
      path: '/contributions/new',
      queryParameters: <String, String>{'project': widget.projectId},
    ).toString(),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canAdd = PermissionHelper.canRecordContributions(
      ref.watch(currentPermissionsProvider),
    );
    // The title passed from the project page is used as is; only a fresh
    // URL loads it.
    final title =
        widget.projectTitle ??
        ref.watch(projectTitleProvider(widget.projectId)).valueOrNull ??
        l10n.tabProjects;
    final provider = projectContributionsProvider(_query);
    final controller = ref.read(provider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('${l10n.givers} · $title')),
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              backgroundColor: AppTones.moneyIn.color,
              foregroundColor: Colors.white,
              onPressed: _add,
              icon: const Icon(AppIcons.add),
              label: Text(l10n.addGiver),
            )
          : null,
      body: PagedListView<ProjectContribution>(
        value: ref.watch(provider),
        bottomPadding: canAdd ? 96 : AppSpace.xl,
        dayOf: (item) => item.paidAt,
        onRefresh: controller.refresh,
        onLoadMore: controller.loadMore,
        onRetry: () => ref.invalidate(provider),
        header: <Widget>[
          TextField(
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(AppIcons.search),
              hintText: l10n.searchPeople,
            ),
            onSubmitted: (value) => setState(() => _search = value.trim()),
          ),
          const SizedBox(height: AppSpace.s),
          Wrap(
            spacing: AppSpace.s,
            children: <Widget>[
              ChoiceChip(
                label: Text(l10n.all),
                selected: _paymentMode == null,
                onSelected: (_) => setState(() => _paymentMode = null),
              ),
              for (final mode in <String>['CASH', 'ONLINE'])
                ChoiceChip(
                  avatar: Icon(paymentModeIcon(mode), size: 20),
                  label: Text(paymentModeLabel(l10n, mode)),
                  selected: _paymentMode == mode,
                  onSelected: (_) => setState(
                    () => _paymentMode = _paymentMode == mode ? null : mode,
                  ),
                ),
            ],
          ),
        ],
        empty: listEmptyState(
          l10n: l10n,
          icon: AppIcons.zakat,
          tone: AppTones.moneyIn,
          title: l10n.noGiversYet,
          filtered: _search.isNotEmpty || _paymentMode != null,
          actionLabel: canAdd ? l10n.addGiver : null,
          onAction: _add,
        ),
        itemBuilder: (context, item) => GiverTile(
          name: item.contributorName,
          phone: item.contributorPhone,
          amount: item.amount,
          paymentMode: item.paymentMode,
          note: item.note,
        ),
      ),
    );
  }
}
