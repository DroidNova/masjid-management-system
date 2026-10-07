import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/widgets/app_button.dart';

/// Title / message / active form shared by the add and edit screens.
class AnnouncementFormBody extends StatelessWidget {
  const AnnouncementFormBody({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.messageController,
    required this.isActive,
    required this.onActiveChanged,
    required this.validator,
    required this.buttonLabel,
    required this.isSubmitting,
    required this.onSubmit,
    this.titleError,
    this.messageError,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController messageController;
  final bool isActive;
  final ValueChanged<bool> onActiveChanged;
  final FormFieldValidator<String> validator;
  final String buttonLabel;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  /// Server validation messages (from `fieldError`).
  final String? titleError;
  final String? messageError;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _AnnouncementTextField(
                    controller: titleController,
                    label: 'Title *',
                    validator: validator,
                    errorText: titleError,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  _AnnouncementTextField(
                    controller: messageController,
                    label: 'Message *',
                    maxLines: 4,
                    validator: validator,
                    errorText: messageError,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: isActive,
                    onChanged: onActiveChanged,
                    title: const Text('Is Active'),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: buttonLabel,
                    isLoading: isSubmitting,
                    onPressed: onSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Same look as AppTextField, plus a server-side [errorText].
class _AnnouncementTextField extends StatelessWidget {
  const _AnnouncementTextField({
    required this.controller,
    required this.label,
    required this.validator,
    required this.textInputAction,
    this.errorText,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final TextInputAction textInputAction;
  final String? errorText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      textInputAction: textInputAction,
      decoration: InputDecoration(labelText: label, errorText: errorText),
    );
  }
}

String? requiredAnnouncementField(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required.';
  return null;
}
