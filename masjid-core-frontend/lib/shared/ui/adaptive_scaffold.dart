import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/ui/responsive.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// One tab of the main navigation.
@immutable
class AppDestination {
  const AppDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;

  /// One word (rule 2).
  final String label;
}

/// The app's frame: a bottom bar on phones, a side rail on tablets, and a
/// wide side menu on desktop (UI_REDESIGN_PLAN.md, section 5). The last
/// destination (Profile) sits at the bottom of the rail and the menu.
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.body,
    this.title,
    this.actions,
    this.header,
    this.floatingActionButton,
  });

  final List<AppDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Widget body;
  final Widget? title;
  final List<Widget>? actions;

  /// Shown at the top of the side menu on desktop (masjid name and icon).
  final Widget? header;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final size = ScreenSize.of(context);
    final appBar = title == null
        ? null
        : AppBar(title: title, actions: actions);

    if (size == ScreenSize.compact) {
      return Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelected,
          destinations: destinations
              .map(
                (destination) => NavigationDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(
                    destination.selectedIcon ?? destination.icon,
                  ),
                  label: destination.label,
                ),
              )
              .toList(),
        ),
      );
    }

    final extended = size == ScreenSize.expanded;
    final pinned = destinations.last;
    final main = destinations.sublist(0, destinations.length - 1);
    final pinnedIndex = destinations.length - 1;
    final pinnedSelected = selectedIndex == pinnedIndex;

    final rtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      body: Row(
        children: <Widget>[
          // The rail sits on the start side: right in Urdu.
          SafeArea(
            left: !rtl,
            right: rtl,
            child: NavigationRail(
              extended: extended,
              minExtendedWidth: 264,
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              leading: extended ? header : null,
              selectedIndex: pinnedSelected ? null : selectedIndex,
              onDestinationSelected: onSelected,
              destinations: main
                  .map(
                    (destination) => NavigationRailDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(
                        destination.selectedIcon ?? destination.icon,
                      ),
                      label: Text(destination.label),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpace.xs,
                      ),
                    ),
                  )
                  .toList(),
              trailingAtBottom: true,
              trailing: Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.l),
                child: _PinnedRailItem(
                  destination: pinned,
                  selected: pinnedSelected,
                  extended: extended,
                  onTap: () => onSelected(pinnedIndex),
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Scaffold(
              appBar: appBar,
              body: body,
              floatingActionButton: floatingActionButton,
            ),
          ),
        ],
      ),
    );
  }
}

/// The bottom-pinned rail entry (Profile). Drawn by hand because a rail's
/// own destinations cannot be split between top and bottom.
class _PinnedRailItem extends StatelessWidget {
  const _PinnedRailItem({
    required this.destination,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  final AppDestination destination;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).navigationRailTheme;
    final color = selected ? AppTones.brand.color : AppColors.textSecondary;
    final icon = Icon(
      selected
          ? destination.selectedIcon ?? destination.icon
          : destination.icon,
      color: color,
      size: 28,
    );
    final label = Text(
      destination.label,
      style:
          (selected
                  ? theme.selectedLabelTextStyle
                  : theme.unselectedLabelTextStyle)
              ?.copyWith(color: color),
    );
    final indicator = selected ? AppTones.brand.container : Colors.transparent;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.l),
        child: extended
            ? Container(
                width: 232,
                height: AppSizes.minTouch,
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.l),
                decoration: BoxDecoration(
                  color: indicator,
                  borderRadius: BorderRadius.circular(AppRadius.l),
                ),
                child: Row(
                  children: <Widget>[
                    icon,
                    const SizedBox(width: AppSpace.m),
                    label,
                  ],
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 56,
                    height: 32,
                    decoration: BoxDecoration(
                      color: indicator,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: icon,
                  ),
                  const SizedBox(height: AppSpace.xs),
                  label,
                ],
              ),
      ),
    );
  }
}
