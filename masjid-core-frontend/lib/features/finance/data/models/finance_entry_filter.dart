import 'package:freezed_annotation/freezed_annotation.dart';

part 'finance_entry_filter.freezed.dart';

/// Filters for the collections and expenses lists (query parameters of
/// `GET /collections/my-masjid` and `GET /expenses/my-masjid`).
@freezed
abstract class FinanceEntryFilter with _$FinanceEntryFilter {
  const FinanceEntryFilter._();

  const factory FinanceEntryFilter({
    String? type,

    /// ACTIVE or CANCELLED; null shows both.
    String? status,
    String? search,
    DateTime? fromDate,
    DateTime? toDate,
  }) = _FinanceEntryFilter;

  Map<String, dynamic> toQuery() => <String, dynamic>{
    if (type != null) 'type': type,
    if (status != null) 'status': status,
    if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
    if (fromDate != null) 'fromDate': fromDate!.toUtc().toIso8601String(),
    if (toDate != null) 'toDate': toDate!.toUtc().toIso8601String(),
  };
}
