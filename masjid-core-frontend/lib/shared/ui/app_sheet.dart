import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/responsive.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';
import 'package:masjid_core_frontend/shared/ui/tone_icon.dart';

/// Shows [builder]'s content as a bottom sheet on phones and as a centred
/// dialog on tablets and the website (UI_REDESIGN_PLAN.md, section 5).
/// The content should be a [Column] with `mainAxisSize: MainAxisSize.min`.
///
/// [dismissible] false stops swipe-down and tap-outside closing; use
/// [PopScope] inside the content to block the back button while busy.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  if (ScreenSize.of(context) == ScreenSize.compact) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: dismissible,
      enableDrag: dismissible,
      builder: (sheetContext) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpace.xl,
          0,
          AppSpace.xl,
          AppSpace.xl + MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: builder(sheetContext),
      ),
    );
  }
  return showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    builder: (dialogContext) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpace.xl),
          child: builder(dialogContext),
        ),
      ),
    ),
  );
}

/// Asks a yes/no question that is not dangerous (log out, discard a draft).
/// iOS gets the native-looking alert; elsewhere a sheet or dialog with an
/// icon. Returns true only when the person confirms.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required IconData icon,
  required String title,
  String? message,
  required String confirmLabel,
  AppTone tone = AppTones.brand,
}) async {
  final l10n = AppLocalizations.of(context);

  if (useCupertino(context)) {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: tone == AppTones.danger,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  if (!context.mounted) return false;
  final confirmed = await showAppSheet<bool>(
    context,
    builder: (sheetContext) {
      final textTheme = Theme.of(sheetContext).textTheme;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ToneIcon(icon: icon, tone: tone, size: 72, circle: true),
          const SizedBox(height: AppSpace.l),
          Text(title, textAlign: TextAlign.center, style: textTheme.titleLarge),
          if (message != null) ...<Widget>[
            const SizedBox(height: AppSpace.s),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpace.xl),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: AppSpace.m),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: tone.color),
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
