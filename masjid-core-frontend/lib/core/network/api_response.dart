import 'package:platform_core_frontend/shared/types/json_types.dart';

class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
    this.errors,
  });

  final bool success;
  final String message;
  final T? data;
  final String? errorCode;
  final JsonMap? errors;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    final success = json['success'] == true;
    final message = _parseMessage(json['message']);
    final errorCode = json['errorCode'] is String
        ? (json['errorCode'] as String).trim()
        : null;

    final rawErrors = json['errors'];
    final errors = rawErrors is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawErrors)
        : null;

    T? parsedData;
    final rawData = json['data'];
    if (success && rawData != null) {
      parsedData = fromJsonT != null ? fromJsonT(rawData) : rawData as T;
    }

    return ApiResponse<T>(
      success: success,
      message: message,
      data: parsedData,
      errorCode: errorCode == null || errorCode.isEmpty ? null : errorCode,
      errors: errors,
    );
  }

  static String _parseMessage(dynamic rawMessage) {
    if (rawMessage is String && rawMessage.trim().isNotEmpty) {
      return rawMessage.trim();
    }

    if (rawMessage is List && rawMessage.isNotEmpty) {
      final first = rawMessage.first;
      if (first is String && first.trim().isNotEmpty) {
        return first.trim();
      }
    }

    return 'Something went wrong. Please try again later.';
  }
}
