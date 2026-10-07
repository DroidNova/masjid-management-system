import 'package:flutter/material.dart';

/// Picks a new status; pops the chosen value (or null on cancel).
class UserStatusDialog extends StatefulWidget {
  const UserStatusDialog({super.key, this.currentStatus});

  final String? currentStatus;

  @override
  State<UserStatusDialog> createState() => _UserStatusDialogState();
}

class _UserStatusDialogState extends State<UserStatusDialog> {
  static const _statuses = <String>['ACTIVE', 'INACTIVE', 'SUSPENDED'];

  late String _status = _statuses.contains(widget.currentStatus)
      ? widget.currentStatus!
      : 'ACTIVE';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update status'),
      content: DropdownButtonFormField<String>(
        initialValue: _status,
        items: _statuses
            .map(
              (status) => DropdownMenuItem(value: status, child: Text(status)),
            )
            .toList(),
        onChanged: (value) => setState(() => _status = value ?? _status),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_status),
          child: const Text('Update'),
        ),
      ],
    );
  }
}
