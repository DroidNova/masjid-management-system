import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/features/projects/data/models/create_project_request.dart';
import 'package:masjid_core_frontend/features/projects/data/models/project_model.dart';
import 'package:masjid_core_frontend/features/projects/data/models/projects_filter.dart';
import 'package:masjid_core_frontend/features/projects/data/models/update_project_request.dart';

/// Project endpoints. Errors surface as ApiException (with `code`).
class ProjectsApi {
  ProjectsApi(this._apiClient);

  final ApiClient _apiClient;

  Future<PageResult<ProjectModel>> getProjects(
    ProjectsFilter filter, {
    required int page,
    required int limit,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/projects/my-masjid',
      query: <String, dynamic>{
        ...filter.toQuery(),
        'page': page,
        'limit': limit,
      },
    );
    return PageResult.fromJson(data, ProjectModel.fromJson);
  }

  Future<ProjectModel> getProjectById(String id) async {
    final data = await _apiClient.get<Map<String, dynamic>>('/projects/$id');
    return ProjectModel.fromJson(data);
  }

  Future<ProjectModel> createProject(CreateProjectRequest request) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/projects/my-masjid',
      body: request.toJson(),
    );
    return ProjectModel.fromJson(data);
  }

  Future<ProjectModel> updateProject(
    String id,
    UpdateProjectRequest request,
  ) async {
    final data = await _apiClient.patch<Map<String, dynamic>>(
      '/projects/$id',
      body: request.toJson(),
    );
    return ProjectModel.fromJson(data);
  }

  /// The server keeps the project and sets its status to CANCELLED.
  Future<void> deleteProject(String id) async {
    await _apiClient.delete<Object?>('/projects/$id');
  }
}
