import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/format/formatters.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Project statuses as the server sends them, in the order people choose
/// them.
const List<String> projectStatuses = <String>[
  'PLANNED',
  'ONGOING',
  'COMPLETED',
  'CANCELLED',
];

/// The look of a project status: badge kind, picture, and name.
(StatusKind, IconData, String) projectStatusLook(
  AppLocalizations l10n,
  String status,
) => switch (status) {
  'PLANNED' => (
    StatusKind.neutral,
    Icons.event_note_rounded,
    l10n.projectPlanned,
  ),
  'COMPLETED' => (StatusKind.done, AppIcons.done, l10n.projectCompleted),
  'CANCELLED' => (
    StatusKind.problem,
    Icons.block_rounded,
    l10n.projectCancelled,
  ),
  _ => (StatusKind.waiting, AppIcons.projects, l10n.projectOngoing),
};

/// How far a project is: its own percent, or collected / target.
double projectShare(ProjectModel project) {
  if (project.progressPercentage > 0) return project.progressPercentage / 100;
  if (project.targetAmount <= 0) return 0;
  return project.collectedAmount / project.targetAmount;
}

/// A project in a list: picture, title, status, a thick progress bar, and
/// "₹X of ₹Y".
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.onTap});

  final ProjectModel project;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final (kind, _, label) = projectStatusLook(l10n, project.status);
    final share = projectShare(project);
    final hasTarget = project.targetAmount > 0;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const ToneIcon(
                    icon: AppIcons.projects,
                    tone: AppTones.projects,
                  ),
                  const SizedBox(width: AppSpace.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          project.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpace.xs),
                        StatusBadge(kind: kind, label: label),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.m),
              if (hasTarget) ...<Widget>[
                ProgressBar(value: share),
                const SizedBox(height: AppSpace.s),
              ],
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      hasTarget
                          ? l10n.collectedOf(
                              AppFormat.rupees(project.collectedAmount),
                              AppFormat.rupees(project.targetAmount),
                            )
                          : l10n.collectedSoFar(
                              AppFormat.rupees(project.collectedAmount),
                            ),
                      style: textTheme.bodyLarge,
                    ),
                  ),
                  if (hasTarget)
                    Text(
                      '${(share.clamp(0, 1) * 100).round()}%',
                      textDirection: TextDirection.ltr,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppTones.projects.color,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
