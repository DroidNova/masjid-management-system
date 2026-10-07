import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/network/api_exception.dart';

/// Runs an admin change and shows its error, if any.
///
/// USER_IN_ANOTHER_MASJID gets a dialog with the server's message (it names
/// the person and what to do); other errors a snackbar.
Future<void> runAdminAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (error) {
    if (!context.mounted) return;
    if (error is ApiException &&
        error.code == ApiErrorCodes.userInAnotherMasjid) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Cannot approve'),
          content: Text(userMessage(error)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(userMessage(error))));
  }
}
