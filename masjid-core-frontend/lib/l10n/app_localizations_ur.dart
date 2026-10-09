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

  @override
  String get aboutMasjidOptional => 'مسجد کے بارے میں (اختیاری)';

  @override
  String get addMember => 'رکن شامل کریں';

  @override
  String get address => 'پتہ';

  @override
  String get age => 'عمر';

  @override
  String get appTagline => 'آپ کی مسجد کے نماز کے اوقات، خبریں اور حساب';

  @override
  String get changeCountry => 'ملک بدلیں';

  @override
  String get changeNumber => 'نمبر بدلیں';

  @override
  String get check => 'دیکھیں';

  @override
  String get cityOrVillage => 'شہر یا گاؤں';

  @override
  String get committeeHelp => 'وہ لوگ جو امام کے ساتھ مسجد چلائیں گے۔';

  @override
  String get committeeMissing => 'کم از کم ایک کمیٹی رکن شامل کریں۔';

  @override
  String get continueLabel => 'آگے بڑھیں';

  @override
  String get country => 'ملک';

  @override
  String get district => 'ضلع';

  @override
  String get duplicateCommitteePhone => 'دو کمیٹی ارکان کا فون نمبر ایک ہی ہے۔';

  @override
  String get edit => 'بدلیں';

  @override
  String get emailOptional => 'ای میل (اختیاری)';

  @override
  String get enterCode => 'کوڈ لکھیں';

  @override
  String get errorAccountInactive =>
      'یہ اکاؤنٹ بند ہے۔ براہ کرم اپنی مسجد کمیٹی سے بات کریں۔';

  @override
  String get errorCodeExpired => 'اس کوڈ کا وقت ختم ہو گیا۔ نیا کوڈ لیں۔';

  @override
  String get errorNoInternet =>
      'انٹرنیٹ نہیں ہے۔ کنکشن دیکھیں اور دوبارہ کوشش کریں۔';

  @override
  String get errorTooManyTries =>
      'بہت زیادہ کوششیں ہو گئیں۔ ایک منٹ رک کر دوبارہ کوشش کریں۔';

  @override
  String get errorWrongCode => 'کوڈ غلط ہے۔ دوبارہ کوشش کریں۔';

  @override
  String get errorWrongPassword => 'پاس ورڈ غلط ہے۔ دوبارہ کوشش کریں۔';

  @override
  String get fatherName => 'والد کا نام';

  @override
  String get fieldRequired => 'براہ کرم یہ بھریں۔';

  @override
  String get fullName => 'نام';

  @override
  String get gender => 'جنس';

  @override
  String get genderFemale => 'عورت';

  @override
  String get genderMale => 'مرد';

  @override
  String get genderOther => 'دیگر';

  @override
  String get hidePassword => 'پاس ورڈ چھپائیں';

  @override
  String get home => 'ہوم';

  @override
  String get imamIsCommitteeMember => 'امام کمیٹی کے رکن نہیں ہو سکتے۔';

  @override
  String get invalidAge => 'عمر 1 سے 120 کے درمیان ہونی چاہیے۔';

  @override
  String get invalidEmail => 'ای میل پتہ دیکھیں۔';

  @override
  String get invalidPhone => 'فون نمبر دیکھیں۔';

  @override
  String get login => 'لاگ ان';

  @override
  String get masjidName => 'مسجد کا نام';

  @override
  String get masjidPhoneOptional => 'مسجد کا فون (اختیاری)';

  @override
  String get newCodeSent => 'نیا کوڈ بھیج دیا گیا ہے۔';

  @override
  String get noRequestFound => 'اس نمبر سے کوئی درخواست نہیں ملی۔';

  @override
  String get password => 'پاس ورڈ';

  @override
  String get phoneAlreadyRegistered => 'فون نمبر پہلے سے درج ہے';

  @override
  String get phoneInAnotherMasjid => 'یہ نمبر پہلے سے کسی دوسری مسجد میں ہے۔';

  @override
  String get phoneNumber => 'فون نمبر';

  @override
  String get registerMasjid => 'مسجد درج کریں';

  @override
  String get removeMember => 'رکن ہٹائیں';

  @override
  String get requestSent => 'درخواست بھیج دی گئی';

  @override
  String get requestSentHelp =>
      'ہم تفصیلات دیکھیں گے۔ آپ کسی بھی وقت پیش رفت دیکھ سکتے ہیں۔';

  @override
  String get requesterHelp => 'آپ کی تفصیلات، تاکہ آپ درخواست دیکھ سکیں۔';

  @override
  String get reviewHelp => 'سب کچھ دیکھیں، پھر بھیجیں۔';

  @override
  String get searchCountry => 'ملک تلاش کریں';

  @override
  String get sendNewCode => 'نیا کوڈ بھیجیں';

  @override
  String get sendRequest => 'درخواست بھیجیں';

  @override
  String get showPassword => 'پاس ورڈ دکھائیں';

  @override
  String get state => 'ریاست';

  @override
  String get stepApproved => 'منظور';

  @override
  String get stepChecking => 'جانچ ہو رہی ہے';

  @override
  String get stepCommittee => 'کمیٹی';

  @override
  String get stepImam => 'امام';

  @override
  String get stepMasjid => 'مسجد';

  @override
  String get stepPlace => 'جگہ';

  @override
  String get stepRejected => 'منظور نہیں';

  @override
  String get stepReview => 'دیکھیں اور بھیجیں';

  @override
  String get stepSent => 'بھیج دی گئی';

  @override
  String get stepYou => 'آپ کے بارے میں';

  @override
  String get trackHelp => 'رجسٹریشن کے وقت دیا گیا فون نمبر لکھیں۔';

  @override
  String get trackRequest => 'درخواست دیکھیں';

  @override
  String get welcomeMessageOptional => 'خوش آمدید پیغام (اختیاری)';

  @override
  String get yourName => 'آپ کا نام';

  @override
  String get yourPassword => 'آپ کا پاس ورڈ';

  @override
  String get yourPhoneNumber => 'آپ کا فون نمبر';

  @override
  String codeSentTo(String phone) {
    return '$phone پر بھیجا گیا';
  }

  @override
  String memberNumber(int number) {
    return 'رکن $number';
  }

  @override
  String membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ارکان',
      one: '1 رکن',
    );
    return '$_temp0';
  }
}
