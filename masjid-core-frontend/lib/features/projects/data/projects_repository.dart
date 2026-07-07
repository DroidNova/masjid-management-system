import 'package:platform_core_frontend/core/network/api_request_coordinator.dart';
import 'package:platform_core_frontend/core/refresh/app_data_refresh_bus.dart';
import 'package:platform_core_frontend/features/projects/data/models/create_project_request.dart';
import 'package:platform_core_frontend/features/projects/data/models/project_model.dart';
import 'package:platform_core_frontend/features/projects/data/models/update_project_request.dart';
import 'package:platform_core_frontend/features/projects/data/projects_api.dart';

class ProjectsRepository {
  ProjectsRepository({ProjectsApi? projectsApi})
      : _projectsApi = projectsApi ?? ProjectsApi();

  final ProjectsApi _projectsApi;

  Future<List<ProjectModel>> getProjects() {
    return ApiRequestCoordinator.instance.run<List<ProjectModel>>(
      key: 'GET:/projects/my-masjid',
      request: _projectsApi.getProjects,
    );
  }

  Future<ProjectModel> getProjectById(String id) {
    return ApiRequestCoordinator.instance.run<ProjectModel>(
      key: 'GET:/projects/$id',
      request: () => _projectsApi.getProjectById(id),
    );
  }

  Future<ProjectModel> createProject(CreateProjectRequest request) async {
    final project = await _projectsApi.createProject(request);
    AppDataRefreshBus.instance.notifyMany(<AppDataScope>[
      AppDataScope.projects,
      AppDataScope.dashboard,
    ]);
    return project;
  }

  Future<ProjectModel> updateProject(String id, UpdateProjectRequest request) async {
    final project = await _projectsApi.updateProject(id, request);
    AppDataRefreshBus.instance.notifyMany(<AppDataScope>[
      AppDataScope.projects,
      AppDataScope.dashboard,
    ]);
    return project;
  }

  Future<void> deleteProject(String id) async {
    await _projectsApi.deleteProject(id);
    AppDataRefreshBus.instance.notifyMany(<AppDataScope>[
      AppDataScope.projects,
      AppDataScope.dashboard,
    ]);
  }
}
