// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'مسجد';

  @override
  String get loading => 'لوڈ ہو رہا ہے…';

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

  @override
  String get account => 'اکاؤنٹ';

  @override
  String get changePassword => 'پاس ورڈ بدلیں';

  @override
  String get changePasswordHelp =>
      'آپ کے دوسرے فون اور کمپیوٹر سے لاگ آؤٹ ہو جائے گا۔';

  @override
  String get changeTimes => 'اوقات بدلیں';

  @override
  String get currentPassword => 'موجودہ پاس ورڈ';

  @override
  String get errorSamePassword => 'نیا پاس ورڈ پرانے جیسا ہی ہے۔';

  @override
  String get errorWrongCurrentPassword => 'موجودہ پاس ورڈ غلط ہے۔';

  @override
  String get familyHead => 'گھر کے سربراہ';

  @override
  String get latestNews => 'تازہ خبر';

  @override
  String get leave => 'چھوڑیں';

  @override
  String get leaveMasjid => 'مسجد چھوڑیں';

  @override
  String get leaveMasjidQuestion => 'مسجد چھوڑنا چاہتے ہیں؟';

  @override
  String get leavePointAccess =>
      'آپ اس مسجد کے اوقات، خبریں اور حساب نہیں دیکھ سکیں گے۔';

  @override
  String get leavePointHistory => 'آپ کی ادائیگی کا ریکارڈ مسجد کے پاس رہے گا۔';

  @override
  String get leavePointJoin =>
      'چھوڑنے کے بعد کوئی دوسری مسجد آپ کو شامل کر سکتی ہے۔';

  @override
  String get logoutQuestion => 'لاگ آؤٹ کریں؟';

  @override
  String get masjidBalance => 'مسجد کا بیلنس';

  @override
  String get memberSince => 'رکن کب سے';

  @override
  String get moneyIn => 'رقم آئی';

  @override
  String get moneyOut => 'رقم گئی';

  @override
  String get namazTimesNotSet => 'نماز کے اوقات ابھی طے نہیں ہوئے۔';

  @override
  String get newPassword => 'نیا پاس ورڈ';

  @override
  String get nextNamaz => 'اگلی نماز';

  @override
  String get notVerified => 'تصدیق نہیں ہوئی';

  @override
  String get passwordChanged => 'پاس ورڈ بدل گیا';

  @override
  String get passwordsDiffer => 'دونوں پاس ورڈ ایک جیسے نہیں ہیں۔';

  @override
  String get prayerAsr => 'عصر';

  @override
  String get prayerFajr => 'فجر';

  @override
  String get prayerIsha => 'عشاء';

  @override
  String get prayerJumma => 'جمعہ';

  @override
  String get prayerMaghrib => 'مغرب';

  @override
  String get prayerZuhr => 'ظہر';

  @override
  String get repeatNewPassword => 'نیا پاس ورڈ دوبارہ';

  @override
  String get roleCommittee => 'کمیٹی';

  @override
  String get roleImam => 'امام';

  @override
  String get roleMember => 'رکن';

  @override
  String get roleSuperAdmin => 'سپر ایڈمن';

  @override
  String get salary => 'تنخواہ';

  @override
  String get seeAll => 'سب دیکھیں';

  @override
  String get setTimes => 'اوقات طے کریں';

  @override
  String get statusActive => 'فعال';

  @override
  String get statusInactive => 'بند';

  @override
  String get statusPending => 'زیرِ التوا';

  @override
  String get superAdmin => 'سپر ایڈمن';

  @override
  String get tabDashboard => 'ڈیش بورڈ';

  @override
  String get tabHome => 'ہوم';

  @override
  String get tabMasjids => 'مساجد';

  @override
  String get tabMoney => 'رقم';

  @override
  String get tabMyPayments => 'میری ادائیگی';

  @override
  String get tabNews => 'خبریں';

  @override
  String get tabPeople => 'لوگ';

  @override
  String get tabProfile => 'پروفائل';

  @override
  String get tabProjects => 'کام';

  @override
  String get tabRequests => 'درخواستیں';

  @override
  String get tabTimes => 'اوقات';

  @override
  String get tabUsers => 'صارفین';

  @override
  String get thisMonth => 'اس مہینے';

  @override
  String get verified => 'تصدیق شدہ';

  @override
  String get youLeftTheMasjid => 'آپ نے مسجد چھوڑ دی';

  @override
  String inHoursMinutes(int hours, int minutes) {
    return '$hours گھنٹے $minutes منٹ میں';
  }

  @override
  String inMinutes(int minutes) {
    return '$minutes منٹ میں';
  }

  @override
  String nextNamazSpoken(String prayer, String time, String countdown) {
    return 'اگلی نماز: $prayer، $time بجے، $countdown';
  }

  @override
  String passwordTooShort(int count) {
    return 'کم از کم $count حروف یا ہندسے رکھیں۔';
  }

  @override
  String youLeft(String masjid) {
    return 'آپ نے $masjid چھوڑ دی';
  }

  @override
  String get addFirstNews => 'پہلی خبر شامل کریں';

  @override
  String get addNews => 'خبر شامل کریں';

  @override
  String get changed => 'بدلا گیا';

  @override
  String get delete => 'حذف کریں';

  @override
  String get deleteNewsPoint => 'یہ خبر اب کسی کو نظر نہیں آئے گی۔';

  @override
  String get deleteNewsQuestion => 'یہ خبر حذف کریں؟';

  @override
  String get dictationTip =>
      'مشورہ: لکھنے کے بجائے بولنے کے لیے کی بورڈ پر مائیک دبائیں۔';

  @override
  String get editNews => 'خبر بدلیں';

  @override
  String get friday => 'جمعہ کا دن';

  @override
  String get leaveWithoutSaving => 'محفوظ کیے بغیر جائیں؟';

  @override
  String get leaveWithoutSavingConfirm => 'جائیں';

  @override
  String get minusFiveMinutes => '5 منٹ پہلے';

  @override
  String get newLabel => 'نئی';

  @override
  String get newsDeleted => 'خبر حذف ہو گئی';

  @override
  String get newsLoadFailed => 'خبریں لوڈ نہیں ہو سکیں';

  @override
  String get newsMessage => 'پیغام';

  @override
  String get newsPublished => 'خبر لگ گئی';

  @override
  String get newsTitle => 'عنوان';

  @override
  String get noNewsYet => 'ابھی کوئی خبر نہیں';

  @override
  String get noteOptional => 'نوٹ (اختیاری)';

  @override
  String get plusFiveMinutes => '5 منٹ بعد';

  @override
  String get readMore => 'مزید پڑھیں';

  @override
  String get saved => 'محفوظ ہو گیا';

  @override
  String get setTime => 'وقت چنیں';

  @override
  String get showLess => 'کم دکھائیں';

  @override
  String get timesSaved => 'اوقات محفوظ ہو گئے';

  @override
  String get addGiver => 'دینے والا شامل کریں';

  @override
  String get addNote => 'نوٹ شامل کریں';

  @override
  String get all => 'سب';

  @override
  String get cancelEntry => 'اندراج منسوخ کریں';

  @override
  String get cancelEntryPoint =>
      'یہ رقم مسجد کے حساب سے نکل جائے گی۔ اندراج فہرست میں منسوخ کے نشان کے ساتھ رہے گا۔';

  @override
  String get cancelEntryQuestion => 'یہ اندراج منسوخ کریں؟';

  @override
  String get cancelled => 'منسوخ';

  @override
  String get catCleaning => 'صفائی';

  @override
  String get catConstruction => 'تعمیر';

  @override
  String get catConstructionFund => 'تعمیراتی فنڈ';

  @override
  String get catDonationBox => 'چندہ بکس';

  @override
  String get catElectricity => 'بجلی';

  @override
  String get catImamSalary => 'امام کی تنخواہ';

  @override
  String get catJumma => 'جمعہ';

  @override
  String get catOther => 'دیگر';

  @override
  String get catRamadanFund => 'رمضان فنڈ';

  @override
  String get catRepair => 'مرمت';

  @override
  String get catSadaqah => 'صدقہ';

  @override
  String get catWater => 'پانی';

  @override
  String get catZakat => 'زکوٰۃ';

  @override
  String get givers => 'دینے والے';

  @override
  String get howMuch => 'کتنا؟';

  @override
  String get moneyInSaved => 'آئی رقم محفوظ ہو گئی';

  @override
  String get moneyLoadFailed => 'رقم کا حساب لوڈ نہیں ہو سکا۔';

  @override
  String get moneyOutSaved => 'گئی رقم محفوظ ہو گئی';

  @override
  String get noGiversYet => 'ابھی کوئی دینے والا نہیں';

  @override
  String get noMoneyInYet => 'ابھی کوئی رقم نہیں آئی';

  @override
  String get noMoneyOutYet => 'ابھی کوئی رقم نہیں گئی';

  @override
  String get nothingMatches => 'کچھ نہیں ملا';

  @override
  String get payCash => 'نقد';

  @override
  String get payOnline => 'آن لائن';

  @override
  String get phoneOptional => 'فون (اختیاری)';

  @override
  String get pickAnother => 'کوئی اور چنیں';

  @override
  String get pickMember => 'رکن چنیں';

  @override
  String get someoneElse => 'رکن نہیں ہیں';

  @override
  String get whatFor => 'کس لیے؟';

  @override
  String get whatKind => 'کس قسم کا؟';

  @override
  String get whoGave => 'کس نے دیا؟';

  @override
  String get aboutProjectOptional => 'کام کے بارے میں (اختیاری)';

  @override
  String get addFirstProject => 'پہلا کام شامل کریں';

  @override
  String get addProject => 'کام شامل کریں';

  @override
  String get amountPerFamilyHelp => 'اس مہینے ہر خاندان کتنا دے گا۔';

  @override
  String get cancelProject => 'کام منسوخ کریں';

  @override
  String get cancelProjectPoint => 'کام رک جائے گا۔ دی گئی رقم درج رہے گی۔';

  @override
  String get cancelProjectQuestion => 'یہ کام منسوخ کریں؟';

  @override
  String get collected => 'جمع ہوا';

  @override
  String get datesAndStatus => 'تاریخیں اور حالت';

  @override
  String get due => 'باقی';

  @override
  String get editProject => 'کام بدلیں';

  @override
  String get endDate => 'اختتام';

  @override
  String get endDateOptional => 'ختم ہونے کی تاریخ (اختیاری)';

  @override
  String get families => 'خاندان';

  @override
  String get moneyNeeded => 'کتنی رقم چاہیے';

  @override
  String get moneyNeededHelp =>
      'کام کے لیے کل رقم۔ معلوم نہ ہو تو خالی چھوڑیں۔';

  @override
  String get mySalary => 'میری تنخواہ ادائیگی';

  @override
  String get noFamiliesYet => 'ابھی کوئی خاندان نہیں';

  @override
  String get noPaymentsYet => 'ابھی کوئی ادائیگی نہیں';

  @override
  String get noProjectsYet => 'ابھی کوئی کام نہیں';

  @override
  String get noSalaryHistory => 'ابھی کوئی تنخواہ ادائیگی نہیں';

  @override
  String get payments => 'ادائیگیاں';

  @override
  String get projectAdded => 'کام شامل ہو گیا';

  @override
  String get projectCancelled => 'منسوخ';

  @override
  String get projectCancelledDone => 'کام منسوخ ہو گیا';

  @override
  String get projectCompleted => 'مکمل';

  @override
  String get projectName => 'کام کا نام';

  @override
  String get projectOngoing => 'جاری';

  @override
  String get projectPlanned => 'منصوبے میں';

  @override
  String get raiseAmount => 'رقم بڑھائیں';

  @override
  String get salaryMonthStarted => 'تنخواہ کا مہینہ شروع ہوا';

  @override
  String get salaryNotPaid => 'نہیں دیا';

  @override
  String get salaryNotStarted => 'اس مہینے کی تنخواہ شروع نہیں ہوئی';

  @override
  String get salaryPaid => 'دے دیا';

  @override
  String get salaryPartlyPaid => 'کچھ دیا';

  @override
  String get salaryPaymentSaved => 'ادائیگی محفوظ ہو گئی';

  @override
  String get searchProjects => 'کام تلاش کریں';

  @override
  String get startDate => 'شروع';

  @override
  String get startDateOptional => 'شروع کی تاریخ (اختیاری)';

  @override
  String get startSalaryMonth => 'مہینہ شروع کریں';

  @override
  String get status => 'حالت';

  @override
  String amountCanOnlyGoUp(String amount) {
    return 'رقم صرف بڑھ سکتی ہے (ابھی $amount)۔';
  }

  @override
  String collectedOf(String collected, String target) {
    return '$target میں سے $collected';
  }

  @override
  String collectedSoFar(String amount) {
    return '$amount جمع ہوئے';
  }

  @override
  String notPaidCount(int count) {
    return '$count نے نہیں دیا';
  }

  @override
  String outOf(String amount) {
    return '$amount میں سے';
  }

  @override
  String paidCount(int count) {
    return '$count نے دیا';
  }

  @override
  String paidOutOf(String paid, String expected) {
    return '$expected میں سے $paid دیا';
  }

  @override
  String partlyPaidCount(int count) {
    return '$count نے کچھ دیا';
  }

  @override
  String payMoreThanDue(String amount) {
    return 'یہ باقی رقم ($amount) سے زیادہ ہے۔';
  }

  @override
  String perFamily(String amount) {
    return 'ہر خاندان $amount';
  }

  @override
  String salarySpoken(String collected, String expected, String due) {
    return 'امام کی تنخواہ: $expected میں سے $collected جمع ہوئے۔ $due باقی ہے۔';
  }

  @override
  String spent(String amount) {
    return '$amount خرچ ہوئے';
  }

  @override
  String stillNeeded(String amount) {
    return '$amount اور چاہیے';
  }

  @override
  String stillToPay(String amount) {
    return '$amount باقی ہے';
  }

  @override
  String get activate => 'دوبارہ چالو کریں';

  @override
  String get activateQuestion => 'اس شخص کو دوبارہ ایپ چلانے دیں؟';

  @override
  String get addPerson => 'شخص شامل کریں';

  @override
  String get copy => 'کاپی کریں';

  @override
  String get deactivate => 'بند کریں';

  @override
  String get deactivatePointHistory =>
      'ان کی ادائیگیاں اور پرانا حساب محفوظ رہے گا۔';

  @override
  String get deactivatePointLogin => 'وہ ایپ میں لاگ اِن نہیں کر سکیں گے۔';

  @override
  String get deactivateQuestion => 'اس شخص کو بند کریں؟';

  @override
  String get details => 'تفصیل';

  @override
  String get donations => 'عطیات';

  @override
  String get editPerson => 'شخص میں تبدیلی';

  @override
  String get family => 'خاندان';

  @override
  String get familyHeadHelp =>
      'خاندان کا سربراہ خاندان کی طرف سے امام کی تنخواہ دیتا ہے۔';

  @override
  String familyMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'خاندان میں $count افراد',
      one: 'خاندان میں 1 فرد',
    );
    return '$_temp0';
  }

  @override
  String get familyMembersOptional => 'خاندان کے افراد (ضروری نہیں)';

  @override
  String get masjidId => 'مسجد آئی ڈی';

  @override
  String get myPaymentsLoadFailed => 'آپ کا حساب نہیں کھل سکا۔';

  @override
  String get noFamilyForRole => 'یہاں صرف ممبروں کا خاندان ہوتا ہے۔';

  @override
  String get noGiftsYet => 'ابھی تک کچھ نہیں دیا';

  @override
  String get noPeopleYet => 'ابھی کوئی شخص نہیں';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count لوگ',
      one: '1 شخص',
    );
    return '$_temp0';
  }

  @override
  String get peopleMembers => 'ممبر';

  @override
  String get personAdded => 'شخص شامل ہو گیا';

  @override
  String get personCanLoginWithCode =>
      'وہ اپنے فون نمبر اور کوڈ سے لاگ اِن کر سکتے ہیں۔';

  @override
  String get role => 'کردار';

  @override
  String get roleAndFamily => 'کردار اور خاندان';

  @override
  String salaryStillDue(String amount) {
    return '$amount تنخواہ ابھی دینی باقی ہے';
  }

  @override
  String get temporaryPasswordHelp =>
      'یہ پاس ورڈ اس شخص کو دیں۔ وہ بعد میں اسے بدل سکتے ہیں۔';

  @override
  String get whoIsIt => 'یہ کون ہے؟';

  @override
  String get youGaveInTotal => 'آپ نے کل دیا';

  @override
  String get aboutMasjid => 'مسجد کے بارے میں';

  @override
  String get allRoles => 'سب کردار';

  @override
  String get approve => 'منظور کریں';

  @override
  String get approveHelp =>
      'اس سے مسجد، اس کے امام اور کمیٹی شامل ہو جائیں گے۔';

  @override
  String get approveQuestion => 'یہ مسجد منظور کریں؟';

  @override
  String get cannotApprove => 'منظور نہیں ہو سکتا';

  @override
  String get changeRoles => 'کردار بدلیں';

  @override
  String get changeStatus => 'حالت بدلیں';

  @override
  String get email => 'ای میل';

  @override
  String get goBack => 'واپس جائیں';

  @override
  String get goHome => 'ہوم پر جائیں';

  @override
  String get joinedOn => 'شامل ہونے کی تاریخ';

  @override
  String get masjid => 'مسجد';

  @override
  String get noMasjids => 'کوئی مسجد نہیں';

  @override
  String get noRequests => 'کوئی درخواست نہیں';

  @override
  String get noRequestsWaiting => 'کوئی درخواست باقی نہیں';

  @override
  String get noUsers => 'کوئی شخص نہیں';

  @override
  String get pageNotFound => 'صفحہ نہیں ملا';

  @override
  String get pageNotFoundHelp => 'یہ لنک پرانا یا غلط ہے۔';

  @override
  String get person => 'شخص';

  @override
  String get phone => 'فون';

  @override
  String get pickToSeeDetails => 'یہاں دیکھنے کے لیے فہرست میں سے ایک چنیں۔';

  @override
  String get reason => 'وجہ';

  @override
  String get reasonOptional => 'وجہ (ضروری نہیں)';

  @override
  String get reject => 'نامنظور کریں';

  @override
  String get rejectQuestion => 'یہ درخواست نامنظور کریں؟';

  @override
  String get request => 'درخواست';

  @override
  String get requestApproved => 'درخواست منظور ہو گئی';

  @override
  String get requestRejected => 'درخواست نامنظور ہو گئی';

  @override
  String get requester => 'کس نے بھیجی';

  @override
  String requestsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count درخواستیں باقی',
      one: '1 درخواست باقی',
    );
    return '$_temp0';
  }

  @override
  String get rolesChanged => 'کردار بدل گیا';

  @override
  String get searchMasjids => 'مسجد یا جگہ تلاش کریں';

  @override
  String get searchRequests => 'مسجد، جگہ یا فون تلاش کریں';

  @override
  String get searchUsers => 'نام، فون یا ای میل تلاش کریں';

  @override
  String get sentOn => 'بھیجنے کی تاریخ';

  @override
  String get statusChanged => 'حالت بدل گئی';

  @override
  String get statusSuspended => 'روکا گیا';

  @override
  String get welcomeMessage => 'خوش آمدید پیغام';

  @override
  String get errorAlreadyExists => 'یہ پہلے سے محفوظ ہے۔';

  @override
  String get errorAlreadyInMasjid => 'یہ شخص پہلے سے اس مسجد میں ہے۔';

  @override
  String get errorCheckInput =>
      'آپ نے جو لکھا اس میں کچھ غلط ہے۔ دیکھ کر دوبارہ کوشش کریں۔';

  @override
  String get errorEmailTaken => 'یہ ای میل پہلے سے کسی اور کا ہے۔';

  @override
  String get errorInAnotherMasjid =>
      'یہ فون نمبر پہلے سے دوسری مسجد میں ہے۔ انہیں پہلے وہ مسجد چھوڑنی ہوگی۔';

  @override
  String get errorLoginAgain => 'براہ کرم دوبارہ لاگ اِن کریں۔';

  @override
  String get errorMasjidNotApproved => 'یہ مسجد ابھی منظور نہیں ہوئی۔';

  @override
  String get errorNotFound => 'یہ نہیں ملا۔ شاید ہٹا دیا گیا ہے۔';

  @override
  String get errorPhoneOtherPerson =>
      'یہ فون نمبر کسی اور تفصیل والے شخص کا ہے۔';

  @override
  String get errorRequestDecided => 'اس درخواست پر پہلے ہی فیصلہ ہو چکا ہے۔';

  @override
  String get errorSalaryMonthStarted =>
      'اس مہینے کی تنخواہ پہلے ہی شروع ہو چکی ہے۔';
}
