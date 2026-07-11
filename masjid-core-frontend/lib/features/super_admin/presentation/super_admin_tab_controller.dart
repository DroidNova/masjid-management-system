import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class SuperAdminTabController extends InheritedWidget {
  const SuperAdminTabController({
    super.key,
    required this.selectedIndex,
    required this.onSelectTab,
    required super.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectTab;

  static SuperAdminTabController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SuperAdminTabController>();
  }

  @override
  bool updateShouldNotify(SuperAdminTabController oldWidget) {
    return selectedIndex != oldWidget.selectedIndex;
  }
}

const List<String> superAdminTabPaths = <String>[
  '/super-admin',
  '/super-admin/requests',
  '/super-admin/masjids',
  '/super-admin/users',
];

void selectSuperAdminTab(BuildContext context, int index) {
  final controller = SuperAdminTabController.maybeOf(context);
  if (controller != null) {
    controller.onSelectTab(index);
    return;
  }

  context.go(superAdminTabPaths[index]);
}
