import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// Screen width classes (UI_REDESIGN_PLAN.md, section 5).
enum ScreenSize {
  /// Phones: under 600 dp. Bottom navigation bar, one column.
  compact,

  /// Tablets and small windows: 600–1024 dp. Navigation rail.
  medium,

  /// Desktop browsers: over 1024 dp. Wide side menu, list + detail panes.
  expanded;

  static ScreenSize fromWidth(double width) {
    if (width < 600) return compact;
    if (width < 1024) return medium;
    return expanded;
  }

  static ScreenSize of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  /// Columns for a grid of [ActionTile]s.
  int get tileColumns => switch (this) {
    compact => 2,
    medium => 3,
    expanded => 4,
  };
}

/// iOS (and macOS) get Cupertino-style pickers and alerts. On the website
/// this follows the visitor's device, so an iPhone browser gets them too.
bool useCupertino(BuildContext context) {
  final platform = Theme.of(context).platform;
  return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
}

/// Centres a page's content and stops it growing too wide on big screens.
class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.child,
    this.maxWidth = AppSizes.maxContentWidth,
    this.padding = const EdgeInsets.all(AppSpace.l),
  });

  /// A narrow page for forms.
  const PageBody.form({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.l),
  }) : maxWidth = AppSizes.maxFormWidth;

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
