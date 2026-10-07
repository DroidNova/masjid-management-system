import 'package:flutter/material.dart';

class NamazTimeFormSection extends StatelessWidget {
  const NamazTimeFormSection({
    super.key,
    required this.fajrController,
    required this.zuhrController,
    required this.asrController,
    required this.maghribController,
    required this.ishaController,
    required this.jummaController,
    required this.noteController,
    this.fieldErrorFor,
  });

  final TextEditingController fajrController;
  final TextEditingController zuhrController;
  final TextEditingController asrController;
  final TextEditingController maghribController;
  final TextEditingController ishaController;
  final TextEditingController jummaController;
  final TextEditingController noteController;

  /// Server validation message for a field name (`fajr`, `note`, ...).
  final String? Function(String field)? fieldErrorFor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _NamazTimePickerField(
              controller: fajrController,
              label: 'Fajr',
              errorText: fieldErrorFor?.call('fajr'),
              fallbackTime: const TimeOfDay(hour: 5, minute: 0),
            ),
            const SizedBox(height: 14),
            _NamazTimePickerField(
              controller: zuhrController,
              label: 'Zuhr',
              errorText: fieldErrorFor?.call('zuhr'),
              fallbackTime: const TimeOfDay(hour: 13, minute: 30),
            ),
            const SizedBox(height: 14),
            _NamazTimePickerField(
              controller: asrController,
              label: 'Asr',
              errorText: fieldErrorFor?.call('asr'),
              fallbackTime: const TimeOfDay(hour: 17, minute: 0),
            ),
            const SizedBox(height: 14),
            _NamazTimePickerField(
              controller: maghribController,
              label: 'Maghrib',
              errorText: fieldErrorFor?.call('maghrib'),
              fallbackTime: const TimeOfDay(hour: 18, minute: 45),
            ),
            const SizedBox(height: 14),
            _NamazTimePickerField(
              controller: ishaController,
              label: 'Isha',
              errorText: fieldErrorFor?.call('isha'),
              fallbackTime: const TimeOfDay(hour: 20, minute: 15),
            ),
            const SizedBox(height: 14),
            _NamazTimePickerField(
              controller: jummaController,
              label: 'Jumma',
              errorText: fieldErrorFor?.call('jumma'),
              fallbackTime: const TimeOfDay(hour: 13, minute: 15),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Note',
                errorText: fieldErrorFor?.call('note'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NamazTimePickerField extends StatelessWidget {
  const _NamazTimePickerField({
    required this.controller,
    required this.label,
    required this.fallbackTime,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final TimeOfDay fallbackTime;
  final String? errorText;

  Future<void> _pickTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _parseTime(controller.text) ?? fallbackTime,
      helpText: 'Select $label time',
    );

    if (selectedTime == null) return;
    controller.text = _formatTime(selectedTime);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _pickTime(context),
      decoration: InputDecoration(
        labelText: label,
        hintText: _formatTime(fallbackTime),
        errorText: errorText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.access_time),
        suffixIcon: IconButton(
          tooltip: 'Select $label time',
          icon: const Icon(Icons.schedule),
          onPressed: () => _pickTime(context),
        ),
      ),
    );
  }

  TimeOfDay? _parseTime(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    final match = RegExp(
      r'^(\d{1,2}):(\d{2})(?:\s*([AaPp][Mm]))?$',
    ).firstMatch(trimmed);
    if (match == null) return null;

    var hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    final period = match.group(3)?.toUpperCase();
    if (hour == null || minute == null || minute > 59) return null;

    if (period != null) {
      if (hour < 1 || hour > 12) return null;
      if (period == 'AM' && hour == 12) hour = 0;
      if (period == 'PM' && hour != 12) hour += 12;
    } else if (hour > 23) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    final hourOfPeriod = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final hour = hourOfPeriod.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
