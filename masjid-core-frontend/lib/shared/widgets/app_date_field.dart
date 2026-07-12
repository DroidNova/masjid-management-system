import 'package:flutter/material.dart';
import 'package:platform_core_frontend/shared/utils/date_format_utils.dart';

class AppDateField extends FormField<DateTime?> {
  AppDateField({
    super.key,
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime?> onDateSelected,
    required DateTime firstDate,
    required DateTime lastDate,
    bool required = false,
    bool enabled = true,
    String? helperText,
    FormFieldValidator<DateTime?>? validator,
  }) : super(
          initialValue: selectedDate,
          validator: validator ??
              (required
                  ? (value) => value == null ? '$label is required' : null
                  : null),
          builder: (state) {
            Future<void> pickDate() async {
              if (!enabled) return;
              final picked = await showDatePicker(
                context: state.context,
                initialDate: state.value ?? DateTime.now(),
                firstDate: firstDate,
                lastDate: lastDate,
              );
              if (picked == null) return;
              state.didChange(picked);
              onDateSelected(picked);
            }

            return InputDecorator(
              decoration: InputDecoration(
                labelText: required ? '$label *' : label,
                helperText: helperText,
                errorText: state.errorText,
                enabled: enabled,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (!required && state.value != null && enabled)
                      IconButton(
                        tooltip: 'Clear date',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          state.didChange(null);
                          onDateSelected(null);
                        },
                      ),
                    const Icon(Icons.calendar_today_outlined),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              child: InkWell(
                onTap: pickDate,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    state.value == null
                        ? (required ? 'Select date' : 'Not set')
                        : formatReadableDate(state.value),
                  ),
                ),
              ),
            );
          },
        );
}
