import 'package:flutter/material.dart';

const Map<String, String> projectStatusLabels = <String, String>{
  'PLANNED': 'Planned',
  'ONGOING': 'Ongoing',
  'COMPLETED': 'Completed',
  'CANCELLED': 'Cancelled',
};

String projectStatusLabel(String status) {
  return projectStatusLabels[status] ?? status.replaceAll('_', ' ');
}

class ProjectStatusChip extends StatelessWidget {
  const ProjectStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(projectStatusLabel(status)));
  }
}
