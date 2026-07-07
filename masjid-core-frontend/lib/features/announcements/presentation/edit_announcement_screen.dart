import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/features/announcements/data/announcements_repository.dart';
import 'package:platform_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:platform_core_frontend/features/announcements/data/models/update_announcement_request.dart';
import 'package:platform_core_frontend/features/announcements/presentation/add_announcement_screen.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';

class EditAnnouncementScreen extends StatefulWidget {
  const EditAnnouncementScreen({
    super.key,
    required this.announcementId,
    required this.announcement,
    AnnouncementsRepository? announcementsRepository,
  }) : _announcementsRepository = announcementsRepository;

  final String announcementId;
  final AnnouncementModel? announcement;
  final AnnouncementsRepository? _announcementsRepository;

  @override
  State<EditAnnouncementScreen> createState() => _EditAnnouncementScreenState();
}

class _EditAnnouncementScreenState extends State<EditAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  late final AnnouncementsRepository _announcementsRepository =
      widget._announcementsRepository ?? AnnouncementsRepository();

  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final announcement = widget.announcement;
    if (announcement != null) {
      _titleController.text = announcement.title;
      _messageController.text = announcement.message;
      _isActive = announcement.isActive;
    }
  }

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
      await _announcementsRepository.updateAnnouncement(
        widget.announcementId,
        UpdateAnnouncementRequest(
          title: _titleController.text,
          message: _messageController.text,
          isActive: _isActive,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement updated successfully.')),
      );
      context.pop(true);
    } catch (error) {
      if (mounted) _showError(_cleanError(error));
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

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.announcement == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Announcement')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Announcement information is missing.'),
                const SizedBox(height: 16),
                AppButton(label: 'Back', onPressed: () => context.pop()),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Announcement')),
      body: AnnouncementFormBody(
        formKey: _formKey,
        titleController: _titleController,
        messageController: _messageController,
        isActive: _isActive,
        onActiveChanged: (value) => setState(() => _isActive = value),
        validator: _required,
        buttonLabel: 'Update Announcement',
        isSubmitting: _isSubmitting,
        onSubmit: _submit,
      ),
    );
  }
}
