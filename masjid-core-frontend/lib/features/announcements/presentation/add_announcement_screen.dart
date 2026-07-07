import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/errors/error_message_helper.dart';
import 'package:platform_core_frontend/features/announcements/data/announcements_repository.dart';
import 'package:platform_core_frontend/features/announcements/data/models/create_announcement_request.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/app_text_field.dart';

class AddAnnouncementScreen extends StatefulWidget {
  const AddAnnouncementScreen({
    super.key,
    AnnouncementsRepository? announcementsRepository,
  }) : _announcementsRepository = announcementsRepository;

  final AnnouncementsRepository? _announcementsRepository;

  @override
  State<AddAnnouncementScreen> createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  late final AnnouncementsRepository _announcementsRepository =
      widget._announcementsRepository ?? AnnouncementsRepository();

  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await _announcementsRepository.createAnnouncement(
        CreateAnnouncementRequest(
          title: _titleController.text,
          message: _messageController.text,
          isActive: _isActive,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement added successfully.')),
      );
      context.pop(true);
    } catch (error) {
      if (mounted) _showError(getReadableErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required.';
    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Announcement')),
      body: AnnouncementFormBody(
        formKey: _formKey,
        titleController: _titleController,
        messageController: _messageController,
        isActive: _isActive,
        onActiveChanged: (value) => setState(() => _isActive = value),
        validator: _required,
        buttonLabel: 'Save Announcement',
        isSubmitting: _isSubmitting,
        onSubmit: _submit,
      ),
    );
  }
}

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
                  AppTextField(
                    controller: titleController,
                    label: 'Title *',
                    validator: validator,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: messageController,
                    label: 'Message *',
                    maxLines: 4,
                    validator: validator,
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
