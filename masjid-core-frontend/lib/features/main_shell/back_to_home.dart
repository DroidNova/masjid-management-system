import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Android back on a tab other than Home goes to Home first; back on Home
/// leaves the app. Tabs are switched without building a back history, so
/// without this, back on News or Projects would close the app at once.
/// A page opened inside a tab (a project, a person) still closes first:
/// its own navigator handles that back press before this one.
class BackToHome extends StatelessWidget {
  const BackToHome({
    super.key,
    required this.navigationShell,
    required this.child,
    this.homeBranch = 0,
  });

  final StatefulNavigationShell navigationShell;
  final Widget child;

  /// The Home tab's branch in the StatefulShellRoute.
  final int homeBranch;

  @override
  Widget build(BuildContext context) {
    final atHome = navigationShell.currentIndex == homeBranch;
    return PopScope(
      canPop: atHome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(homeBranch);
      },
      child: child,
    );
  }
}
