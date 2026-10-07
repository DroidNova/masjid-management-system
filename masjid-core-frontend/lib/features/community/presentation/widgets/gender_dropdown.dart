import 'package:flutter/material.dart';

/// MALE / FEMALE / OTHER picker, required.
class GenderDropdown extends StatelessWidget {
  const GenderDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.requiredMessage,
    this.outlined = true,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String requiredMessage;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: 'Gender *',
        border: outlined ? const OutlineInputBorder() : null,
      ),
      items: const <DropdownMenuItem<String>>[
        DropdownMenuItem(value: 'MALE', child: Text('Male')),
        DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
        DropdownMenuItem(value: 'OTHER', child: Text('Other')),
      ],
      onChanged: onChanged,
      validator: (value) => value == null ? requiredMessage : null,
    );
  }
}
