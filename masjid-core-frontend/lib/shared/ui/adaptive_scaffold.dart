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
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      body: Row(
        children: <Widget>[
          // The rail sits on the start side: right in Urdu.
          SafeArea(
            left: !rtl,
            right: rtl,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // A phone on its side is too short for every entry plus
                // the pinned Profile: then all entries scroll together,
                // with dots showing there is more.
                final needed =
                    destinations.length * _railEntryHeight +
                    (extended && header != null ? 120 : 0);
                if (constraints.maxHeight >= needed) {
                  return _pinnedRail(extended);
                }
                return _ScrollableRail(
                  destinations: destinations,
                  selectedIndex: selectedIndex,
                  onSelected: onSelected,
                  extended: extended,
                  header: header,
                );
              },
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            // Keep the page clear of the system buttons, which sit on the
            // end side when the phone is turned.
            child: SafeArea(
              top: false,
              bottom: false,
              left: rtl,
              right: !rtl,
              child: Scaffold(
                appBar: appBar,
                body: body,
                floatingActionButton: floatingActionButton,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Height one rail entry needs (icon, label, spacing).
  static const double _railEntryHeight = 80;

  /// The usual rail: entries at the top, Profile pinned at the bottom.
  Widget _pinnedRail(bool extended) {
    final pinned = destinations.last;
    final main = destinations.sublist(0, destinations.length - 1);
    final pinnedIndex = destinations.length - 1;
    final pinnedSelected = selectedIndex == pinnedIndex;
    return NavigationRail(
      extended: extended,
      minExtendedWidth: 264,
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      leading: extended ? header : null,
      selectedIndex: pinnedSelected ? null : selectedIndex,
      onDestinationSelected: onSelected,
      destinations: main.map(_railDestination).toList(),
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
    );
  }
}

NavigationRailDestination _railDestination(AppDestination destination) =>
    NavigationRailDestination(
      icon: Icon(destination.icon),
      selectedIcon: Icon(destination.selectedIcon ?? destination.icon),
      label: Text(destination.label),
      padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
    );

/// The rail when the window is too short for it (a phone on its side):
/// every entry, Profile included, in one scrolling list. Faded dots at the
/// top or bottom show that more entries are hidden that way.
class _ScrollableRail extends StatefulWidget {
  const _ScrollableRail({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.extended,
    this.header,
  });

  final List<AppDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool extended;
  final Widget? header;

  @override
  State<_ScrollableRail> createState() => _ScrollableRailState();
}

class _ScrollableRailState extends State<_ScrollableRail> {
  bool _moreAbove = false;
  bool _moreBelow = true;

  bool _onMetrics(ScrollMetrics metrics) {
    final above = metrics.pixels > metrics.minScrollExtent + 1;
    final below = metrics.pixels < metrics.maxScrollExtent - 1;
    if (above != _moreAbove || below != _moreBelow) {
      setState(() {
        _moreAbove = above;
        _moreBelow = below;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (notification) => _onMetrics(notification.metrics),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) => _onMetrics(notification.metrics),
        child: Stack(
          children: <Widget>[
            NavigationRail(
              scrollable: true,
              extended: widget.extended,
              minExtendedWidth: 264,
              labelType: widget.extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              leading: widget.extended ? widget.header : null,
              selectedIndex: widget.selectedIndex,
              onDestinationSelected: widget.onSelected,
              destinations: widget.destinations.map(_railDestination).toList(),
            ),
            if (_moreAbove)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _MoreHint(atTop: true),
              ),
            if (_moreBelow)
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _MoreHint(atTop: false),
              ),
          ],
        ),
      ),
    );
  }
}

/// A fade into the rail's colour with three dots: more entries this way.
class _MoreHint extends StatelessWidget {
  const _MoreHint({required this.atTop});

  final bool atTop;

  @override
  Widget build(BuildContext context) {
    final background =
        Theme.of(context).navigationRailTheme.backgroundColor ??
        Theme.of(context).colorScheme.surface;
    return IgnorePointer(
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: atTop ? Alignment.bottomCenter : Alignment.topCenter,
            end: atTop ? Alignment.topCenter : Alignment.bottomCenter,
            colors: <Color>[background.withValues(alpha: 0), background],
          ),
        ),
        alignment: atTop ? Alignment.topCenter : Alignment.bottomCenter,
        child: const Icon(
          Icons.more_horiz_rounded,
          color: AppColors.textSecondary,
        ),
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
