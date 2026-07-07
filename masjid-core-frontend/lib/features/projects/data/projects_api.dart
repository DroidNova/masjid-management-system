import 'package:dio/dio.dart';
import 'package:platform_core_frontend/core/network/api_client.dart';
import 'package:platform_core_frontend/features/projects/data/models/create_project_request.dart';
import 'package:platform_core_frontend/features/projects/data/models/project_model.dart';
import 'package:platform_core_frontend/features/projects/data/models/update_project_request.dart';

class ProjectsApi {
  ProjectsApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await _apiClient.dio.get<Object?>('/projects/my-masjid');
      return _extractListData(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ProjectModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<ProjectModel> getProjectById(String id) async {
    try {
      final response = await _apiClient.dio.get<Object?>('/projects/$id');
      return ProjectModel.fromJson(_extractMapData(response.data));
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<ProjectModel> createProject(CreateProjectRequest request) async {
    try {
      final response = await _apiClient.dio.post<Object?>(
        '/projects/my-masjid',
        data: request.toJson(),
      );
      return ProjectModel.fromJson(_extractMapData(response.data));
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<ProjectModel> updateProject(
    String id,
    UpdateProjectRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.patch<Object?>(
        '/projects/$id',
        data: request.toJson(),
      );
      return ProjectModel.fromJson(_extractMapData(response.data));
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await _apiClient.dio.delete<Object?>('/projects/$id');
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Map<String, dynamic> _extractMapData(Object? responseData) {
    final data = _unwrapData(responseData);
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  List<dynamic> _extractListData(Object? responseData) {
    final data = _unwrapData(responseData);
    if (data is List<dynamic>) return data;
    if (data is Map<String, dynamic>) {
      final items = data['items'];
      if (items is List<dynamic>) return items;
    }
    return <dynamic>[];
  }

  Object? _unwrapData(Object? responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  String _readDioErrorMessage(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) return message;
      final responseError = responseData['error'];
      if (responseError is Map<String, dynamic>) {
        final errorMessage = responseError['message'];
        if (errorMessage is String && errorMessage.isNotEmpty) {
          return errorMessage;
        }
      }
    }
    return error.message ?? 'Unable to load projects.';
  }
}
