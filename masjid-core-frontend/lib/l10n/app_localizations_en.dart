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

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get search => 'Search';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get pickDate => 'Pick date';

  @override
  String get readAloud => 'Read aloud';

  @override
  String get stopReading => 'Stop';

  @override
  String get pleaseWait => 'Please wait…';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get tryAgain => 'Try again';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get searchPeople => 'Search by name or phone';

  @override
  String get amountHint => 'Enter amount';

  @override
  String get deleteDigit => 'Delete';

  @override
  String get pressAndHold => 'Press and hold';

  @override
  String holdTo(String action) {
    return 'Hold to $action';
  }

  @override
  String stepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get largeText => 'Large text';
}
