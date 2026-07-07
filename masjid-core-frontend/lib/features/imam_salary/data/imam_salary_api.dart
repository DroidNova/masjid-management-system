import 'package:dio/dio.dart';
import 'package:platform_core_frontend/core/network/api_client.dart';
import 'package:platform_core_frontend/features/imam_salary/models/create_imam_salary_request.dart';
import 'package:platform_core_frontend/features/imam_salary/models/imam_salary_model.dart';
import 'package:platform_core_frontend/features/imam_salary/models/update_imam_salary_request.dart';

class ImamSalaryApi {
  ImamSalaryApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<ImamSalaryModel>> getImamSalaries() async {
    try {
      final response = await _apiClient.dio.get<Object?>(
        '/imam-salaries/my-masjid',
      );
      return _extractListData(response.data)
          .whereType<Map<String, dynamic>>()
          .map(ImamSalaryModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<ImamSalaryModel> getImamSalaryById(String id) async {
    try {
      final response = await _apiClient.dio.get<Object?>('/imam-salaries/$id');
      return ImamSalaryModel.fromJson(_extractMapData(response.data));
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<ImamSalaryModel> createImamSalary(
    CreateImamSalaryRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.post<Object?>(
        '/imam-salaries/my-masjid',
        data: request.toJson(),
      );
      return ImamSalaryModel.fromJson(_extractMapData(response.data));
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<ImamSalaryModel> updateImamSalary(
    String id,
    UpdateImamSalaryRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.patch<Object?>(
        '/imam-salaries/$id',
        data: request.toJson(),
      );
      return ImamSalaryModel.fromJson(_extractMapData(response.data));
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<void> deleteImamSalary(String id) async {
    try {
      await _apiClient.dio.delete<Object?>('/imam-salaries/$id');
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
    return error.message ?? 'Unable to load imam salary records.';
  }
}
