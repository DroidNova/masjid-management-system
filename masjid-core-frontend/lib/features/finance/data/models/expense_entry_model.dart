import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_entry_model.freezed.dart';
part 'expense_entry_model.g.dart';

/// An expense (`/expenses/my-masjid`).
@freezed
abstract class ExpenseEntryModel with _$ExpenseEntryModel {
  const ExpenseEntryModel._();

  const factory ExpenseEntryModel({
    required String id,
    required String type,
    required double amount,
    String? title,
    String? description,
    DateTime? spentAt,

    /// ACTIVE or CANCELLED.
    @Default('ACTIVE') String status,
    DateTime? createdAt,
  }) = _ExpenseEntryModel;

  factory ExpenseEntryModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseEntryModelFromJson(json);

  bool get isCancelled => status == 'CANCELLED';
}
