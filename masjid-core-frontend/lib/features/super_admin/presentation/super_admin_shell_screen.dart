import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/features/auth/data/auth_repository.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/masjid_requests/admin_masjid_requests_screen.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/masjids/admin_masjids_screen.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/super_admin_dashboard_screen.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/users/admin_users_screen.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/super_admin_tab_controller.dart';

class SuperAdminShellScreen extends StatefulWidget {
  const SuperAdminShellScreen({
    super.key,
    this.initialIndex = 0,
    this.authRepository,
  });

  final int initialIndex;
  final AuthRepository? authRepository;

  @override
  State<SuperAdminShellScreen> createState() => _SuperAdminShellScreenState();
}

class _SuperAdminShellScreenState extends State<SuperAdminShellScreen> {
  late int _selectedIndex = widget.initialIndex;
  late final AuthRepository _authRepository =
      widget.authRepository ?? AuthRepository();
  late final List<Widget?> _pages =
      List<Widget?>.filled(superAdminTabPaths.length, null);

  @override
  void didUpdateWidget(covariant SuperAdminShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex &&
        _selectedIndex != widget.initialIndex) {
      _selectedIndex = widget.initialIndex;
    }
  }

  void _selectTab(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  Widget _pageForIndex(int index) {
    final cachedPage = _pages[index];
    if (cachedPage != null) return cachedPage;

    final page = switch (index) {
      0 => const SuperAdminDashboardScreen(),
      1 => const AdminMasjidRequestsScreen(),
      2 => const AdminMasjidsScreen(),
      3 => const AdminUsersScreen(),
      _ => const SuperAdminDashboardScreen(),
    };
    _pages[index] = page;
    return page;
  }

  @override
  Widget build(BuildContext context) {
    return SuperAdminTabController(
      selectedIndex: _selectedIndex,
      onSelectTab: _selectTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Super Admin'),
          actions: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Chip(label: Text('SUPER_ADMIN')),
            ),
            IconButton(
              onPressed: () async {
                await _authRepository.logout();
                if (context.mounted) context.go('/auth');
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: List<Widget>.generate(superAdminTabPaths.length, (index) {
            final page = _pages[index];
            if (page != null || index == _selectedIndex) {
              return _pageForIndex(index);
            }
            return const SizedBox.shrink();
          }),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectTab,
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
      ),
    );
  }
}
