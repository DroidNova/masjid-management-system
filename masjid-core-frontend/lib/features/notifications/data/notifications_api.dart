import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/record_history/data/record_history.dart';

final notificationsApiProvider = Provider<NotificationsApi>(
  (ref) => NotificationsApi(ref.watch(apiClientProvider)),
);

/// `/notifications/my`: the signed-in person's notices (the bell).
class NotificationsApi {
  NotificationsApi(this._apiClient);

  final ApiClient _apiClient;

  Future<PageResult<AppNotification>> list({required int page}) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/notifications/my',
      query: <String, dynamic>{'page': page, 'limit': 20},
    );
    return PageResult.fromJson(data, AppNotification.fromJson);
  }

  Future<int> unreadCount() async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/notifications/my/unread-count',
    );
    return (data['count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markAllRead() =>
      _apiClient.post<Object?>('/notifications/my/read-all');
}

/// One notice. [kind] is PAYMENT_RECORDED, PAYMENT_CHANGED or
/// PAYMENT_CANCELLED; [purpose] says what the money was for (SALARY with
/// [month]/[year], PROJECT with [projectTitle], DONATION with
/// [collectionType]). The app writes the sentence in the reader's language.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.actorName,
    required this.amount,
    required this.purpose,
    required this.createdAt,
    this.history,
    this.newAmount,
    this.month,
    this.year,
    this.projectTitle,
    this.collectionType,
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final entity = HistoryEntity.values
        .where((value) => value.value == json['entity'])
        .firstOrNull;
    final entityId = json['entityId'] as String?;
    return AppNotification(
      id: json['id'] as String,
      kind: json['kind'] as String? ?? '',
      actorName: json['actorName'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      newAmount: (data['newAmount'] as num?)?.toDouble(),
      purpose: data['purpose'] as String? ?? '',
      month: (data['month'] as num?)?.toInt(),
      year: (data['year'] as num?)?.toInt(),
      projectTitle: data['projectTitle'] as String?,
      collectionType: data['collectionType'] as String?,
      history: entity == null || entityId == null
          ? null
          : (entity: entity, id: entityId),
      readAt: DateTime.tryParse(json['readAt'] as String? ?? '')?.toLocal(),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }

  final String id;
  final String kind;
  final String actorName;
  final double amount;

  /// PAYMENT_CHANGED only, when the amount itself changed.
  final double? newAmount;
  final String purpose;
  final int? month;
  final int? year;
  final String? projectTitle;
  final String? collectionType;

  /// The record to open (its history) when the notice is tapped.
  final HistoryTarget? history;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isUnread => readAt == null;
}
