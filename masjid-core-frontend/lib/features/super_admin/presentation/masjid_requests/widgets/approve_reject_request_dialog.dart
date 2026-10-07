import 'package:flutter/material.dart';

Future<String?> showRejectReasonDialog(BuildContext context) =>
    showReasonDialog(context, title: 'Reject request', confirmLabel: 'Reject');

/// Asks for a reason. Returns the trimmed text, or null when cancelled.
/// With [required], the confirm button stays off until something is typed.
Future<String?> showReasonDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  bool required = false,
}) {
  // Not disposed here: the dialog still uses it during its closing animation.
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: required ? 'Reason (required)' : 'Reason',
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, _) => FilledButton(
            onPressed: required && value.text.trim().isEmpty
                ? null
                : () => Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(confirmLabel),
          ),
        ),
      ],
    ),
  );
}

/// True when the admin confirms approving [masjidName].
Future<bool> showApproveRequestDialog(
  BuildContext context,
  String masjidName,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Approve request'),
      content: Text(
        'Approve $masjidName? This creates the masjid and its users.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Approve'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
