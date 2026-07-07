import 'package:flutter/foundation.dart';

enum AppDataScope {
  dashboard,
  finance,
  projects,
  community,
  announcements,
  namazTime,
  imamSalary,
  adminDashboard,
  adminUsers,
  adminMasjidRequests,
  adminMasjids,
}

class AppDataRefreshBus {
  AppDataRefreshBus._();

  static final AppDataRefreshBus instance = AppDataRefreshBus._();

  final Map<AppDataScope, ValueNotifier<int>> _notifiers =
      <AppDataScope, ValueNotifier<int>>{
    for (final scope in AppDataScope.values) scope: ValueNotifier<int>(0),
  };

  ValueNotifier<int> notifierFor(AppDataScope scope) => _notifiers[scope]!;

  void notify(AppDataScope scope) {
    _notifiers[scope]!.value++;
  }

  void notifyMany(List<AppDataScope> scopes) {
    for (final scope in scopes) {
      notify(scope);
    }
  }
}
