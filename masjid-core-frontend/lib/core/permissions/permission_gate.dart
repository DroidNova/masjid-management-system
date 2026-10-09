import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Shows [child] only if the signed-in user's permissions pass [isAllowed].
///
/// Use it for whole screens (routes) and for buttons:
///
///   PermissionGate(
///     isAllowed: PermissionHelper.canManageFinance,
///     fallback: const SizedBox.shrink(),
///     child: AddButton(...),
///   )
///
/// Permissions come from the server at login (see AppPermissions).
class PermissionGate extends ConsumerWidget {
  const PermissionGate({
    super.key,
    required this.isAllowed,
    required this.child,
    this.fallback,
  });

  final bool Function(List<String> permissions) isAllowed;
  final Widget child;

  /// Shown when not allowed. Defaults to a full-screen "not allowed" page.
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(currentPermissionsProvider);
    if (isAllowed(permissions)) return child;
    return fallback ?? Scaffold(appBar: AppBar(), body: const NotAllowedView());
  }
}
