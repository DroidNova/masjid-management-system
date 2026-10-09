import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app's languages, in the order the language picker shows them.
/// Native names, so people find their own language without reading English.
enum AppLanguage {
  hindi('hi', 'हिन्दी'),
  urdu('ur', 'اردو'),
  english('en', 'English');

  const AppLanguage(this.code, this.nativeName);

  final String code;
  final String nativeName;

  Locale get locale => Locale(code);

  static AppLanguage? fromCode(String? code) {
    for (final language in values) {
      if (language.code == code) return language;
    }
    return null;
  }
}

/// Per-device preferences. Not tied to the account, so they also apply on
/// the login screens.
@immutable
class AppSettings {
  const AppSettings({
    this.language,
    this.largeText = false,
    this.readAloud = true,
  });

  /// Null until the person picks one; the app then follows the device
  /// language (falling back to English).
  final AppLanguage? language;

  /// Makes all text 20% bigger, on top of the device's own text size.
  final bool largeText;

  /// Shows the speaker buttons and reads success messages aloud.
  final bool readAloud;

  bool get hasChosenLanguage => language != null;

  AppSettings copyWith({
    AppLanguage? language,
    bool? largeText,
    bool? readAloud,
  }) => AppSettings(
    language: language ?? this.language,
    largeText: largeText ?? this.largeText,
    readAloud: readAloud ?? this.readAloud,
  );
}

/// Overridden in main.dart with the loaded instance, so settings are read
/// synchronously and the first frame already has the right language.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'Override sharedPreferencesProvider with SharedPreferences.getInstance()',
  ),
);

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

class AppSettingsController extends Notifier<AppSettings> {
  static const String _languageKey = 'settings.language';
  static const String _largeTextKey = 'settings.largeText';
  static const String _readAloudKey = 'settings.readAloud';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      language: AppLanguage.fromCode(prefs.getString(_languageKey)),
      largeText: prefs.getBool(_largeTextKey) ?? false,
      readAloud: prefs.getBool(_readAloudKey) ?? true,
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
    await _prefs.setString(_languageKey, language.code);
  }

  Future<void> setLargeText(bool value) async {
    state = state.copyWith(largeText: value);
    await _prefs.setBool(_largeTextKey, value);
  }

  Future<void> setReadAloud(bool value) async {
    state = state.copyWith(readAloud: value);
    await _prefs.setBool(_readAloudKey, value);
  }
}
