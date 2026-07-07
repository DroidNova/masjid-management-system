import 'package:dio/dio.dart';
import 'package:platform_core_frontend/core/network/api_client.dart';
import 'package:platform_core_frontend/features/dashboard/data/models/dashboard_response.dart';

class DashboardApi {
  DashboardApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<DashboardResponse> getMyMasjidDashboard() async {
    try {
      final response = await _apiClient.dio.get<Object?>(
        '/dashboard/my-masjid',
      );
      return DashboardResponse.fromJson(_extractData(response.data));
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Map<String, dynamic> _extractData(Object? responseData) {
    if (responseData is Map<String, dynamic>) {
      final wrappedData = responseData['data'];
      if (wrappedData is Map<String, dynamic>) {
        return wrappedData;
      }
      return responseData;
    }

    throw const FormatException('Unexpected dashboard response from server.');
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

    return error.message ?? 'Unable to load dashboard. Please try again.';
  }
}
