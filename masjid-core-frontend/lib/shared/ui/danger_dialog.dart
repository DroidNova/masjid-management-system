import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/app_icons.dart';
import 'package:masjid_core_frontend/shared/ui/app_sheet.dart';
import 'package:masjid_core_frontend/shared/ui/hold_to_confirm_button.dart';
import 'package:masjid_core_frontend/shared/ui/read_aloud_button.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';
import 'package:masjid_core_frontend/shared/ui/tone_icon.dart';

/// One consequence line in a [showDangerDialog].
@immutable
class DangerPoint {
  const DangerPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

/// Confirms something that cannot be undone: leaving the masjid, deleting,
/// deactivating a person (UI_REDESIGN_PLAN.md, section 4).
///
/// Cancel is the big default button. The dangerous button must be held for
/// two seconds. [onConfirm] runs inside the dialog: while it runs the dialog
/// cannot be closed; if it throws, the dialog shows the reason and nothing
/// else happens. Returns true only when [onConfirm] finished without error.
Future<bool> showDangerDialog(
  BuildContext context, {
  required String title,
  String? subject,
  List<DangerPoint> points = const <DangerPoint>[],
  required String confirmLabel,
  IconData confirmIcon = AppIcons.warning,
  required Future<void> Function() onConfirm,
}) async {
  final done = await showAppSheet<bool>(
    context,
    // Swipe-down and tap-outside are off so a busy request is never
    // abandoned; Cancel and the back button still close it when idle.
    dismissible: false,
    builder: (_) => _DangerContent(
      title: title,
      subject: subject,
      points: points,
      confirmLabel: confirmLabel,
      confirmIcon: confirmIcon,
      onConfirm: onConfirm,
    ),
  );
  return done ?? false;
}

class _DangerContent extends StatefulWidget {
  const _DangerContent({
    required this.title,
    required this.subject,
    required this.points,
    required this.confirmLabel,
    required this.confirmIcon,
    required this.onConfirm,
  });

  final String title;
  final String? subject;
  final List<DangerPoint> points;
  final String confirmLabel;
  final IconData confirmIcon;
  final Future<void> Function() onConfirm;

  @override
  State<_DangerContent> createState() => _DangerContentState();
}

class _DangerContentState extends State<_DangerContent> {
  bool _working = false;
  String? _error;

  Future<void> _confirm() async {
    setState(() => _working = true);
    try {
      await widget.onConfirm();
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _working = false;
          _error = errorText(AppLocalizations.of(context), error);
        });
      }
    }
  }

  String get _spokenText => <String?>[
    widget.title,
    widget.subject,
    ...widget.points.map((point) => point.text),
  ].whereType<String>().join('. ');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final subject = widget.subject;
    final error = _error;

    return PopScope(
      canPop: !_working,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Center(
            child: ToneIcon(
              icon: AppIcons.warning,
              tone: AppTones.danger,
              size: 80,
              circle: true,
            ),
          ),
          const SizedBox(height: AppSpace.l),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
          if (subject != null) ...<Widget>[
            const SizedBox(height: AppSpace.xs),
            Text(
              subject,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: AppTones.danger.color,
              ),
            ),
          ],
          if (widget.points.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpace.l),
            for (final point in widget.points)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ToneIcon(
                      icon: point.icon,
                      tone: AppTones.neutral,
                      size: 36,
                    ),
                    const SizedBox(width: AppSpace.m),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpace.xs),
                        child: Text(point.text, style: textTheme.bodyLarge),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          Align(child: ReadAloudButton(text: _spokenText)),
          const SizedBox(height: AppSpace.s),
          if (error != null) ...<Widget>[
            Container(
              padding: const EdgeInsets.all(AppSpace.m),
              decoration: BoxDecoration(
                color: AppTones.problem.container,
                borderRadius: BorderRadius.circular(AppRadius.s),
              ),
              child: Row(
                children: <Widget>[
                  Icon(AppIcons.problem, color: AppTones.problem.color),
                  const SizedBox(width: AppSpace.m),
                  Expanded(
                    child: Text(
                      error,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppTones.problem.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.l),
            FilledButton(
              autofocus: true,
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.ok),
            ),
          ] else if (_working) ...<Widget>[
            const SizedBox(height: AppSpace.s),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: AppSpace.m),
            Text(
              l10n.pleaseWait,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpace.l),
          ] else ...<Widget>[
            FilledButton(
              autofocus: true,
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            const SizedBox(height: AppSpace.l),
            HoldToConfirmButton(
              label: widget.confirmLabel,
              icon: widget.confirmIcon,
              onConfirmed: _confirm,
            ),
          ],
        ],
      ),
    );
  }
}
