import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/settings/app_settings.dart';
import 'package:masjid_core_frontend/features/auth/application/auth_controller.dart';

/// When this person last opened the news, on this device. News newer than
/// this shows a "New" mark and counts on the Home News tile. Null before
/// the first look. Stored per user, so a shared phone keeps them apart.
final newsLastSeenProvider =
    NotifierProvider<NewsLastSeenController, DateTime?>(
      NewsLastSeenController.new,
    );

class NewsLastSeenController extends Notifier<DateTime?> {
  String? get _key {
    final userId = ref.read(currentUserProvider)?.id;
    return userId == null ? null : 'news.lastSeen.$userId';
  }

  @override
  DateTime? build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    final key = _key;
    if (key == null) return null;
    final stored = ref.watch(sharedPreferencesProvider).getString(key);
    return stored == null ? null : DateTime.tryParse(stored);
  }

  /// Remembers [newest] (the newest item shown) as seen. Never goes back.
  Future<void> markSeen(DateTime newest) async {
    final key = _key;
    final current = state;
    if (key == null || (current != null && !newest.isAfter(current))) return;
    state = newest;
    await ref
        .read(sharedPreferencesProvider)
        .setString(key, newest.toUtc().toIso8601String());
  }
}

/// True when [createdAt] is newer than [lastSeen]. Before the first look
/// ([lastSeen] null) everything counts as new.
bool isNewNews(DateTime? createdAt, DateTime? lastSeen) {
  if (createdAt == null) return false;
  return lastSeen == null || createdAt.isAfter(lastSeen);
}
