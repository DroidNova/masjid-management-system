import 'package:platform_core_frontend/core/network/response_mapper.dart';
import 'package:platform_core_frontend/shared/models/page_meta.dart';
import 'package:platform_core_frontend/shared/models/paginated_data.dart';
import 'package:platform_core_frontend/shared/types/json_types.dart';

class ListResponseMapper {
  const ListResponseMapper._();

  static PaginatedData<T> map<T>(
    dynamic raw, {
    required T Function(JsonMap json) itemParser,
    int defaultLimit = 20,
  }) {
    final payload = ResponseMapper.unwrapDataMap(raw);
    // TODO(BACKEND): confirm final list envelope keys for each endpoint.
    final itemsRaw = payload['items'] ?? payload['users'] ?? payload['data'] ?? const [];

    final itemMaps = (itemsRaw as List?)?.whereType<JsonMap>().toList() ??
        const <JsonMap>[];
    final items = itemMaps.map(itemParser).toList(growable: false);

    final page = _asInt(payload['page'], fallback: 1);
    final limit = _asInt(payload['limit'], fallback: items.isEmpty ? defaultLimit : items.length);
    final total = _asInt(payload['total'], fallback: items.length);

    return PaginatedData<T>(
      items: items,
      meta: PageMeta(
        page: page,
        limit: limit,
        total: total,
      ),
    );
  }

  static int _asInt(dynamic raw, {required int fallback}) {
    if (raw is int) {
      return raw;
    }
    return int.tryParse(raw?.toString() ?? '') ?? fallback;
  }
}
