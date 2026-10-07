import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/features/announcements/application/announcements_controller.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/create_announcement_request.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/widgets/announcement_form_body.dart';

class AddAnnouncementScreen extends ConsumerStatefulWidget {
  const AddAnnouncementScreen({super.key});

  @override
  ConsumerState<AddAnnouncementScreen> createState() =>
      _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends ConsumerState<AddAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isActive = true;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(announcementFormControllerProvider.notifier);
    final saved = await controller.create(
      CreateAnnouncementRequest.fromForm(
        title: _titleController.text,
        message: _messageController.text,
        isActive: _isActive,
      ),
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (!saved) {
      final error = ref.read(announcementFormControllerProvider).error;
      if (error != null) {
        messenger.showSnackBar(SnackBar(content: Text(userMessage(error))));
      }
      return;
    }
    messenger.showSnackBar(
      const SnackBar(content: Text('Announcement added successfully.')),
    );
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(announcementFormControllerProvider);
    final error = saveState.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Announcement')),
      body: AnnouncementFormBody(
        formKey: _formKey,
        titleController: _titleController,
        messageController: _messageController,
        isActive: _isActive,
        onActiveChanged: (value) => setState(() => _isActive = value),
        validator: requiredAnnouncementField,
        buttonLabel: 'Save Announcement',
        isSubmitting: saveState.isLoading,
        onSubmit: _submit,
        titleError: fieldError(error, 'title'),
        messageError: fieldError(error, 'message'),
      ),
    );
  }
}
