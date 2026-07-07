import 'package:platform_core_frontend/core/auth/access_policy.dart';
import 'package:platform_core_frontend/features/admin/domain/entities/admin_user_detail.dart';
import 'package:platform_core_frontend/features/auth/domain/entities/current_user.dart';

class AdminUserPolicy {
  const AdminUserPolicy._();

  static bool canEditRoles(CurrentUser? actor, AdminUserDetail target) {
    if (!_hasRoleAssignmentPermission(actor) || !AccessPolicy.hasRole(actor, 'SUPER_ADMIN')) {
      return false;
    }
    if (_isSuperAdminTarget(target)) {
      return false;
    }
    if (_isAdminTarget(target) && !AccessPolicy.hasRole(actor, 'SUPER_ADMIN')) {
      return false;
    }
    return true;
  }

  static bool canEditStatus(CurrentUser? actor, AdminUserDetail target) {
    if (!_hasStatusUpdatePermission(actor) || !_isAdminActor(actor)) {
      return false;
    }
    if (_isSuperAdminTarget(target)) {
      return false;
    }
    if (_isAdminTarget(target) && !AccessPolicy.hasRole(actor, 'SUPER_ADMIN')) {
      return false;
    }
    return true;
  }

  static List<String> availableAssignableRoles(
    CurrentUser? actor,
    AdminUserDetail target,
  ) {
    if (!canEditRoles(actor, target)) {
      return const <String>[];
    }

    return const <String>['ADMIN', 'USER'];
  }

  static bool isReadOnlyTarget(CurrentUser? actor, AdminUserDetail target) {
    return !canEditRoles(actor, target) && !canEditStatus(actor, target);
  }

  static String? readOnlyReason(CurrentUser? actor, AdminUserDetail target) {
    if (_isSuperAdminTarget(target)) {
      return 'SUPER_ADMIN accounts are read-only in admin APIs.';
    }
    if (_isAdminTarget(target) && !AccessPolicy.hasRole(actor, 'SUPER_ADMIN')) {
      return 'Only SUPER_ADMIN can modify ADMIN accounts.';
    }
    if (!_hasStatusUpdatePermission(actor) && !_hasRoleAssignmentPermission(actor)) {
      return 'Your account is missing required admin permissions.';
    }
    if (!_isAdminActor(actor)) {
      return 'Your account role cannot manage this user.';
    }
    return null;
  }

  static bool _isAdminTarget(AdminUserDetail target) =>
      _hasRole(target.roles, 'ADMIN');

  static bool _isSuperAdminTarget(AdminUserDetail target) =>
      _hasRole(target.roles, 'SUPER_ADMIN');

  static bool _isAdminActor(CurrentUser? actor) =>
      AccessPolicy.hasRole(actor, 'ADMIN') || AccessPolicy.hasRole(actor, 'SUPER_ADMIN');

  static bool _hasStatusUpdatePermission(CurrentUser? actor) =>
      AccessPolicy.hasPermission(actor, 'users.update');

  static bool _hasRoleAssignmentPermission(CurrentUser? actor) =>
      AccessPolicy.hasPermission(actor, 'roles.assign');

  static bool _hasRole(List<String> roles, String required) {
    final normalized = required.toUpperCase();
    return roles.any((role) => role.toUpperCase() == normalized);
  }
}
