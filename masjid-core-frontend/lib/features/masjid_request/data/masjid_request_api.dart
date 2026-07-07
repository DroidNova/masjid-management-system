import 'package:dio/dio.dart';
import 'package:platform_core_frontend/core/network/api_client.dart';
import 'package:platform_core_frontend/features/masjid_request/data/models/create_masjid_request.dart';

class MasjidRequestApi {
  MasjidRequestApi({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<void> submitMasjidRequest(CreateMasjidRequest request) async {
    try {
      final response = await _apiClient.dio.post<Object?>(
        '/masjid-requests',
        data: request.toJson(),
      );

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) return;

      final success = responseData['success'];
      if (success == false) {
        throw Exception(_readMessage(responseData));
      }
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  String _readDioErrorMessage(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      return _readMessage(responseData);
    }

    return error.message ?? 'Unable to submit request. Please try again.';
  }

  String _readMessage(Map<String, dynamic> responseData) {
    final message = responseData['message'];
    if (message is String && message.isNotEmpty) return message;

    final responseError = responseData['error'];
    if (responseError is Map<String, dynamic>) {
      final errorMessage = responseError['message'];
      if (errorMessage is String && errorMessage.isNotEmpty) {
        return errorMessage;
      }
    }

    return 'Unable to submit request. Please try again.';
  }
}
