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

/// Users with an edit or status change in flight (their buttons are off).
final communityBusyUserIdsProvider = StateProvider<Set<String>>(
  (ref) => const <String>{},
);

typedef _Inputs = ({String? userId, int members, int masjid});

/// Loads the masjid profile and its users; edits users.
class CommunityController extends AutoDisposeAsyncNotifier<CommunityData> {
  _Inputs? _inputs;
  CommunityData? _latest;

  /// Inputs right after this controller's own `members` bump: that rebuild
  /// keeps [_latest] (already updated in place) instead of fetching again.
  _Inputs? _ownChange;

  @override
  Future<CommunityData> build() async {
    final inputs = (
      userId: ref.watch(currentUserProvider.select((user) => user?.id)),
      members: ref.watch(dataVersionProvider(DataScope.members)),
      masjid: ref.watch(dataVersionProvider(DataScope.masjid)),
    );
    _inputs = inputs;
    final ownChange = _ownChange;
    _ownChange = null;
    final latest = _latest;
    if (latest != null && inputs == ownChange) return latest;

    final repository = ref.watch(communityRepositoryProvider);
    final results = await Future.wait<Object>(<Future<Object>>[
      repository.getMyMasjid(),
      repository.getMyMasjidUsers(),
    ]);
    return _latest = CommunityData(
      masjid: results[0] as MasjidDetailModel,
      users: results[1] as List<CommunityUserModel>,
    );
  }

  /// Pull-to-refresh: keeps showing the current data while reloading.
  Future<void> refresh() async {
    _ownChange = null;
    ref.invalidateSelf();
    await future;
  }

  /// Throws ApiException on failure; the screen shows it.
  Future<void> updateUser(String userId, UpdateCommunityUserRequest request) =>
      _change(
        userId,
        () => ref
            .read(communityRepositoryProvider)
            .updateMasjidUser(userId, request),
      );

  /// Throws ApiException on failure; the screen shows it.
  Future<void> changeUserStatus(String userId, String status) => _change(
    userId,
    () => ref
        .read(communityRepositoryProvider)
        .updateMasjidUserStatus(userId, status),
  );

  Future<void> _change(
    String userId,
    Future<CommunityUserModel> Function() request,
  ) async {
    final busy = ref.read(communityBusyUserIdsProvider.notifier);
    if (busy.state.contains(userId)) return;
    busy.state = <String>{...busy.state, userId};
    // Finish (and mark changes) even if the screen closes meanwhile.
    final keepAlive = ref.keepAlive();
    try {
      final updated = await request();
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData(_latest = current.replaceUser(updated));
      }
      // Other screens (dashboard counts, contributor pickers) reload; this
      // one already shows the change, so its own rebuild skips the fetch.
      final inputs = _inputs;
      if (inputs != null) {
        _ownChange = (
          userId: inputs.userId,
          members: inputs.members + 1,
          masjid: inputs.masjid,
        );
      }
      ref.markChanged(const <DataScope>[
        DataScope.dashboard,
        DataScope.members,
      ]);
    } finally {
      busy.state = <String>{...busy.state}..remove(userId);
      keepAlive.close();
    }
  }
}
