// freezed: @JsonSerializable on the factory configures the generated class.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_collection_request.freezed.dart';
part 'create_collection_request.g.dart';

/// Body of `POST /collections/my-masjid`. Null fields are left out.
@freezed
abstract class CreateCollectionRequest with _$CreateCollectionRequest {
  @JsonSerializable(includeIfNull: false)
  const factory CreateCollectionRequest({
    required String type,
    required double amount,
    String? title,
    String? description,

    /// `yyyy-MM-dd`.
    String? collectedAt,
  }) = _CreateCollectionRequest;

  factory CreateCollectionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCollectionRequestFromJson(json);
}
