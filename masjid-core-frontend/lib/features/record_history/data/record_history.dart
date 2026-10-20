import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/providers.dart';

/// Record types the history can be opened for. Must match HISTORY_ENTITIES
/// in masjid-core/src/common/audit/record-history.service.ts.
enum HistoryEntity {
  project('PROJECT'),
  projectContribution('PROJECT_CONTRIBUTION'),
  collectionContribution('COLLECTION_CONTRIBUTION'),
  salaryPayment('SALARY_PAYMENT'),
  salaryMonth('SALARY_MONTH'),
  collection('COLLECTION'),
  expense('EXPENSE');

  const HistoryEntity(this.value);

  final String value;
}

/// One record: which type and its id.
typedef HistoryTarget = ({HistoryEntity entity, String id});

/// `GET /audit-log/record/:entity/:id`: who added the record, who changed
/// or cancelled it, and when, oldest first.
class RecordHistory {
  const RecordHistory({
    required this.createdAt,
    required this.collectedByName,
    required this.events,
  });

  factory RecordHistory.fromJson(Map<String, dynamic> json) => RecordHistory(
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    collectedByName: json['collectedByName'] as String?,
    events: (json['events'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => HistoryEvent.fromJson(item as Map<String, dynamic>))
        .toList(),
  );

  /// When the record was saved, also for records older than the history.
  final DateTime createdAt;

  /// Who received the money, when that can differ from who entered it.
  final String? collectedByName;
  final List<HistoryEvent> events;

  /// False for records saved before the history was kept.
  bool get hasCreate => events.any((event) => event.action == 'CREATE');
}

class HistoryEvent {
  const HistoryEvent({
    required this.action,
    required this.actorName,
    required this.at,
    required this.changes,
  });

  factory HistoryEvent.fromJson(Map<String, dynamic> json) => HistoryEvent(
    action: json['action'] as String? ?? '',
    actorName: json['actorName'] as String? ?? '',
    at: DateTime.parse(json['at'] as String).toLocal(),
    changes: (json['changes'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => HistoryChange.fromJson(item as Map<String, dynamic>))
        .toList(),
  );

  /// CREATE, UPDATE or CANCEL.
  final String action;

  /// The person's name at the time, or 'system' for automatic entries.
  final String actorName;
  final DateTime at;
  final List<HistoryChange> changes;
}

/// One field that changed. [kind] is money, date, text or code (a type or
/// status value); [from] and [to] are numbers for money, ISO strings for
/// dates and plain strings otherwise.
class HistoryChange {
  const HistoryChange({
    required this.field,
    required this.kind,
    this.from,
    this.to,
  });

  factory HistoryChange.fromJson(Map<String, dynamic> json) => HistoryChange(
    field: json['field'] as String? ?? '',
    kind: json['kind'] as String? ?? 'text',
    from: json['from'],
    to: json['to'],
  );

  final String field;
  final String kind;
  final Object? from;
  final Object? to;
}

/// Loaded when the history button is tapped; dropped when the sheet closes,
/// so it is fresh every time.
final recordHistoryProvider = FutureProvider.autoDispose
    .family<RecordHistory, HistoryTarget>((ref, target) async {
      final data = await ref
          .watch(apiClientProvider)
          .get<Map<String, dynamic>>(
            '/audit-log/record/${target.entity.value}/${target.id}',
          );
      return RecordHistory.fromJson(data);
    });
