import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/features/announcements/application/announcements_controller.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/update_announcement_request.dart';
import 'package:masjid_core_frontend/features/announcements/presentation/widgets/news_form.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Edits one piece of news. [announcement] (route `extra`, from the list)
/// is used as is; from a fresh URL it is loaded by [announcementId].
class EditAnnouncementScreen extends ConsumerWidget {
  const EditAnnouncementScreen({
    super.key,
    required this.announcementId,
    this.announcement,
  });

  final String announcementId;
  final AnnouncementModel? announcement;

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    String title,
    String message,
  ) async {
    final l10n = AppLocalizations.of(context);
    final saved = await ref
        .read(announcementFormControllerProvider.notifier)
        .updateAnnouncement(
          announcementId,
          UpdateAnnouncementRequest.fromForm(
            title: title,
            message: message,
            isActive: true,
          ),
        );
    if (!saved || !context.mounted) return;
    await showSuccess(context, title: l10n.saved, icon: AppIcons.edit);
    if (context.mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final passed = announcement;
    // Opened from the list: already up to date, no request needed.
    final loaded = passed == null
        ? ref.watch(announcementByIdProvider(announcementId))
        : AsyncData<AnnouncementModel>(passed);
    final current = loaded.valueOrNull;
    final saveState = ref.watch(announcementFormControllerProvider);
    final saveError = saveState.error;

    final Widget body;
    if (current != null) {
      body = NewsForm(
        initialTitle: current.title,
        initialMessage: current.message,
        saving: saveState.isLoading,
        error: saveError == null ? null : errorText(l10n, saveError),
        onSave: (title, message) => _save(context, ref, title, message),
      );
    } else if (loaded.hasError) {
      body = ErrorState(
        error: loaded.error!,
        onRetry: () => ref.invalidate(announcementByIdProvider(announcementId)),
      );
    } else {
      body = const SingleChildScrollView(
        child: PageBody.form(child: SkeletonList(itemCount: 2)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editNews)),
      body: SafeArea(top: false, child: body),
    );
  }
}
