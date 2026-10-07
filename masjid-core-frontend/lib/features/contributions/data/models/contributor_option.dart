import 'package:freezed_annotation/freezed_annotation.dart';

part 'contributor_option.freezed.dart';
part 'contributor_option.g.dart';

/// A masjid member that can be picked as the contributor
/// (`GET /masjids/my/users`, only the fields this feature needs).
@freezed
abstract class ContributorOption with _$ContributorOption {
  const factory ContributorOption({
    required String id,
    @Default('') String fullName,
    String? phone,
  }) = _ContributorOption;

  factory ContributorOption.fromJson(Map<String, dynamic> json) =>
      _$ContributorOptionFromJson(json);
}
