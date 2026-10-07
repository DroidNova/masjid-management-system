import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/projects/application/projects_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/data/models/projects_filter.dart';
import 'package:masjid_core_frontend/features/projects/presentation/widgets/project_card.dart';
import 'package:masjid_core_frontend/features/projects/presentation/widgets/project_empty_view.dart';
import 'package:masjid_core_frontend/shared/widgets/app_button.dart';
import 'package:masjid_core_frontend/shared/widgets/loading_view.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsState = ref.watch(projectsControllerProvider);

    if (!projectsState.hasValue && !projectsState.hasError) {
      return const LoadingView();
    }

    if (projectsState.hasError && !projectsState.isLoading) {
      final error = projectsState.error!;
      final noMasjid =
          error is ApiException &&
          error.code == ApiErrorCodes.userMasjidNotAssigned;
      if (noMasjid) {
        return _ProjectsErrorView(
          message: 'You are not assigned to any masjid yet.',
          buttonLabel: 'Logout / Back to Login',
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
        );
      }
      return _ProjectsErrorView(
        message: 'Unable to load projects.',
        detail: userMessage(error),
        onPressed: () => ref.invalidate(projectsControllerProvider),
      );
    }

    return _ProjectsContent(state: projectsState);
  }
}

class _ProjectsContent extends ConsumerWidget {
  const _ProjectsContent({required this.state});

  final AsyncValue<PagedState<ProjectModel>> state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManageProjects = PermissionHelper.canManageProjects(
      ref.watch(currentPermissionsProvider),
    );
    final filter = ref.watch(projectsFilterProvider);
    final controller = ref.read(projectsControllerProvider.notifier);
    final paged = state.valueOrNull;
    // A filter change reloads the list; the header and chips stay.
    final reloading = state.isReloading;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: controller.refresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.extentAfter < 300) controller.loadMore();
            return false;
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Projects',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text('Track masjid construction and repair work'),
                      const SizedBox(height: 16),
                      if (canManageProjects) ...<Widget>[
                        AppButton(
                          label: 'Add Project',
                          onPressed: () => context.push('/projects/add'),
                        ),
                        const SizedBox(height: 16),
                      ],
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: <Widget>[
                            for (final entry in _filters.entries) ...<Widget>[
                              FilterChip(
                                label: Text(entry.value),
                                selected: filter.status == entry.key,
                                onSelected: (_) => ref
                                    .read(projectsFilterProvider.notifier)
                                    .update(
                                      (current) =>
                                          current.copyWith(status: entry.key),
                                    ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (reloading || paged == null)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (paged.items.isEmpty)
                        ProjectEmptyView(
                          message: filter == const ProjectsFilter()
                              ? 'No projects added yet.'
                              : 'No projects match this filter.',
                        )
                      else ...<Widget>[
                        ...paged.items.map(
                          (project) => ProjectCard(
                            key: ValueKey<String>(project.id),
                            project: project,
                            onTap: () => context.push(
                              '/projects/${project.id}',
                              extra: project,
                            ),
                          ),
                        ),
                        _LoadMoreFooter(
                          state: paged,
                          onLoadMore: controller.loadMore,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Status filter chips; null means all.
  static const Map<String?, String> _filters = <String?, String>{
    null: 'All',
    'PLANNED': 'Planned',
    'ONGOING': 'Ongoing',
    'COMPLETED': 'Completed',
    'CANCELLED': 'Cancelled',
  };
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({required this.state, required this.onLoadMore});

  final PagedState<ProjectModel> state;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (state.loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final loadMoreError = state.loadMoreError;
    if (loadMoreError != null) {
      return Column(
        children: <Widget>[
          Text(userMessage(loadMoreError), textAlign: TextAlign.center),
          TextButton(onPressed: onLoadMore, child: const Text('Retry')),
        ],
      );
    }
    if (state.hasMore) {
      return TextButton(onPressed: onLoadMore, child: const Text('Load more'));
    }
    return const SizedBox.shrink();
  }
}

class _ProjectsErrorView extends StatelessWidget {
  const _ProjectsErrorView({
    required this.message,
    required this.onPressed,
    this.detail,
    this.buttonLabel = 'Retry',
  });

  final String message;
  final String? detail;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final detailText = detail;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.task_alt_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (detailText != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(detailText, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 20),
                AppButton(label: buttonLabel, onPressed: onPressed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
