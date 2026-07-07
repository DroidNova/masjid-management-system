import 'package:flutter/material.dart';
import 'package:platform_core_frontend/core/auth/current_user_role_helper.dart';

class AddUserRoleDropdown extends StatelessWidget {
  const AddUserRoleDropdown({
    super.key,
    required this.allowedRoles,
    required this.value,
    required this.onChanged,
  });

  final List<String> allowedRoles;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Role *',
        border: OutlineInputBorder(),
      ),
      items: allowedRoles
          .map(
            (role) => DropdownMenuItem<String>(
              value: role,
              child: Text(CurrentUserRoleHelper.roleLabel(role)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (selectedRole) {
        if (selectedRole == null || selectedRole.isEmpty) {
          return 'Please select a role.';
        }
        return null;
      },
    );
  }
}
