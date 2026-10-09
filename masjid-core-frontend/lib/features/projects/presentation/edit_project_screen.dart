import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/error_text.dart';
import 'package:masjid_core_frontend/features/projects/application/project_detail_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/presentation/project_form_screen.dart';
import 'package:masjid_core_frontend/l10n/app_localizations.dart';
import 'package:masjid_core_frontend/shared/ui/ui.dart';

/// Edits a project. [initialProject] (from the detail page) fills the form
/// at once; from a fresh URL the project is loaded by [projectId].
class EditProjectScreen extends ConsumerWidget {
  const EditProjectScreen({
    super.key,
    required this.projectId,
    this.initialProject,
  });

  final String projectId;
  final ProjectModel? initialProject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passed = initialProject;
    if (passed != null && passed.id == projectId) {
      return ProjectFormScreen(initial: passed);
    }

    final l10n = AppLocalizations.of(context);
    final state = ref.watch(projectDetailProvider(projectId));
    final loaded = state.valueOrNull;
    if (loaded != null) return ProjectFormScreen(initial: loaded);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProject)),
      body: state.hasError
          ? EmptyState(
              icon: AppIcons.problem,
              tone: AppTones.problem,
              title: errorText(l10n, state.error!),
              actionLabel: l10n.tryAgain,
              onAction: () => ref.invalidate(projectDetailProvider(projectId)),
            )
          : const SingleChildScrollView(
              child: PageBody.form(child: SkeletonList(itemCount: 3)),
            ),
    );
  }
}
