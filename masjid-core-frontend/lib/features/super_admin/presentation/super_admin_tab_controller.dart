import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Tab locations of the super admin shell, in branch order.
const List<String> superAdminTabPaths = <String>[
  '/super-admin',
  '/super-admin/requests',
  '/super-admin/masjids',
  '/super-admin/users',
];

/// Switches the super admin shell to tab [index] (keeps each tab's state).
void selectSuperAdminTab(BuildContext context, int index) {
  final shell = StatefulNavigationShell.maybeOf(context);
  if (shell != null) {
    shell.goBranch(index);
    return;
  }
  context.go(superAdminTabPaths[index]);
}
