import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/shared/widgets/account_menu_button.dart';
import 'package:masjid_core_frontend/shared/widgets/logout_button.dart';

/// Bottom-tab shell for masjid users. Each tab is a branch of a
/// StatefulShellRoute, so it keeps its scroll position and loaded data.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<_MainTab> _tabs = <_MainTab>[
    _MainTab(label: 'Home', icon: Icons.home_outlined),
    _MainTab(label: 'Finance', icon: Icons.account_balance_wallet_outlined),
    _MainTab(label: 'Projects', icon: Icons.task_alt_outlined),
    _MainTab(label: 'Community', icon: Icons.groups_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masjid Core'),
        actions: const <Widget>[AccountMenuButton(), LogoutButton()],
      ),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        // Tapping the current tab again returns it to its first page.
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
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
}

class _MainTab {
  const _MainTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
