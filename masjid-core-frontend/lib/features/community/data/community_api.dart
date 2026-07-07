import 'package:dio/dio.dart';
import 'package:platform_core_frontend/core/network/api_client.dart';
import 'package:platform_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:platform_core_frontend/features/community/data/models/create_community_user_request.dart';
import 'package:platform_core_frontend/features/community/data/models/masjid_detail_model.dart';

class CommunityApi {
  CommunityApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<MasjidDetailModel> getMyMasjid() async {
    try {
      final response = await _apiClient.dio.get<Object?>('/masjids/my');
      return MasjidDetailModel.fromJson(_extractMapData(response.data));
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<List<CommunityUserModel>> getMyMasjidUsers() async {
    try {
      final response = await _apiClient.dio.get<Object?>('/masjids/my/users');
      return _extractListData(response.data)
          .whereType<Map<String, dynamic>>()
          .map(CommunityUserModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<CommunityUserModel> createMasjidUser(
    CreateCommunityUserRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.post<Object?>(
        '/masjids/my/users',
        data: request.toJson(),
      );
      final userData = _extractCreatedUserData(response.data);
      return CommunityUserModel.fromJson(userData);
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Map<String, dynamic> _extractMapData(Object? responseData) {
    final data = _unwrapData(responseData);
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  Map<String, dynamic> _extractCreatedUserData(Object? responseData) {
    final data = _unwrapData(responseData);
    final responseMap = responseData is Map<String, dynamic>
        ? responseData
        : const <String, dynamic>{};

    if (data is Map<String, dynamic>) {
      final user = data['user'];
      final userMap = user is Map<String, dynamic>
          ? Map<String, dynamic>.from(user)
          : Map<String, dynamic>.from(data);

      final wrapperMessage = responseMap['message'];
      if (wrapperMessage is String && !userMap.containsKey('message')) {
        userMap['message'] = wrapperMessage;
      }
      final temporaryPassword = data['temporaryPassword'];
      if (temporaryPassword != null &&
          !userMap.containsKey('temporaryPassword')) {
        userMap['temporaryPassword'] = temporaryPassword;
      }
      return userMap;
    }

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
    return error.message ?? 'Unable to load community details.';
  }
}
