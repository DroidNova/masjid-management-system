import 'package:dio/dio.dart';
import 'package:platform_core_frontend/core/network/api_client.dart';
import 'package:platform_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:platform_core_frontend/features/announcements/data/models/create_announcement_request.dart';
import 'package:platform_core_frontend/features/announcements/data/models/update_announcement_request.dart';

class AnnouncementsApi {
  AnnouncementsApi({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<AnnouncementModel>> getAnnouncements() async {
    try {
      final response = await _apiClient.dio.get<Object?>(
        '/announcements/my-masjid',
      );
      return _extractListData(response.data)
          .whereType<Map<String, dynamic>>()
          .map(AnnouncementModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<AnnouncementModel> createAnnouncement(
    CreateAnnouncementRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.post<Object?>(
        '/announcements/my-masjid',
        data: request.toJson(),
      );
      return AnnouncementModel.fromJson(_extractMapData(response.data));
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<AnnouncementModel> updateAnnouncement(
    String id,
    UpdateAnnouncementRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.patch<Object?>(
        '/announcements/$id',
        data: request.toJson(),
      );
      return AnnouncementModel.fromJson(_extractMapData(response.data));
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      await _apiClient.dio.delete<Object?>('/announcements/$id');
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
    return error.message ?? 'Unable to load announcements.';
  }
}
