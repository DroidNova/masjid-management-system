import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/ui/status_badge.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// A message inside the page, next to what it is about: red with an icon
/// for problems, amber for warnings, green for good news. Stays until the
/// cause is fixed, unlike a snack bar that disappears before it is read.
/// Screen readers announce it when it appears.
class MessageBanner extends StatelessWidget {
  const MessageBanner({
    super.key,
    required this.text,
    this.kind = StatusKind.problem,
    this.action,
  });

  final String text;
  final StatusKind kind;

  /// Optional button under the text (for example "Send new code").
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tone = kind.tone;
    final button = action;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.m),
        decoration: BoxDecoration(
          color: tone.container,
          borderRadius: BorderRadius.circular(AppRadius.s),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(kind.icon, color: tone.color, size: 28),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: tone.color),
                  ),
                ),
              ],
            ),
            if (button != null) ...<Widget>[
              const SizedBox(height: AppSpace.s),
              Align(alignment: AlignmentDirectional.centerEnd, child: button),
            ],
          ],
        ),
      ),
    );
  }
}
