import 'package:dio/dio.dart';
import 'package:platform_core_frontend/core/network/api_client.dart';
import 'package:platform_core_frontend/features/namaz_time/data/models/namaz_time_model.dart';
import 'package:platform_core_frontend/features/namaz_time/data/models/update_namaz_time_request.dart';

class NamazTimeApi {
  NamazTimeApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<NamazTimeModel?> getNamazTime(String masjidId) async {
    try {
      final response = await _apiClient.dio.get<Object?>(
        '/namaz-times/$masjidId',
      );
      final data = _extractMapData(response.data);
      if (data.isEmpty) return null;
      return NamazTimeModel.fromJson(data);
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Future<NamazTimeModel> updateNamazTime({
    required String masjidId,
    required UpdateNamazTimeRequest request,
  }) async {
    try {
      final response = await _apiClient.dio.put<Object?>(
        '/namaz-times/$masjidId',
        data: request.toJson(),
      );
      return NamazTimeModel.fromJson(_extractMapData(response.data));
    } on DioException catch (error) {
      throw Exception(_readDioErrorMessage(error));
    }
  }

  Map<String, dynamic> _extractMapData(Object? responseData) {
    if (responseData is Map<String, dynamic>) {
      final wrappedData = responseData['data'];
      if (wrappedData is Map<String, dynamic>) return wrappedData;
      return responseData;
    }
    return <String, dynamic>{};
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
    return error.message ?? 'Unable to load namaz timings.';
  }
}
