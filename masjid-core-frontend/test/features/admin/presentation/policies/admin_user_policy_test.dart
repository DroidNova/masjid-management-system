import 'package:flutter_test/flutter_test.dart';
import 'package:platform_core_frontend/features/admin/domain/entities/admin_user_detail.dart';
import 'package:platform_core_frontend/features/admin/presentation/policies/admin_user_policy.dart';
import 'package:platform_core_frontend/features/auth/domain/entities/current_user.dart';

void main() {
  CurrentUser actor({
    required List<String> roles,
    required List<String> permissions,
  }) {
    return CurrentUser(
      id: 'actor-1',
      email: 'actor@example.com',
      roles: roles,
      permissions: permissions,
    );
  }

  AdminUserDetail target({required List<String> roles}) {
    return AdminUserDetail(
      id: 'target-1',
      email: 'target@example.com',
      status: 'ACTIVE',
      roles: roles,
      permissions: const <String>[],
    );
  }

  group('AdminUserPolicy', () {
    test('ADMIN cannot edit roles and can edit USER status only', () {
      final adminActor = actor(
        roles: const ['ADMIN'],
        permissions: const ['users.update', 'roles.assign'],
      );

      expect(
        AdminUserPolicy.canEditRoles(adminActor, target(roles: const ['USER'])),
        isFalse,
      );
      expect(
        AdminUserPolicy.canEditStatus(adminActor, target(roles: const ['USER'])),
        isTrue,
      );
      expect(
        AdminUserPolicy.canEditStatus(adminActor, target(roles: const ['ADMIN'])),
        isFalse,
      );
      expect(
        AdminUserPolicy.readOnlyReason(adminActor, target(roles: const ['ADMIN'])),
        'Only SUPER_ADMIN can modify ADMIN accounts.',
      );
    });

    test('SUPER_ADMIN can edit ADMIN and USER but not SUPER_ADMIN target', () {
      final superAdminActor = actor(
        roles: const ['SUPER_ADMIN'],
        permissions: const ['users.update', 'roles.assign'],
      );

      expect(
        AdminUserPolicy.canEditRoles(superAdminActor, target(roles: const ['USER'])),
        isTrue,
      );
      expect(
        AdminUserPolicy.canEditStatus(superAdminActor, target(roles: const ['ADMIN'])),
        isTrue,
      );
      expect(
        AdminUserPolicy.availableAssignableRoles(
          superAdminActor,
          target(roles: const ['USER']),
        ),
        const ['ADMIN', 'USER'],
      );
      expect(
        AdminUserPolicy.canEditRoles(
          superAdminActor,
          target(roles: const ['SUPER_ADMIN']),
        ),
        isFalse,
      );
      expect(
        AdminUserPolicy.canEditStatus(
          superAdminActor,
          target(roles: const ['SUPER_ADMIN']),
        ),
        isFalse,
      );
    });
  });
}
