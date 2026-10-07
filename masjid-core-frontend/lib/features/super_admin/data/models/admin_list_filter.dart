import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_list_filter.freezed.dart';

/// Search and filters of an admin list. Empty values are not sent.
@freezed
abstract class AdminListFilter with _$AdminListFilter {
  const factory AdminListFilter({
    @Default('') String search,
    String? status,

    /// Users list only.
    String? role,
  }) = _AdminListFilter;
}
