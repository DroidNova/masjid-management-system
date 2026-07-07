import 'package:flutter/material.dart';

class RolesWrap extends StatelessWidget {
  const RolesWrap({
    super.key,
    required this.roles,
  });

  final List<String> roles;

  @override
  Widget build(BuildContext context) {
    if (roles.isEmpty) {
      return Text(
        '-',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: roles
          .map(
            (role) => Chip(
              label: Text(role),
              visualDensity: VisualDensity.compact,
            ),
          )
          .toList(),
    );
  }
}
