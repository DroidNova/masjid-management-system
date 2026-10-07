import 'package:freezed_annotation/freezed_annotation.dart';

part 'committee_member_input.freezed.dart';
part 'committee_member_input.g.dart';

/// One committee member in a masjid request (CommitteeMemberDto).
@freezed
abstract class CommitteeMemberInput with _$CommitteeMemberInput {
  const factory CommitteeMemberInput({
    required String name,
    required String phone,
    required String fatherName,
    required int age,
    required String gender,
  }) = _CommitteeMemberInput;

  factory CommitteeMemberInput.fromJson(Map<String, dynamic> json) =>
      _$CommitteeMemberInputFromJson(json);
}
