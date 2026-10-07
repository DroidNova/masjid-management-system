import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/refresh/data_scopes.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';
import 'package:masjid_core_frontend/features/community/data/community_repository.dart';
import 'package:masjid_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:masjid_core_frontend/features/community/data/models/masjid_detail_model.dart';
import 'package:masjid_core_frontend/features/community/data/models/update_community_user_request.dart';

/// What the community screen shows: the masjid and its users, grouped.
class CommunityData {
  const CommunityData({required this.masjid, required this.users});

  final MasjidDetailModel masjid;
  final List<CommunityUserModel> users;

  /// Masjid admins and committee members.
  List<CommunityUserModel> get committeeUsers => users
      .where((user) => user.isMasjidAdmin || user.isCommitteeMember)
      .toList();

  /// Imams who are not also on the committee.
  List<CommunityUserModel> get imamUsers => users
      .where(
        (user) => user.isImam && !user.isMasjidAdmin && !user.isCommitteeMember,
      )
      .toList();

  /// Everyone not listed as committee or imam.
  List<CommunityUserModel> get memberUsers {
    final groupedIds = <String>{
      ...committeeUsers.map((user) => user.id),
      ...imamUsers.map((user) => user.id),
    };
    return users.where((user) => !groupedIds.contains(user.id)).toList();
  }

  CommunityData replaceUser(CommunityUserModel updated) => CommunityData(
    masjid: masjid,
    users: users.map((user) => user.id == updated.id ? updated : user).toList(),
  );
}

final communityControllerProvider =
    AsyncNotifierProvider.autoDispose<CommunityController, CommunityData>(
      CommunityController.new,
    );

/// Loads the masjid profile and its users; edits users.
class CommunityController extends AutoDisposeAsyncNotifier<CommunityData> {
  @override
  Future<CommunityData> build() async {
    ref.watch(currentUserProvider.select((user) => user?.id));
    ref.watch(dataVersionProvider(DataScope.members));
    ref.watch(dataVersionProvider(DataScope.masjid));

    final repository = ref.watch(communityRepositoryProvider);
    final results = await Future.wait<Object>(<Future<Object>>[
      repository.getMyMasjid(),
      repository.getMyMasjidUsers(),
    ]);
    return CommunityData(
      masjid: results[0] as MasjidDetailModel,
      users: results[1] as List<CommunityUserModel>,
    );
  }

  /// Pull-to-refresh: keeps showing the current data while reloading.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Throws ApiException on failure; the screen shows it.
  Future<void> updateUser(
    String userId,
    UpdateCommunityUserRequest request,
  ) async {
    final updated = await ref
        .read(communityRepositoryProvider)
        .updateMasjidUser(userId, request);
    _replace(updated);
  }

  /// Throws ApiException on failure; the screen shows it.
  Future<void> changeUserStatus(String userId, String status) async {
    final updated = await ref
        .read(communityRepositoryProvider)
        .updateMasjidUserStatus(userId, status);
    _replace(updated);
  }

  void _replace(CommunityUserModel updated) {
    final current = state.valueOrNull;
    if (current != null) state = AsyncData(current.replaceUser(updated));
    ref.markChanged(const <DataScope>[DataScope.members, DataScope.dashboard]);
  }
}
