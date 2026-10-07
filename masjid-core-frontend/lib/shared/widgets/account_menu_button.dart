import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/community/application/leave_masjid_controller.dart';

/// App bar menu with account actions. Today: "Leave masjid", shown to users
/// with the `masjid.leave` permission who belong to a masjid.
///
/// One phone number can belong to one masjid at a time, so a person must
/// leave their current masjid before another masjid's committee can add them.
class AccountMenuButton extends ConsumerWidget {
  const AccountMenuButton({super.key});

  Future<void> _confirmLeave(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave masjid?'),
        content: const Text(
          'You will stop seeing this masjid and any imam or committee role '
          'you have here will end. Your payment history is kept. '
          'Another masjid can add you after you leave.\n\n'
          'You will be logged out.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave masjid'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(leaveMasjidControllerProvider.notifier);
    final auth = ref.read(authControllerProvider.notifier);
    final left = await controller.leave();
    if (!left) {
      final error = ref.read(leaveMasjidControllerProvider).error;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error == null ? 'Unable to leave the masjid.' : userMessage(error),
          ),
        ),
      );
      return;
    }
    messenger.showSnackBar(
      const SnackBar(content: Text('You have left the masjid.')),
    );
    // Signing out sends the user to the login page (router redirect).
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final canLeave =
        PermissionHelper.has(user, AppPermissions.masjidLeave) &&
        (user?.masjidId?.isNotEmpty ?? false);
    if (!canLeave) return const SizedBox.shrink();

    final busy = ref.watch(leaveMasjidControllerProvider).isLoading;
    if (busy) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return PopupMenuButton<String>(
      tooltip: 'Account',
      onSelected: (value) {
        if (value == 'leave') _confirmLeave(context, ref);
      },
      itemBuilder: (context) => const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'leave',
          child: ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Leave masjid'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
