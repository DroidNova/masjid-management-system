import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/routing/app_router.dart';
import 'package:platform_core_frontend/features/auth/presentation/auth_scope.dart';
import 'package:platform_core_frontend/shared/widgets/protected_app_shell.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AuthScope.of(context);
    final user = authController.state.user;
    final canAccessAdmin = authController.canAccessAdmin;

    return ProtectedAppShell(
      title: 'Platform Home',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Welcome', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(user?.displayName ?? user?.email ?? 'Authenticated user'),
              const SizedBox(height: 6),
              if (user != null) Text('Email: ${user.email}'),
              const SizedBox(height: 6),
              Text('Roles: ${user?.roles.join(', ') ?? '-'}'),
              const SizedBox(height: 6),
              Text('Permissions: ${user?.permissions.join(', ') ?? '-'}'),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.profile),
                    child: const Text('Profile'),
                  ),
                  if (canAccessAdmin)
                    OutlinedButton(
                      onPressed: () => context.go(AppRoutes.adminUsers),
                      child: const Text('Admin Users'),
                    ),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings module placeholder (coming next).'),
                        ),
                      );
                    },
                    child: const Text('Settings (Placeholder)'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
