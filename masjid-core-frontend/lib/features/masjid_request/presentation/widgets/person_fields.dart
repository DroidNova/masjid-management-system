import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Digits-only age field (1 to 120 is checked by [validator]).
class AgeField extends StatelessWidget {
  const AgeField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: validator,
    );
  }
}

/// MALE / FEMALE / OTHER picker.
class GenderField extends StatelessWidget {
  const GenderField({
    super.key,
    required this.value,
    required this.label,
    required this.requiredMessage,
    required this.onChanged,
  });

  final String? value;
  final String label;
  final String requiredMessage;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
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
