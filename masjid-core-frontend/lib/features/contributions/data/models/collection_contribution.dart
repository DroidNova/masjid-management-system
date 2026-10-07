import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection_contribution.freezed.dart';
part 'collection_contribution.g.dart';

/// One general collection contribution (`/collections/contributions` and
/// `/contributions/my/collections`).
@freezed
abstract class CollectionContribution with _$CollectionContribution {
  const factory CollectionContribution({
    required String id,
    @Default('') String collectionType,
    @Default('') String contributorName,
    String? contributorPhone,
    @Default(0) double amount,
    @Default('') String paymentMode,
    DateTime? paidAt,
    @Default('') String collectedByName,
    String? note,
  }) = _CollectionContribution;

  factory CollectionContribution.fromJson(Map<String, dynamic> json) =>
      _$CollectionContributionFromJson(json);
}
