import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/data/models/projects_filter.dart';
import 'package:masjid_core_frontend/features/projects/data/projects_repository.dart';

/// Filter for the projects list. Changing it reloads from page 1.
final projectsFilterProvider = StateProvider.autoDispose<ProjectsFilter>(
  (ref) => const ProjectsFilter(),
);

final projectsControllerProvider =
    AsyncNotifierProvider.autoDispose<
      ProjectsController,
      PagedState<ProjectModel>
    >(ProjectsController.new);

class ProjectsController extends PagedController<ProjectModel> {
  @override
  Future<PagedState<ProjectModel>> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    ref.watch(projectsFilterProvider);
    // Recording a project contribution marks DataScope.projects too.
    ref.watch(dataVersionProvider(DataScope.projects));
    return super.build();
  }

  @override
  Future<PageResult<ProjectModel>> fetchPage(int page) => ref
      .read(projectsRepositoryProvider)
      .getProjects(ref.read(projectsFilterProvider), page: page);
}
