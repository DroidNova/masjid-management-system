// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Masjid Core';

  @override
  String get loading => 'लोड हो रहा है…';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get notAllowedTitle => 'अनुमति नहीं';

  @override
  String get notAllowedMessage => 'आपको यह काम करने की अनुमति नहीं है।';

  @override
  String get sessionExpired =>
      'आपका सत्र खत्म हो गया। कृपया फिर से लॉग इन करें।';

  @override
  String get noMasjidAssigned => 'आप अभी किसी मस्जिद से जुड़े नहीं हैं।';

  @override
  String get dashboardLoadFailed => 'होम पेज लोड नहीं हो सका';

  @override
  String get next => 'आगे';

  @override
  String get back => 'पीछे';

  @override
  String get done => 'हो गया';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get ok => 'ठीक है';

  @override
  String get save => 'सहेजें';

  @override
  String get close => 'बंद करें';

  @override
  String get search => 'खोजें';

  @override
  String get today => 'आज';

  @override
  String get yesterday => 'कल';

  @override
  String get pickDate => 'तारीख चुनें';

  @override
  String get readAloud => 'सुनें';

  @override
  String get stopReading => 'रोकें';

  @override
  String get pleaseWait => 'कृपया रुकें…';

  @override
  String get somethingWentWrong => 'कुछ गड़बड़ हो गई';

  @override
  String get tryAgain => 'फिर कोशिश करें';

  @override
  String get nothingFound => 'कुछ नहीं मिला';

  @override
  String get searchPeople => 'नाम या फ़ोन से खोजें';

  @override
  String get amountHint => 'रकम डालें';

  @override
  String get deleteDigit => 'मिटाएँ';

  @override
  String get pressAndHold => 'दबाकर रखें';

  @override
  String holdTo(String action) {
    return '$action के लिए दबाकर रखें';
  }

  @override
  String stepOf(int current, int total) {
    return 'चरण $current / $total';
  }

  @override
  String get chooseLanguage => 'भाषा चुनें';

  @override
  String get largeText => 'बड़े अक्षर';
}
