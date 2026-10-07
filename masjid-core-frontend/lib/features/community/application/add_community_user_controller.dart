import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/community/data/community_repository.dart';
import 'package:masjid_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:masjid_core_frontend/features/community/data/models/create_community_user_request.dart';

final addCommunityUserControllerProvider =
    NotifierProvider.autoDispose<
      AddCommunityUserController,
      AsyncValue<CommunityUserModel?>
    >(AddCommunityUserController.new);

/// Creates a masjid user. State: data(null) idle, loading while saving,
/// data(user) after success, error with the ApiException on failure.
class AddCommunityUserController
    extends AutoDisposeNotifier<AsyncValue<CommunityUserModel?>> {
  @override
  AsyncValue<CommunityUserModel?> build() => const AsyncData(null);

  /// Returns the created user, or null when it failed (see [state]).
  Future<CommunityUserModel?> submit(CreateCommunityUserRequest request) async {
    if (state.isLoading) return null;
    // Finish (and mark changes) even if the screen closes meanwhile.
    final keepAlive = ref.keepAlive();
    try {
      state = const AsyncLoading();
      final result = await AsyncValue.guard(
        () => ref.read(communityRepositoryProvider).createMasjidUser(request),
      );
      state = result;
      if (result.hasError) return null;
      ref.markChanged(const <DataScope>[
        DataScope.members,
        DataScope.dashboard,
      ]);
      return result.value;
    } finally {
      keepAlive.close();
    }
  }
}

/// Builds the request from form text: trims, drops empty optional fields.
CreateCommunityUserRequest buildCreateCommunityUserRequest({
  required String fullName,
  required String phone,
  required String email,
  required String role,
  required String fatherName,
  required String age,
  required String gender,
  required bool isFamilyHead,
  required String familyMemberCount,
  required String masjidId,
}) {
  final isMember = role == PermissionHelper.member;
  final count = familyMemberCount.trim();
  return CreateCommunityUserRequest(
    fullName: fullName.trim(),
    phone: phone.trim(),
    email: _emptyToNull(email),
    role: role,
    fatherName: fatherName.trim(),
    age: int.parse(age.trim()),
    gender: gender,
    isFamilyHead: isMember ? isFamilyHead : null,
    familyMemberCount: isMember && isFamilyHead && count.isNotEmpty
        ? int.parse(count)
        : null,
    masjidId: _emptyToNull(masjidId),
  );
}

/// Text for the "User Added" dialog.
String addUserSuccessMessage(CommunityUserModel user, String? role) {
  final message = user.message;
  if (message != null && message.isNotEmpty) return message;
  final password = user.temporaryPassword;
  if (password != null && password.isNotEmpty) {
    return 'User added successfully. Temporary password is $password.';
  }
  if (role == PermissionHelper.member) {
    return 'Member added successfully. This user can login using phone OTP.';
  }
  return 'User added successfully.';
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
