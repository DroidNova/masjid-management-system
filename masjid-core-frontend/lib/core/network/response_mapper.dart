import 'package:platform_core_frontend/shared/types/json_types.dart';

class ResponseMapper {
  const ResponseMapper._();

  static JsonMap asMap(dynamic raw) {
    if (raw is JsonMap) {
      return raw;
    }
    return const <String, dynamic>{};
  }

  static JsonMap unwrapDataMap(dynamic raw) {
    final payload = asMap(raw);
    final data = payload['data'];
    if (data is JsonMap) {
      return data;
    }
    return payload;
  }

  static List<dynamic> unwrapDataList(dynamic raw) {
    if (raw is List) {
      return raw;
    }

    final payload = asMap(raw);
    final data = payload['data'];
    if (data is List) {
      return data;
    }

    return const <dynamic>[];
  }
}
