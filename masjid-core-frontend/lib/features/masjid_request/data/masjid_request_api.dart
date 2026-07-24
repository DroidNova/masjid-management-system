import 'package:dio/dio.dart';
import 'package:platform_core_frontend/core/network/api_client.dart';
import 'package:platform_core_frontend/features/masjid_request/data/models/create_masjid_request.dart';
import 'package:platform_core_frontend/features/masjid_request/data/models/track_masjid_application_result.dart';

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


  Future<List<TrackMasjidApplicationResult>> trackApplicationByPhone(
    String requesterPhone,
  ) async {
    try {
      final response = await _apiClient.dio.post<Object?>(
        '/masjid-requests/track',
        data: <String, dynamic>{'requesterPhone': requesterPhone},
      );

      return _extractTrackItems(response.data)
          .whereType<Map<String, dynamic>>()
          .map(TrackMasjidApplicationResult.fromJson)
          .toList();
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  List<dynamic> _extractTrackItems(Object? responseData) {
    final unwrapped = _unwrapData(responseData);
    if (unwrapped is List<dynamic>) return unwrapped;
    if (unwrapped is Map<String, dynamic>) {
      final items = unwrapped['items'];
      if (items is List<dynamic>) return items;
      final nestedData = unwrapped['data'];
      if (nestedData is Map<String, dynamic>) {
        final nestedItems = nestedData['items'];
        if (nestedItems is List<dynamic>) return nestedItems;
      }
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
