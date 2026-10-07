// freezed: @JsonSerializable on the factory configures the generated class.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_expense_request.freezed.dart';
part 'create_expense_request.g.dart';

/// Body of `POST /expenses/my-masjid`. Null fields are left out.
@freezed
abstract class CreateExpenseRequest with _$CreateExpenseRequest {
  @JsonSerializable(includeIfNull: false)
  const factory CreateExpenseRequest({
    required String type,
    required double amount,
    String? title,
    String? description,

    /// `yyyy-MM-dd`.
    String? spentAt,
  }) = _CreateExpenseRequest;

  factory CreateExpenseRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateExpenseRequestFromJson(json);
}
