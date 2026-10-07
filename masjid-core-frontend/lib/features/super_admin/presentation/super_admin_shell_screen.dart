import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';

/// Bottom-tab shell for the super admin. Each tab is a branch of a
/// StatefulShellRoute (see app/router.dart), so tabs keep their state.
class SuperAdminShellScreen extends ConsumerWidget {
  const SuperAdminShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin'),
        actions: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Chip(label: Text('SUPER_ADMIN')),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.pending_actions),
            label: 'Requests',
          ),
          NavigationDestination(icon: Icon(Icons.mosque), label: 'Masjids'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Users'),
        ],
      ),
    );
  }
}
