import 'package:flutter/material.dart';
import 'package:platform_core_frontend/shared/widgets/app_text_field.dart';

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
  });

  final TextEditingController fajrController;
  final TextEditingController zuhrController;
  final TextEditingController asrController;
  final TextEditingController maghribController;
  final TextEditingController ishaController;
  final TextEditingController jummaController;
  final TextEditingController noteController;

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
              fallbackTime: const TimeOfDay(hour: 5, minute: 0),
            ),
            const SizedBox(height: 14),
            _NamazTimePickerField(
              controller: zuhrController,
              label: 'Zuhr',
              fallbackTime: const TimeOfDay(hour: 13, minute: 30),
            ),
            const SizedBox(height: 14),
            _NamazTimePickerField(
              controller: asrController,
              label: 'Asr',
              fallbackTime: const TimeOfDay(hour: 17, minute: 0),
            ),
            const SizedBox(height: 14),
            _NamazTimePickerField(
              controller: maghribController,
              label: 'Maghrib',
              fallbackTime: const TimeOfDay(hour: 18, minute: 45),
            ),
            const SizedBox(height: 14),
            _NamazTimePickerField(
              controller: ishaController,
              label: 'Isha',
              fallbackTime: const TimeOfDay(hour: 20, minute: 15),
            ),
            const SizedBox(height: 14),
            _NamazTimePickerField(
              controller: jummaController,
              label: 'Jumma',
              fallbackTime: const TimeOfDay(hour: 13, minute: 15),
            ),
            const SizedBox(height: 14),
            AppTextField(controller: noteController, label: 'Note', maxLines: 3),
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
  });

  final TextEditingController controller;
  final String label;
  final TimeOfDay fallbackTime;

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
