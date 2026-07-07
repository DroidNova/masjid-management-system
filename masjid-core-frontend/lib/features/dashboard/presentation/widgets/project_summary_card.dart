import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/project_summary.dart';
import 'package:platform_core_frontend/features/dashboard/presentation/widgets/dashboard_format.dart';

class ProjectSummaryCard extends StatelessWidget {
  const ProjectSummaryCard({super.key, required this.projectsSummary});

  final ProjectsSummary? projectsSummary;

  @override
  Widget build(BuildContext context) {
    final projects = projectsSummary?.latestProjects ?? <ProjectPreview>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Projects',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text('Active projects: ${projectsSummary?.activeProjectsCount ?? 0}'),
            const SizedBox(height: 12),
            if (projects.isEmpty)
              const Text('No active projects yet.')
            else
              ...projects.map((project) => _ProjectTile(project: project)),
          ],
        ),
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.project});

  final ProjectPreview project;

  @override
  Widget build(BuildContext context) {
    final progress =
        (project.progressPercentage / 100).clamp(0.0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            project.title ?? 'Project',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 6),
          Text(
            '${formatRupees(project.collectedAmount)} / '
            '${formatRupees(project.targetAmount)} '
            '(${project.progressPercentage.round()}%)',
          ),
          if (project.status != null) Text('Status: ${project.status}'),
        ],
      ),
    );
  }
}
