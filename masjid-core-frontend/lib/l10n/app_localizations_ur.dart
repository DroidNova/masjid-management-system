// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'Masjid Core';

  @override
  String get loading => 'لوڈ ہو رہا ہے…';

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String get logout => 'لاگ آؤٹ';

  @override
  String get notAllowedTitle => 'اجازت نہیں';

  @override
  String get notAllowedMessage => 'آپ کو یہ کام کرنے کی اجازت نہیں ہے۔';

  @override
  String get sessionExpired =>
      'آپ کا سیشن ختم ہو گیا۔ براہ کرم دوبارہ لاگ ان کریں۔';

  @override
  String get noMasjidAssigned => 'آپ ابھی کسی مسجد سے منسلک نہیں ہیں۔';

  @override
  String get dashboardLoadFailed => 'ہوم پیج لوڈ نہیں ہو سکا';

  @override
  String get next => 'آگے';

  @override
  String get back => 'پیچھے';

  @override
  String get done => 'ہو گیا';

  @override
  String get cancel => 'منسوخ کریں';

  @override
  String get ok => 'ٹھیک ہے';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get close => 'بند کریں';

  @override
  String get search => 'تلاش کریں';

  @override
  String get today => 'آج';

  @override
  String get yesterday => 'کل';

  @override
  String get pickDate => 'تاریخ چنیں';

  @override
  String get readAloud => 'سنیں';

  @override
  String get stopReading => 'روکیں';

  @override
  String get pleaseWait => 'براہ کرم انتظار کریں…';

  @override
  String get somethingWentWrong => 'کچھ غلط ہو گیا';

  @override
  String get tryAgain => 'دوبارہ کوشش کریں';

  @override
  String get nothingFound => 'کچھ نہیں ملا';

  @override
  String get searchPeople => 'نام یا فون سے تلاش کریں';

  @override
  String get amountHint => 'رقم لکھیں';

  @override
  String get deleteDigit => 'مٹائیں';

  @override
  String get pressAndHold => 'دبا کر رکھیں';

  @override
  String holdTo(String action) {
    return '$action کے لیے دبا کر رکھیں';
  }

  @override
  String stepOf(int current, int total) {
    return 'مرحلہ $current / $total';
  }

  @override
  String get chooseLanguage => 'زبان چنیں';

  @override
  String get largeText => 'بڑے حروف';
}
