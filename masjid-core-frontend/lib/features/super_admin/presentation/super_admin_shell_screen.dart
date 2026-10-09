import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/features/main_shell/presentation/main_shell_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// The super admin's frame: Dashboard, Requests, Masjids, Users, and
/// Profile (bottom bar, rail, or side menu by width). Each tab is a branch
/// of a StatefulShellRoute (see app/router.dart), so tabs keep their state.
class SuperAdminShellScreen extends StatelessWidget {
  const SuperAdminShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = <String>[
      l10n.tabDashboard,
      l10n.tabRequests,
      l10n.tabMasjids,
      l10n.tabUsers,
      l10n.tabProfile,
    ];
    final index = navigationShell.currentIndex;

    return AdaptiveScaffold(
      destinations: <AppDestination>[
        AppDestination(icon: Icons.dashboard_rounded, label: labels[0]),
        AppDestination(icon: Icons.pending_actions_rounded, label: labels[1]),
        AppDestination(icon: AppIcons.mosque, label: labels[2]),
        AppDestination(icon: AppIcons.people, label: labels[3]),
        AppDestination(icon: AppIcons.profile, label: labels[4]),
      ],
      selectedIndex: index,
      onSelected: (tab) =>
          navigationShell.goBranch(tab, initialLocation: tab == index),
      title: Text(index == 0 ? l10n.superAdmin : labels[index]),
      header: MasjidHeader(
        name: l10n.superAdmin,
        icon: Icons.admin_panel_settings_rounded,
      ),
      body: navigationShell,
    );
  }
}
