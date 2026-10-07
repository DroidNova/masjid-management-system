import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/data/projects_repository.dart';

/// One project, always loaded by id (so `/projects/:id` works from a fresh
/// URL). A project passed as route `extra` is only an instant preview.
final projectDetailProvider = AsyncNotifierProvider.autoDispose
    .family<ProjectDetailController, ProjectModel, String>(
      ProjectDetailController.new,
    );

class ProjectDetailController
    extends AutoDisposeFamilyAsyncNotifier<ProjectModel, String> {
  @override
  Future<ProjectModel> build(String projectId) {
    ref.watch(currentUserProvider.select((user) => user?.id));
    ref.watch(dataVersionProvider(DataScope.projects));
    // Contributions change the collected amount.
    ref.watch(dataVersionProvider(DataScope.contributions));
    return ref.watch(projectsRepositoryProvider).getProjectById(projectId);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
