import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/projects/application/project_detail_controller.dart';
import 'package:masjid_core_frontend/features/projects/application/project_editor_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/presentation/widgets/project_card.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// One project: a progress ring with collected / target, what is left and
/// spent, the description and dates, its givers, and (for managers) edit
/// and cancel. [initialProject] (from the list) shows at once; the project
/// is loaded by [projectId] either way, so the numbers are current.
class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    this.initialProject,
  });

  final String projectId;
  final ProjectModel? initialProject;

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    ProjectModel project,
  ) async {
    final l10n = AppLocalizations.of(context);
    final editor = ref.read(projectEditorControllerProvider.notifier);
    final cancelled = await showDangerDialog(
      context,
      title: l10n.cancelProjectQuestion,
      subject: project.title,
      confirmLabel: l10n.cancelProject,
      confirmIcon: Icons.block_rounded,
      points: <DangerPoint>[
        DangerPoint(icon: AppIcons.projects, text: l10n.cancelProjectPoint),
      ],
      onConfirm: () async {
        if (!await editor.deleteProject(project.id)) {
          throw ref.read(projectEditorControllerProvider).error ??
              StateError('cancel failed');
        }
      },
    );
    if (cancelled && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.projectCancelledDone)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Kept alive so a failed cancel's error can be read and shown.
    ref.listen(projectEditorControllerProvider, (_, _) {});
    final state = ref.watch(projectDetailProvider(projectId));
    final preview = initialProject?.id == projectId ? initialProject : null;
    final project = state.valueOrNull ?? preview;
    final permissions = ref.watch(currentPermissionsProvider);

    final Widget body;
    if (project != null) {
      body = _Details(
        project: project,
        canManage: PermissionHelper.canManageProjects(permissions),
        canRecord: PermissionHelper.canRecordContributions(permissions),
        onCancel: () => _cancel(context, ref, project),
        onRefresh: () =>
            ref.read(projectDetailProvider(projectId).notifier).refresh(),
      );
    } else if (state.hasError) {
      body = EmptyState(
        icon: AppIcons.problem,
        tone: AppTones.problem,
        title: errorText(l10n, state.error!),
        actionLabel: l10n.tryAgain,
        onAction: () => ref.invalidate(projectDetailProvider(projectId)),
      );
    } else {
      body = const SingleChildScrollView(
        child: PageBody.form(child: SkeletonList(itemCount: 3)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(project?.title ?? l10n.tabProjects)),
      body: SafeArea(top: false, child: body),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.project,
    required this.canManage,
    required this.canRecord,
    required this.onCancel,
    required this.onRefresh,
  });

  final ProjectModel project;
  final bool canManage;
  final bool canRecord;
  final VoidCallback onCancel;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final (_, statusIcon, statusLabel) = projectStatusLook(
      l10n,
      project.status,
    );
    final description = project.description?.trim() ?? '';
    final hasTarget = project.targetAmount > 0;
    final collected = AppFormat.rupees(project.collectedAmount);
    final white = textTheme.bodyLarge?.copyWith(color: Colors.white);
    final start = project.startDate;
    final end = project.endDate;
    final cancelled = project.status == 'CANCELLED';

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          PageBody.form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                HeroCard(
                  tone: AppTones.projects,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(statusIcon, size: 20),
                          const SizedBox(width: AppSpace.xs),
                          Expanded(child: Text(statusLabel, style: white)),
                          ReadAloudButton(
                            text: hasTarget
                                ? '${project.title}. ${l10n.collectedOf(collected, AppFormat.rupees(project.targetAmount))}'
                                : '${project.title}. ${l10n.collectedSoFar(collected)}',
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpace.s),
                      Row(
                        children: <Widget>[
                          if (hasTarget) ...<Widget>[
                            ProgressRing(
                              value: projectShare(project),
                              size: 96,
                            ),
                            const SizedBox(width: AppSpace.l),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(l10n.collected, style: white),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: AmountText(
                                    project.collectedAmount,
                                    size: AmountSize.large,
                                    color: Colors.white,
                                  ),
                                ),
                                if (hasTarget)
                                  Text(
                                    l10n.outOf(
                                      AppFormat.rupees(project.targetAmount),
                                    ),
                                    style: white,
                                  ),
                                if (hasTarget && project.remainingAmount > 0)
                                  Text(
                                    l10n.stillNeeded(
                                      AppFormat.rupees(project.remainingAmount),
                                    ),
                                    style: textTheme.titleSmall?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (project.spentAmount > 0) ...<Widget>[
                        const SizedBox(height: AppSpace.m),
                        Row(
                          children: <Widget>[
                            const Icon(AppIcons.moneyOut, size: 20),
                            const SizedBox(width: AppSpace.xs),
                            Expanded(
                              child: Text(
                                l10n.spent(
                                  AppFormat.rupees(project.spentAmount),
                                ),
                                style: white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (description.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpace.l),
                  Text(description, style: textTheme.bodyLarge),
                ],
                if (start != null || end != null) ...<Widget>[
                  const SizedBox(height: AppSpace.m),
                  Row(
                    children: <Widget>[
                      const Icon(
                        AppIcons.calendar,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpace.s),
                      Expanded(
                        child: Text(
                          <String>[
                            if (start != null) AppFormat.date(start),
                            if (end != null) AppFormat.date(end),
                          ].join('  →  '),
                          style: textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpace.xl),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTones.projects.color,
                  ),
                  onPressed: () => context.push(
                    '/projects/${project.id}/contributions',
                    extra: project.title,
                  ),
                  icon: const Icon(AppIcons.zakat),
                  label: Text(l10n.givers),
                ),
                if (canRecord && !cancelled) ...<Widget>[
                  const SizedBox(height: AppSpace.m),
                  OutlinedButton.icon(
                    onPressed: () => context.push(
                      Uri(
                        path: '/contributions/new',
                        queryParameters: <String, String>{
                          'project': project.id,
                        },
                      ).toString(),
                    ),
                    icon: const Icon(AppIcons.add),
                    label: Text(l10n.addGiver),
                  ),
                ],
                if (canManage) ...<Widget>[
                  const SizedBox(height: AppSpace.m),
                  OutlinedButton.icon(
                    onPressed: () => context.push(
                      '/projects/${project.id}/edit',
                      extra: project,
                    ),
                    icon: const Icon(AppIcons.edit),
                    label: Text(l10n.editProject),
                  ),
                  if (!cancelled) ...<Widget>[
                    const SizedBox(height: AppSpace.xxl),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTones.danger.color,
                        side: BorderSide(
                          color: AppTones.danger.color,
                          width: 2,
                        ),
                      ),
                      onPressed: onCancel,
                      icon: const Icon(Icons.block_rounded),
                      label: Text(l10n.cancelProject),
                    ),
                  ],
                ],
                const SizedBox(height: AppSpace.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
