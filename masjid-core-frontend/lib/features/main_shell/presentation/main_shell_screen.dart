import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/shared/widgets/logout_button.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key, required this.child});

  final Widget child;

  static const List<_MainTab> _tabs = <_MainTab>[
    _MainTab(
      label: 'Home',
      icon: Icons.home_outlined,
      path: '/main/home',
    ),
    _MainTab(
      label: 'Finance',
      icon: Icons.account_balance_wallet_outlined,
      path: '/main/finance',
    ),
    _MainTab(
      label: 'Projects',
      icon: Icons.task_alt_outlined,
      path: '/main/projects',
    ),
    _MainTab(
      label: 'Community',
      icon: Icons.groups_outlined,
      path: '/main/community',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndexForLocation(
      GoRouterState.of(context).uri.path,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Masjid Core'),
        actions: const <Widget>[LogoutButton()],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          if (index == selectedIndex) return;
          context.go(_tabs[index].path);
        },
        type: BottomNavigationBarType.fixed,
        items: _tabs
            .map(
              (tab) => BottomNavigationBarItem(
                icon: Icon(tab.icon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }

  int _selectedIndexForLocation(String location) {
    final index = _tabs.indexWhere((tab) => location.startsWith(tab.path));
    return index < 0 ? 0 : index;
  }
}

class _MainTab {
  const _MainTab({
    required this.label,
    required this.icon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final String path;
}
