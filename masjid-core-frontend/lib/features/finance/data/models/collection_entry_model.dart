import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection_entry_model.freezed.dart';
part 'collection_entry_model.g.dart';

/// A general collection (`/collections/my-masjid`).
@freezed
abstract class CollectionEntryModel with _$CollectionEntryModel {
  const CollectionEntryModel._();

  const factory CollectionEntryModel({
    required String id,
    required String type,
    required double amount,
    String? title,
    String? description,
    DateTime? collectedAt,

    /// ACTIVE or CANCELLED.
    @Default('ACTIVE') String status,
    DateTime? createdAt,
  }) = _CollectionEntryModel;

  factory CollectionEntryModel.fromJson(Map<String, dynamic> json) =>
      _$CollectionEntryModelFromJson(json);

  bool get isCancelled => status == 'CANCELLED';
}
