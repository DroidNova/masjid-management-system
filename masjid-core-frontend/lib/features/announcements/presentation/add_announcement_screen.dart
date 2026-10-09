import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/features/announcements/application/announcements_controller.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/create_announcement_request.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/widgets/news_form.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Writes a new piece of news; it is visible to everyone once saved.
class AddAnnouncementScreen extends ConsumerWidget {
  const AddAnnouncementScreen({super.key});

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    String title,
    String message,
  ) async {
    final l10n = AppLocalizations.of(context);
    final saved = await ref
        .read(announcementFormControllerProvider.notifier)
        .create(
          CreateAnnouncementRequest.fromForm(
            title: title,
            message: message,
            isActive: true,
          ),
        );
    if (!saved || !context.mounted) return;
    await showSuccess(
      context,
      title: l10n.newsPublished,
      icon: AppIcons.announcements,
    );
    if (context.mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(announcementFormControllerProvider);
    final error = state.error;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addNews)),
      body: SafeArea(
        top: false,
        child: NewsForm(
          saving: state.isLoading,
          error: error == null ? null : errorText(l10n, error),
          onSave: (title, message) => _save(context, ref, title, message),
        ),
      ),
    );
  }
}
