import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/pagination/paged_controller.dart';
import 'package:masjid_core_frontend/core/pagination/paged_family_controller.dart';
import 'package:masjid_core_frontend/core/settings/app_settings.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/visit/data/public_masjid_api.dart';

/// Masjids followed on this phone, newest first. Kept only on the device
/// (no account needed, nothing sent to the server), so a visitor without
/// login keeps them, and they stay after logging in or out.
final followedMasjidsProvider =
    NotifierProvider<FollowedMasjidsController, List<PublicMasjid>>(
      FollowedMasjidsController.new,
    );

class FollowedMasjidsController extends Notifier<List<PublicMasjid>> {
  static const String _key = 'visit.followedMasjids';

  @override
  List<PublicMasjid> build() {
    final stored = ref.watch(sharedPreferencesProvider).getString(_key);
    if (stored == null) return const <PublicMasjid>[];
    try {
      return (jsonDecode(stored) as List<dynamic>)
          .map((item) => PublicMasjid.fromJson(item as Map<String, dynamic>))
          .where((masjid) => masjid.code.isNotEmpty)
          .toList();
    } on Object {
      return const <PublicMasjid>[];
    }
  }

  bool isFollowing(String code) => state.any((masjid) => masjid.code == code);

  Future<void> follow(PublicMasjid masjid) => _save(<PublicMasjid>[
    masjid,
    ...state.where((other) => other.code != masjid.code),
  ]);

  Future<void> unfollow(String code) =>
      _save(state.where((masjid) => masjid.code != code).toList());

  Future<void> _save(List<PublicMasjid> masjids) async {
    state = masjids;
    await ref
        .read(sharedPreferencesProvider)
        .setString(
          _key,
          jsonEncode(masjids.map((masjid) => masjid.toJson()).toList()),
        );
  }
}

/// All public news of one masjid (the "More news" page).
final publicNewsProvider = AsyncNotifierProvider.autoDispose
    .family<PublicNewsController, PagedState<AnnouncementModel>, String>(
      PublicNewsController.new,
    );

class PublicNewsController
    extends PagedFamilyController<AnnouncementModel, String> {
  @override
  Future<PageResult<AnnouncementModel>> fetchPage(String code, int page) =>
      ref.read(publicMasjidApiProvider).announcements(code, page: page);
}
