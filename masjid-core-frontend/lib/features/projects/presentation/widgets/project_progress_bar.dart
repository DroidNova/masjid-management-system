import 'package:flutter/material.dart';

class ProjectProgressBar extends StatelessWidget {
  const ProjectProgressBar({super.key, required this.progressPercentage});

  final double progressPercentage;

  @override
  Widget build(BuildContext context) {
    final progress = (progressPercentage / 100).clamp(0.0, 1.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 6),
        Text('Progress: ${progressPercentage.round()}%'),
      ],
    );
  }
}
