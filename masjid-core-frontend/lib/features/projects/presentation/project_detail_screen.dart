import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/projects/application/project_detail_controller.dart';
import 'package:masjid_core_frontend/features/projects/application/project_editor_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/presentation/widgets/project_progress_bar.dart';
import 'package:masjid_core_frontend/features/projects/presentation/widgets/project_status_chip.dart';
import 'package:masjid_core_frontend/shared/widgets/app_button.dart';
import 'package:masjid_core_frontend/shared/widgets/loading_view.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    this.initialProject,
  });

  final String projectId;

  /// From the list (route `extra`): shown instantly while the project loads.
  final ProjectModel? initialProject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectDetailProvider(projectId));
    final preview = initialProject?.id == projectId ? initialProject : null;

    final Widget body;
    if (projectState.hasError && !projectState.isLoading) {
      body = _DetailError(
        message: userMessage(projectState.error!),
        onRetry: () => ref.invalidate(projectDetailProvider(projectId)),
      );
    } else {
      final project = projectState.valueOrNull ?? preview;
      body = project == null
          ? const LoadingView()
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(projectDetailProvider(projectId).notifier).refresh(),
              child: _ProjectDetailBody(project: project),
            );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Project Details')),
      body: body,
    );
  }
}

class _ProjectDetailBody extends ConsumerWidget {
  const _ProjectDetailBody({required this.project});

  final ProjectModel project;

  Future<void> _deleteProject(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !context.mounted) return;

    final ok = await ref
        .read(projectEditorControllerProvider.notifier)
        .deleteProject(project.id);
    if (!context.mounted) return;
    final error = ref.read(projectEditorControllerProvider).error;
    if (!ok && error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Project deleted successfully.' : userMessage(error!),
        ),
      ),
    );
    if (ok) context.pop(true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManageProjects = PermissionHelper.canManageProjects(
      ref.watch(currentPermissionsProvider),
    );
    final isDeleting = ref.watch(projectEditorControllerProvider).isLoading;
    final description = project.description;
    final startDate = project.startDate;
    final endDate = project.endDate;
    final createdAt = project.createdAt;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            project.title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ProjectStatusChip(status: project.status),
                      ],
                    ),
                    if (description != null) ...<Widget>[
                      const SizedBox(height: 12),
                      Text(description),
                    ],
                    const SizedBox(height: 16),
                    Text('Target: ${AppFormat.rupees(project.targetAmount)}'),
                    Text(
                      'Collected: ${AppFormat.rupees(project.collectedAmount)}',
                    ),
                    Text('Spent: ${AppFormat.rupees(project.spentAmount)}'),
                    const SizedBox(height: 16),
                    ProjectProgressBar(
                      progressPercentage: project.progressPercentage,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'View Contributions',
                      isOutlined: true,
                      onPressed: () => context.push(
                        '/projects/${project.id}/contributions',
                        extra: project.title,
                      ),
                    ),
                    const Divider(height: 28),
                    Text(
                      'Start Date: '
                      '${startDate == null ? 'Not set' : AppFormat.date(startDate)}',
                    ),
                    Text(
                      'End Date: '
                      '${endDate == null ? 'Not set' : AppFormat.date(endDate)}',
                    ),
                    Text(
                      'Created: '
                      '${createdAt == null ? '-' : AppFormat.dateTime(createdAt)}',
                    ),
                    if (canManageProjects) ...<Widget>[
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'Edit Project',
                        onPressed: () => context.push(
                          '/projects/${project.id}/edit',
                          extra: project,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Delete / Cancel Project',
                        isOutlined: true,
                        isLoading: isDeleting,
                        onPressed: () => _deleteProject(context, ref),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppButton(label: 'Retry', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
