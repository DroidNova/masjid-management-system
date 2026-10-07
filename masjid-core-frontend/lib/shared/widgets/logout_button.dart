import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/auth/data/auth_repository.dart';

class LogoutButton extends ConsumerStatefulWidget {
  const LogoutButton({super.key, AuthRepository? authRepository});

  @override
  ConsumerState<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends ConsumerState<LogoutButton> {
  bool _isLoggingOut = false;

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    setState(() => _isLoggingOut = true);
    // The router sends the user to the login page.
    await ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Logout',
      onPressed: _isLoggingOut ? null : _confirmLogout,
      icon: _isLoggingOut
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.logout),
    );
  }
}
