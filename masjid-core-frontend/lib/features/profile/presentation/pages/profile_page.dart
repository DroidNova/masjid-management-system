import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/auth/presentation/auth_scope.dart';
import 'package:platform_core_frontend/shared/widgets/protected_app_shell.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).state.user;

    return ProtectedAppShell(
      title: 'Profile',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account Information', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('Name: ${user?.displayName ?? '-'}'),
            const SizedBox(height: 8),
            Text('Email: ${user?.email ?? '-'}'),
            const SizedBox(height: 8),
            Text('Roles: ${user?.roles.join(', ') ?? '-'}'),
            const SizedBox(height: 8),
            Text('Permissions: ${user?.permissions.join(', ') ?? '-'}'),
          ],
        ),
      ),
    );
  }
}
