import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/features/announcements/application/announcements_controller.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/update_announcement_request.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/widgets/announcement_form_body.dart';
import 'package:masjid_core_frontend/shared/widgets/app_button.dart';
import 'package:masjid_core_frontend/shared/widgets/loading_view.dart';

/// Edits one announcement. Loads it by [announcementId], so the route works
/// from a fresh URL; [announcement] (route `extra`) is only shown instantly
/// while the real data loads.
class EditAnnouncementScreen extends ConsumerWidget {
  const EditAnnouncementScreen({
    super.key,
    required this.announcementId,
    this.announcement,
  });

  final String announcementId;
  final AnnouncementModel? announcement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref.watch(announcementByIdProvider(announcementId));
    final preview = announcement;
    final current = loaded.valueOrNull ?? preview;

    Widget body;
    if (current != null) {
      body = _EditAnnouncementForm(
        announcementId: announcementId,
        initial: current,
      );
    } else if (loaded.hasError) {
      body = _EditAnnouncementError(
        message: userMessage(loaded.error!),
        onRetry: () => ref.invalidate(announcementByIdProvider(announcementId)),
      );
    } else {
      body = const LoadingView();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Announcement')),
      body: body,
    );
  }
}

class _EditAnnouncementForm extends ConsumerStatefulWidget {
  const _EditAnnouncementForm({
    required this.announcementId,
    required this.initial,
  });

  final String announcementId;
  final AnnouncementModel initial;

  @override
  ConsumerState<_EditAnnouncementForm> createState() =>
      _EditAnnouncementFormState();
}

class _EditAnnouncementFormState extends ConsumerState<_EditAnnouncementForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _fill(widget.initial);
  }

  @override
  void didUpdateWidget(covariant _EditAnnouncementForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The real data replaced the preview: take it, unless the user has
    // already started editing.
    final old = oldWidget.initial;
    final untouched =
        _titleController.text == old.title &&
        _messageController.text == old.message &&
        _isActive == old.isActive;
    if (widget.initial != old && untouched) _fill(widget.initial);
  }

  void _fill(AnnouncementModel announcement) {
    _titleController.text = announcement.title;
    _messageController.text = announcement.message;
    _isActive = announcement.isActive;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(announcementFormControllerProvider.notifier);
    final saved = await controller.updateAnnouncement(
      widget.announcementId,
      UpdateAnnouncementRequest.fromForm(
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
      const SnackBar(content: Text('Announcement updated successfully.')),
    );
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(announcementFormControllerProvider);
    final error = saveState.error;

    return AnnouncementFormBody(
      formKey: _formKey,
      titleController: _titleController,
      messageController: _messageController,
      isActive: _isActive,
      onActiveChanged: (value) => setState(() => _isActive = value),
      validator: requiredAnnouncementField,
      buttonLabel: 'Update Announcement',
      isSubmitting: saveState.isLoading,
      onSubmit: _submit,
      titleError: fieldError(error, 'title'),
      messageError: fieldError(error, 'message'),
    );
  }
}

class _EditAnnouncementError extends StatelessWidget {
  const _EditAnnouncementError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppButton(label: 'Retry', onPressed: onRetry),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
