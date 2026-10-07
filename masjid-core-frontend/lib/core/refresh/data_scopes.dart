import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Areas of data that can change. A screen's controller watches the scopes it
/// shows; code that changes data marks the scopes it affected, and every
/// watching controller reloads. No feature needs to import another one.
enum DataScope {
  dashboard,
  masjid,
  namazTimes,
  announcements,
  members,
  finance,
  projects,
  contributions,
  imamSalary,
  admin,
}

/// Version counter per scope. Watch it in a controller's `build`:
///   ref.watch(dataVersionProvider(DataScope.finance));
final dataVersionProvider = StateProvider.family<int, DataScope>(
  (ref, scope) => 0,
);

/// Common groups, so callers don't forget a dependent screen.
class DataChanges {
  const DataChanges._();

  /// Any money in or out also changes the dashboard's finance card.
  static const List<DataScope> money = <DataScope>[
    DataScope.finance,
    DataScope.dashboard,
    DataScope.contributions,
  ];
}

void _bump(
  StateController<int> Function(DataScope) controllerFor,
  Iterable<DataScope> scopes,
) {
  // Read every notifier before changing any: bumping a scope the caller
  // watches rebuilds the caller and makes its `ref` unusable afterwards.
  final controllers = scopes.toSet().map(controllerFor).toList();
  for (final controller in controllers) {
    controller.state++;
  }
}

extension MarkChangedRef on Ref {
  /// Tell watching screens to reload, e.g. `ref.markChanged(DataChanges.money)`.
  void markChanged(Iterable<DataScope> scopes) =>
      _bump((scope) => read(dataVersionProvider(scope).notifier), scopes);
}

extension MarkChangedWidgetRef on WidgetRef {
  void markChanged(Iterable<DataScope> scopes) =>
      _bump((scope) => read(dataVersionProvider(scope).notifier), scopes);
}
