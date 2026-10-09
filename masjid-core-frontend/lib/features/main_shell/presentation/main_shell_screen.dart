import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/dashboard/application/dashboard_controller.dart';
import 'package:masjid_core_frontend/features/main_shell/main_tabs.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// The masjid app's frame: the person's own tabs (bottom bar on phones,
/// rail on tablets, side menu on desktop) around the current page. Each tab
/// is a branch of a StatefulShellRoute, so it keeps its scroll position and
/// loaded data.
class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tabs = mainTabsFor(ref.watch(currentPermissionsProvider));
    final current = MainTab.values[navigationShell.currentIndex];
    // A page opened from a Home tile that is not one of this person's tabs
    // (for example Projects for a member) keeps Home highlighted.
    final selected = tabs.indexOf(current);
    final masjidName = ref.watch(
      dashboardControllerProvider.select(
        (dashboard) => dashboard.valueOrNull?.masjid?.name,
      ),
    );
    final name = (masjidName == null || masjidName.trim().isEmpty)
        ? l10n.appTitle
        : masjidName.trim();

    return AdaptiveScaffold(
      destinations: tabs
          .map((tab) => AppDestination(icon: tab.icon, label: tab.label(l10n)))
          .toList(),
      selectedIndex: selected < 0 ? 0 : selected,
      onSelected: (index) {
        final branch = tabs[index].branch;
        navigationShell.goBranch(
          branch,
          // Tapping the open tab again returns it to its first page.
          initialLocation: branch == navigationShell.currentIndex,
        );
      },
      title: current.hasOwnAppBar
          ? null
          : Text(current == MainTab.home ? name : current.label(l10n)),
      header: MasjidHeader(name: name),
      body: navigationShell,
    );
  }
}

/// The masjid's picture and name at the top of the desktop side menu.
class MasjidHeader extends StatelessWidget {
  const MasjidHeader({super.key, required this.name, this.icon});

  final String name;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 232,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.s,
          AppSpace.l,
          AppSpace.s,
          AppSpace.xl,
        ),
        child: Row(
          children: <Widget>[
            ToneIcon(icon: icon ?? AppIcons.mosque, tone: AppTones.brand),
            const SizedBox(width: AppSpace.m),
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
