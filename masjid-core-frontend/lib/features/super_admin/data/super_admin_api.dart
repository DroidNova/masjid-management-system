import 'package:dio/dio.dart';
import 'package:platform_core_frontend/core/network/api_client.dart';
import 'package:platform_core_frontend/core/network/api_request_coordinator.dart';

class AdminListResult {
  const AdminListResult(this.items, this.total);

  final List<Map<String, dynamic>> items;
  final int total;
}

class SuperAdminApi {
  SuperAdminApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AdminListResult> getUsers({
    String? search,
    String? status,
    String? role,
    int page = 1,
    int limit = 20,
  }) {
    final query = _cleanQuery(<String, dynamic>{
      'search': search,
      'status': status,
      'role': role,
      'page': page,
      'limit': limit,
    });
    return ApiRequestCoordinator.instance.run<AdminListResult>(
      key: _requestKey('/admin/users', query),
      request: () => _getList('/admin/users', query),
    );
  }

  Future<Map<String, dynamic>> getUser(String id) {
    return ApiRequestCoordinator.instance.run<Map<String, dynamic>>(
      key: 'GET:/admin/users/$id',
      request: () => _getMap('/admin/users/$id'),
    );
  }

  Future<Map<String, dynamic>> updateUserStatus(
    String id,
    Map<String, dynamic> data,
  ) {
    return _patchMap('/admin/users/$id/status', data);
  }

  Future<Map<String, dynamic>> updateUserRoles(
    String id,
    Map<String, dynamic> data,
  ) {
    return _postMap('/admin/users/$id/roles', data);
  }

  Future<AdminListResult> getMasjidRequests({
    String? search,
    String? status,
    int page = 1,
    int limit = 20,
  }) {
    final query = _cleanQuery(<String, dynamic>{
      'search': search,
      'status': status,
      'page': page,
      'limit': limit,
    });
    return ApiRequestCoordinator.instance.run<AdminListResult>(
      key: _requestKey('/masjid-requests', query),
      request: () => _getList('/masjid-requests', query),
    );
  }

  Future<Map<String, dynamic>> getMasjidRequest(String id) async {
    final list = await _getList('/masjid-requests', <String, dynamic>{
      'id': id,
      'limit': 1,
    });
    return list.items.isNotEmpty ? list.items.first : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateMasjidRequestStatus(
    String id,
    Map<String, dynamic> data,
  ) {
    return _patchMap('/masjid-requests/$id/status', data);
  }

  Future<AdminListResult> getMasjids({
    String? search,
    String? status,
    int page = 1,
    int limit = 20,
  }) {
    final query = _cleanQuery(<String, dynamic>{
      'search': search,
      'status': status,
      'page': page,
      'limit': limit,
    });
    return ApiRequestCoordinator.instance.run<AdminListResult>(
      key: _requestKey('/masjids', query),
      request: () => _getList('/masjids', query),
    );
  }

  Future<Map<String, dynamic>> getMasjid(String id) {
    return ApiRequestCoordinator.instance.run<Map<String, dynamic>>(
      key: 'GET:/masjids/$id',
      request: () => _getMap('/masjids/$id'),
    );
  }

  Future<Map<String, dynamic>> updateMasjidStatus(
    String id,
    Map<String, dynamic> data,
  ) {
    return _patchMap('/masjids/$id/status', data);
  }

  Future<AdminListResult> _getList(
    String path,
    Map<String, dynamic> query,
  ) async {
    try {
      final response = await _apiClient.dio.get<Object?>(
        path,
        queryParameters: query,
      );
      final data = _unwrap(response.data);
      final total = _total(data);
      final raw = data is Map<String, dynamic> ? data['items'] : data;
      final items = raw is List
          ? raw.whereType<Map<String, dynamic>>().toList()
          : <Map<String, dynamic>>[];
      return AdminListResult(items, total == 0 ? items.length : total);
    } on DioException catch (error) {
      throw Exception(_message(error));
    }
  }

  Future<Map<String, dynamic>> _getMap(String path) async {
    try {
      final response = await _apiClient.dio.get<Object?>(path);
      final data = _unwrap(response.data);
      return data is Map<String, dynamic> ? data : <String, dynamic>{};
    } on DioException catch (error) {
      throw Exception(_message(error));
    }
  }

  Future<Map<String, dynamic>> _patchMap(String path, Object data) async {
    try {
      final response = await _apiClient.dio.patch<Object?>(path, data: data);
      final unwrapped = _unwrap(response.data);
      return unwrapped is Map<String, dynamic>
          ? unwrapped
          : <String, dynamic>{};
    } on DioException catch (error) {
      throw Exception(_message(error));
    }
  }

  Future<Map<String, dynamic>> _postMap(String path, Object data) async {
    try {
      final response = await _apiClient.dio.post<Object?>(path, data: data);
      final unwrapped = _unwrap(response.data);
      return unwrapped is Map<String, dynamic>
          ? unwrapped
          : <String, dynamic>{};
    } on DioException catch (error) {
      throw Exception(_message(error));
    }
  }

  Map<String, dynamic> _cleanQuery(Map<String, dynamic> query) {
    return Map<String, dynamic>.from(query)
      ..removeWhere((key, value) => value == null || value == '');
  }

  String _requestKey(String path, Map<String, dynamic> query) {
    if (query.isEmpty) return 'GET:$path';
    final parts = query.entries
        .map(
          (entry) =>
              '${entry.key}=${Uri.encodeQueryComponent('${entry.value}')}',
        )
        .join('&');
    return 'GET:$path?$parts';
  }

  Object? _unwrap(Object? response) {
    return response is Map<String, dynamic> && response.containsKey('data')
        ? response['data']
        : response;
  }

  int _total(Object? data) {
    if (data is Map<String, dynamic>) {
      final total = data['total'] ?? data['count'];
      if (total is int) return total;
      return int.tryParse(total?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  String _message(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String) return message;
    }
    if (error.response?.statusCode == 403) {
      return 'You are not allowed to perform this action.';
    }
    if (error.response?.statusCode == 401) {
      return 'Session expired. Please login again.';
    }
    if (error.response?.statusCode == 404) return 'This API is not available yet.';
    return error.message ?? 'Something went wrong.';
  }
}
