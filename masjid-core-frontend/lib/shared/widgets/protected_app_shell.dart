import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/routing/app_router.dart';
import 'package:platform_core_frontend/features/auth/presentation/auth_scope.dart';

class ProtectedAppShell extends StatelessWidget {
  const ProtectedAppShell({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  Future<void> _logout(BuildContext context) async {
    final controller = AuthScope.of(context);
    await controller.logout();
    if (!context.mounted) {
      return;
    }

    context.go(AppRoutes.login);
  }

  void _navigateToTopLevelRoute(BuildContext context, String routeName) {
    context.go(routeName);
  }

  @override
  Widget build(BuildContext context) {
    final controller = AuthScope.of(context);
    final user = controller.state.user;
    final sessionLabel = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : user?.email ?? 'Authenticated user';
    final canAccessAdmin = controller.canAccessAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => _navigateToTopLevelRoute(context, AppRoutes.home),
            child: const Text('Home'),
          ),
          TextButton(
            onPressed: () => _navigateToTopLevelRoute(context, AppRoutes.profile),
            child: const Text('Profile'),
          ),
          if (canAccessAdmin)
            TextButton(
              onPressed: () =>
                  _navigateToTopLevelRoute(context, AppRoutes.adminUsers),
              child: const Text('Admin'),
            ),
          if (actions != null) ...actions!,
          PopupMenuButton<String>(
            tooltip: 'Session options',
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text(
                  sessionLabel,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: child),
    );
  }
}
