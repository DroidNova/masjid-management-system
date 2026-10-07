import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/projects/data/models/create_project_request.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/data/models/projects_filter.dart';
import 'package:masjid_core_frontend/features/projects/data/models/update_project_request.dart';
import 'package:masjid_core_frontend/features/projects/data/projects_api.dart';

final projectsRepositoryProvider = Provider<ProjectsRepository>(
  (ref) => ProjectsRepository(ProjectsApi(ref.watch(apiClientProvider))),
);

class ProjectsRepository {
  ProjectsRepository(this._api);

  final ProjectsApi _api;

  static const int pageSize = 20;

  Future<PageResult<ProjectModel>> getProjects(
    ProjectsFilter filter, {
    int page = 1,
  }) => _api.getProjects(filter, page: page, limit: pageSize);

  Future<ProjectModel> getProjectById(String id) => _api.getProjectById(id);

  Future<ProjectModel> createProject(CreateProjectRequest request) =>
      _api.createProject(request);

  Future<ProjectModel> updateProject(String id, UpdateProjectRequest request) =>
      _api.updateProject(id, request);

  Future<void> deleteProject(String id) => _api.deleteProject(id);
}
