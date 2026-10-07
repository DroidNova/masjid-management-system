// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Masjid Core';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Retry';

  @override
  String get logout => 'Logout';

  @override
  String get notAllowedTitle => 'Not allowed';

  @override
  String get notAllowedMessage =>
      'You do not have permission to perform this action.';

  @override
  String get sessionExpired => 'Your session has expired. Please login again.';

  @override
  String get noMasjidAssigned => 'You are not assigned to any masjid yet.';

  @override
  String get dashboardLoadFailed => 'Unable to load dashboard';
}
