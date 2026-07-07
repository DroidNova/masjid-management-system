import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/namaz_time_summary.dart';
import 'package:platform_core_frontend/features/dashboard/presentation/widgets/dashboard_format.dart';

class NamazTimeCard extends StatelessWidget {
  const NamazTimeCard({super.key, required this.namazTime});

  final NamazTimeSummary? namazTime;

  @override
  Widget build(BuildContext context) {
    final times = namazTime;
    if (times == null) {
      return const _SectionCard(
        title: 'Namaz Timings',
        child: Text('Namaz timings are not added yet.'),
      );
    }

    return _SectionCard(
      title: 'Namaz Timings',
      child: Column(
        children: <Widget>[
          _TimeRow(label: 'Fajr', value: valueOrDash(times.fajr)),
          _TimeRow(label: 'Zuhr', value: valueOrDash(times.zuhr)),
          _TimeRow(label: 'Asr', value: valueOrDash(times.asr)),
          _TimeRow(label: 'Maghrib', value: valueOrDash(times.maghrib)),
          _TimeRow(label: 'Isha', value: valueOrDash(times.isha)),
          _TimeRow(
            label: 'Jumma',
            value: valueOrDash(times.jumma),
            highlighted: true,
          ),
          if (times.note != null) ...<Widget>[
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(times.note!),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? Theme.of(context).colorScheme.primary : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w700, color: color),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
