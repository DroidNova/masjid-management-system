import 'package:flutter/material.dart';
import 'package:platform_core_frontend/shared/widgets/audit_info_button.dart';
import 'package:platform_core_frontend/features/finance/presentation/widgets/finance_labels.dart';
import 'package:platform_core_frontend/features/projects/data/models/project_model.dart';
import 'package:platform_core_frontend/features/projects/presentation/widgets/project_progress_bar.dart';
import 'package:platform_core_frontend/features/projects/presentation/widgets/project_status_chip.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.onTap});

  final ProjectModel project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ProjectStatusChip(status: project.status),
                  AuditInfoButton(auditInfo: project.auditInfo),
                ],
              ),
              if (project.description != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(project.description!),
              ],
              const SizedBox(height: 12),
              Text('Target: ${formatRupees(project.targetAmount)}'),
              Text('Collected: ${formatRupees(project.collectedAmount)}'),
              Text('Spent: ${formatRupees(project.spentAmount)}'),
              const SizedBox(height: 12),
              ProjectProgressBar(
                progressPercentage: project.progressPercentage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
