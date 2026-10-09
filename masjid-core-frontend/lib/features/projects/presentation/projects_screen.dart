import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/projects/application/projects_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/data/models/projects_filter.dart';
import 'package:masjid_core_frontend/features/projects/presentation/widgets/project_card.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Projects (building work, repairs...): cards with a progress bar, search,
/// and status chips. Managers get "Add project".
class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final canManage = PermissionHelper.canManageProjects(
      ref.watch(currentPermissionsProvider),
    );
    final filter = ref.watch(projectsFilterProvider);
    final controller = ref.read(projectsControllerProvider.notifier);
    void update(ProjectsFilter next) =>
        ref.read(projectsFilterProvider.notifier).state = next;

    return Scaffold(
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              backgroundColor: AppTones.projects.color,
              foregroundColor: Colors.white,
              onPressed: () => context.push('/projects/add'),
              icon: const Icon(AppIcons.add),
              label: Text(l10n.addProject),
            )
          : null,
      body: PagedListView<ProjectModel>(
        value: ref.watch(projectsControllerProvider),
        bottomPadding: canManage ? 96 : AppSpace.xl,
        onRefresh: controller.refresh,
        onLoadMore: controller.loadMore,
        onRetry: () => ref.invalidate(projectsControllerProvider),
        header: <Widget>[
          TextField(
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(AppIcons.search),
              hintText: l10n.searchProjects,
            ),
            onSubmitted: (value) =>
                update(filter.copyWith(search: value.trim())),
          ),
          const SizedBox(height: AppSpace.s),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                ChoiceChip(
                  label: Text(l10n.all),
                  selected: filter.status == null,
                  onSelected: (_) => update(filter.copyWith(status: null)),
                ),
                for (final status in projectStatuses) ...<Widget>[
                  const SizedBox(width: AppSpace.s),
                  ChoiceChip(
                    avatar: Icon(projectStatusLook(l10n, status).$2, size: 20),
                    label: Text(projectStatusLook(l10n, status).$3),
                    selected: filter.status == status,
                    onSelected: (_) => update(
                      filter.copyWith(
                        status: filter.status == status ? null : status,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        empty: listEmptyState(
          l10n: l10n,
          icon: AppIcons.projects,
          tone: AppTones.projects,
          title: l10n.noProjectsYet,
          filtered: filter != const ProjectsFilter(),
          actionLabel: canManage ? l10n.addFirstProject : null,
          onAction: () => context.push('/projects/add'),
        ),
        itemBuilder: (context, project) => ProjectCard(
          project: project,
          onTap: () => context.push('/projects/${project.id}', extra: project),
        ),
      ),
    );
  }
}
