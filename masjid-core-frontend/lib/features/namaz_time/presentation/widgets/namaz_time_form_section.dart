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
            AppTextField(controller: fajrController, label: 'Fajr', hint: '05:00 AM'),
            const SizedBox(height: 14),
            AppTextField(controller: zuhrController, label: 'Zuhr', hint: '01:30 PM'),
            const SizedBox(height: 14),
            AppTextField(controller: asrController, label: 'Asr', hint: '05:00 PM'),
            const SizedBox(height: 14),
            AppTextField(
              controller: maghribController,
              label: 'Maghrib',
              hint: '06:45 PM',
            ),
            const SizedBox(height: 14),
            AppTextField(controller: ishaController, label: 'Isha', hint: '08:15 PM'),
            const SizedBox(height: 14),
            AppTextField(controller: jummaController, label: 'Jumma', hint: '01:15 PM'),
            const SizedBox(height: 14),
            AppTextField(controller: noteController, label: 'Note', maxLines: 3),
          ],
        ),
      ),
    );
  }
}
