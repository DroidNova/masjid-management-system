import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/network/api_client.dart';
import 'package:masjid_core_frontend/core/pagination/page.dart';
import 'package:masjid_core_frontend/core/providers.dart';
import 'package:masjid_core_frontend/features/announcements/data/models/announcement_model.dart';
import 'package:masjid_core_frontend/features/dashboard/data/models/namaz_time_summary.dart';

final publicMasjidApiProvider = Provider<PublicMasjidApi>(
  (ref) => PublicMasjidApi(ref.watch(apiClientProvider)),
);

/// A masjid's public page, loaded by its code. Works without login.
final publicMasjidPageProvider = FutureProvider.autoDispose
    .family<PublicMasjidPage, String>(
      (ref, code) => ref.watch(publicMasjidApiProvider).page(code),
    );

/// `/public/masjids`: what people outside a masjid may see, no login
/// needed (no token is sent when nobody is signed in).
class PublicMasjidApi {
  PublicMasjidApi(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PublicMasjid>> search(String text) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/public/masjids/search',
      query: <String, dynamic>{'q': text},
    );
    return (data['items'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => PublicMasjid.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<PublicMasjidPage> page(String code) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/public/masjids/${Uri.encodeComponent(code)}',
    );
    return PublicMasjidPage.fromJson(data);
  }

  Future<PageResult<AnnouncementModel>> announcements(
    String code, {
    required int page,
  }) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/public/masjids/${Uri.encodeComponent(code)}/announcements',
      query: <String, dynamic>{'page': page, 'limit': 20},
    );
    return PageResult.fromJson(data, _publicNews);
  }
}

/// Public news has no masjid id or audience; it is always public.
AnnouncementModel _publicNews(Map<String, dynamic> json) =>
    AnnouncementModel.fromJson(<String, dynamic>{...json, 'isPublic': true});

/// "k7m 2qx" → "K7M2QX" (the server accepts both; this keeps one form).
String normalizeMasjidCode(String input) =>
    input.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

/// "K7M2QX" → "K7M 2QX", easier to read out and type.
String displayMasjidCode(String code) =>
    code.length == 6 ? '${code.substring(0, 3)} ${code.substring(3)}' : code;

/// Name and place of a masjid, as anyone may see them.
class PublicMasjid {
  const PublicMasjid({
    required this.code,
    required this.name,
    this.locality,
    this.district,
    this.state,
    this.address,
  });

  factory PublicMasjid.fromJson(Map<String, dynamic> json) => PublicMasjid(
    code: json['publicCode'] as String? ?? json['code'] as String? ?? '',
    name: json['name'] as String? ?? '',
    locality: json['locality'] as String?,
    district: json['district'] as String?,
    state: json['state'] as String?,
    address: json['address'] as String?,
  );

  final String code;
  final String name;
  final String? locality;
  final String? district;
  final String? state;
  final String? address;

  /// "Barota, Sonipat, Haryana".
  String get place => <String?>[locality, district, state]
      .whereType<String>()
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .join(', ');

  /// What this device remembers about a followed masjid.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'code': code,
    'name': name,
    'locality': locality,
    'district': district,
    'state': state,
  };
}

class PublicMasjidPage {
  const PublicMasjidPage({
    required this.masjid,
    required this.latestNews,
    this.times,
  });

  factory PublicMasjidPage.fromJson(Map<String, dynamic> json) {
    final times = json['namazTime'];
    return PublicMasjidPage(
      masjid: PublicMasjid.fromJson(json),
      times: times is Map<String, dynamic>
          ? NamazTimeSummary.fromJson(times)
          : null,
      latestNews:
          (json['latestAnnouncements'] as List<dynamic>? ?? const <dynamic>[])
              .map((item) => _publicNews(item as Map<String, dynamic>))
              .toList(),
    );
  }

  final PublicMasjid masjid;
  final NamazTimeSummary? times;

  /// The newest public news (at most 5; the rest is on the news page).
  final List<AnnouncementModel> latestNews;

  static const int latestCount = 5;
}
