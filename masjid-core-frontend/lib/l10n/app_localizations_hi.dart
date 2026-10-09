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

  @override
  String get aboutMasjidOptional => 'मस्जिद के बारे में (ज़रूरी नहीं)';

  @override
  String get addMember => 'सदस्य जोड़ें';

  @override
  String get address => 'पता';

  @override
  String get age => 'उम्र';

  @override
  String get appTagline => 'आपकी मस्जिद के नमाज़ के समय, खबरें और हिसाब';

  @override
  String get changeCountry => 'देश बदलें';

  @override
  String get changeNumber => 'नंबर बदलें';

  @override
  String get check => 'देखें';

  @override
  String get cityOrVillage => 'शहर या गाँव';

  @override
  String get committeeHelp => 'वे लोग जो इमाम के साथ मस्जिद चलाएँगे।';

  @override
  String get committeeMissing => 'कम से कम एक कमेटी सदस्य जोड़ें।';

  @override
  String get continueLabel => 'आगे बढ़ें';

  @override
  String get country => 'देश';

  @override
  String get district => 'ज़िला';

  @override
  String get duplicateCommitteePhone =>
      'दो कमेटी सदस्यों का फ़ोन नंबर एक ही है।';

  @override
  String get edit => 'बदलें';

  @override
  String get emailOptional => 'ईमेल (ज़रूरी नहीं)';

  @override
  String get enterCode => 'कोड डालें';

  @override
  String get errorAccountInactive =>
      'यह खाता बंद है। कृपया अपनी मस्जिद कमेटी से बात करें।';

  @override
  String get errorCodeExpired => 'इस कोड का समय खत्म हो गया। नया कोड लें।';

  @override
  String get errorNoInternet =>
      'इंटरनेट नहीं है। कनेक्शन देखें और फिर कोशिश करें।';

  @override
  String get errorTooManyTries =>
      'बहुत बार कोशिश हुई। एक मिनट रुककर फिर कोशिश करें।';

  @override
  String get errorWrongCode => 'कोड गलत है। फिर कोशिश करें।';

  @override
  String get errorWrongPassword => 'पासवर्ड गलत है। फिर कोशिश करें।';

  @override
  String get fatherName => 'पिता का नाम';

  @override
  String get fieldRequired => 'कृपया यह भरें।';

  @override
  String get fullName => 'नाम';

  @override
  String get gender => 'लिंग';

  @override
  String get genderFemale => 'महिला';

  @override
  String get genderMale => 'पुरुष';

  @override
  String get genderOther => 'अन्य';

  @override
  String get hidePassword => 'पासवर्ड छिपाएँ';

  @override
  String get home => 'होम';

  @override
  String get imamIsCommitteeMember => 'इमाम कमेटी सदस्य नहीं हो सकते।';

  @override
  String get invalidAge => 'उम्र 1 से 120 के बीच होनी चाहिए।';

  @override
  String get invalidEmail => 'ईमेल पता जाँचें।';

  @override
  String get invalidPhone => 'फ़ोन नंबर जाँचें।';

  @override
  String get login => 'लॉग इन';

  @override
  String get masjidName => 'मस्जिद का नाम';

  @override
  String get masjidPhoneOptional => 'मस्जिद का फ़ोन (ज़रूरी नहीं)';

  @override
  String get newCodeSent => 'नया कोड भेज दिया गया है।';

  @override
  String get noRequestFound => 'इस नंबर से कोई अनुरोध नहीं मिला।';

  @override
  String get password => 'पासवर्ड';

  @override
  String get phoneAlreadyRegistered => 'फ़ोन नंबर पहले से दर्ज है';

  @override
  String get phoneInAnotherMasjid =>
      'यह नंबर पहले से किसी दूसरी मस्जिद में है।';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get registerMasjid => 'मस्जिद जोड़ें';

  @override
  String get removeMember => 'सदस्य हटाएँ';

  @override
  String get requestSent => 'अनुरोध भेज दिया गया';

  @override
  String get requestSentHelp =>
      'हम जानकारी जाँचेंगे। आप कभी भी प्रगति देख सकते हैं।';

  @override
  String get requesterHelp => 'आपकी जानकारी, ताकि आप अनुरोध देख सकें।';

  @override
  String get reviewHelp => 'सब कुछ जाँचें, फिर भेजें।';

  @override
  String get searchCountry => 'देश खोजें';

  @override
  String get sendNewCode => 'नया कोड भेजें';

  @override
  String get sendRequest => 'अनुरोध भेजें';

  @override
  String get showPassword => 'पासवर्ड दिखाएँ';

  @override
  String get state => 'राज्य';

  @override
  String get stepApproved => 'मंज़ूर';

  @override
  String get stepChecking => 'जाँच हो रही है';

  @override
  String get stepCommittee => 'कमेटी';

  @override
  String get stepImam => 'इमाम';

  @override
  String get stepMasjid => 'मस्जिद';

  @override
  String get stepPlace => 'जगह';

  @override
  String get stepRejected => 'मंज़ूर नहीं';

  @override
  String get stepReview => 'जाँचें और भेजें';

  @override
  String get stepSent => 'भेजा गया';

  @override
  String get stepYou => 'आपके बारे में';

  @override
  String get trackHelp => 'रजिस्ट्रेशन के समय दिया गया फ़ोन नंबर डालें।';

  @override
  String get trackRequest => 'अनुरोध देखें';

  @override
  String get welcomeMessageOptional => 'स्वागत संदेश (ज़रूरी नहीं)';

  @override
  String get yourName => 'आपका नाम';

  @override
  String get yourPassword => 'आपका पासवर्ड';

  @override
  String get yourPhoneNumber => 'आपका फ़ोन नंबर';

  @override
  String codeSentTo(String phone) {
    return '$phone पर भेजा गया';
  }

  @override
  String memberNumber(int number) {
    return 'सदस्य $number';
  }

  @override
  String membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सदस्य',
      one: '1 सदस्य',
    );
    return '$_temp0';
  }

  @override
  String get account => 'खाता';

  @override
  String get changePassword => 'पासवर्ड बदलें';

  @override
  String get changePasswordHelp =>
      'आपके दूसरे फ़ोन और कंप्यूटर से लॉग आउट हो जाएगा।';

  @override
  String get changeTimes => 'समय बदलें';

  @override
  String get currentPassword => 'अभी का पासवर्ड';

  @override
  String get errorSamePassword => 'नया पासवर्ड पुराने जैसा ही है।';

  @override
  String get errorWrongCurrentPassword => 'अभी का पासवर्ड गलत है।';

  @override
  String get familyHead => 'घर के मुखिया';

  @override
  String get latestNews => 'ताज़ा खबर';

  @override
  String get leave => 'छोड़ें';

  @override
  String get leaveMasjid => 'मस्जिद छोड़ें';

  @override
  String get leaveMasjidQuestion => 'मस्जिद छोड़ना चाहते हैं?';

  @override
  String get leavePointAccess =>
      'आप इस मस्जिद के समय, खबरें और हिसाब नहीं देख पाएँगे।';

  @override
  String get leavePointHistory => 'आपके भुगतान का रिकॉर्ड मस्जिद के पास रहेगा।';

  @override
  String get leavePointJoin =>
      'छोड़ने के बाद कोई दूसरी मस्जिद आपको जोड़ सकती है।';

  @override
  String get logoutQuestion => 'लॉग आउट करें?';

  @override
  String get masjidBalance => 'मस्जिद का बैलेंस';

  @override
  String get memberSince => 'सदस्य कब से';

  @override
  String get moneyIn => 'पैसा आया';

  @override
  String get moneyOut => 'पैसा गया';

  @override
  String get namazTimesNotSet => 'नमाज़ के समय अभी तय नहीं हुए हैं।';

  @override
  String get newPassword => 'नया पासवर्ड';

  @override
  String get nextNamaz => 'अगली नमाज़';

  @override
  String get notVerified => 'जाँचा नहीं गया';

  @override
  String get passwordChanged => 'पासवर्ड बदल गया';

  @override
  String get passwordsDiffer => 'दोनों पासवर्ड एक जैसे नहीं हैं।';

  @override
  String get prayerAsr => 'अस्र';

  @override
  String get prayerFajr => 'फ़ज्र';

  @override
  String get prayerIsha => 'इशा';

  @override
  String get prayerJumma => 'जुमा';

  @override
  String get prayerMaghrib => 'मग़रिब';

  @override
  String get prayerZuhr => 'ज़ुहर';

  @override
  String get repeatNewPassword => 'नया पासवर्ड फिर से';

  @override
  String get roleCommittee => 'कमेटी';

  @override
  String get roleImam => 'इमाम';

  @override
  String get roleMember => 'सदस्य';

  @override
  String get roleSuperAdmin => 'सुपर एडमिन';

  @override
  String get salary => 'तनख़्वाह';

  @override
  String get seeAll => 'सब देखें';

  @override
  String get setTimes => 'समय तय करें';

  @override
  String get statusActive => 'चालू';

  @override
  String get statusInactive => 'बंद';

  @override
  String get statusPending => 'रुका हुआ';

  @override
  String get superAdmin => 'सुपर एडमिन';

  @override
  String get tabDashboard => 'डैशबोर्ड';

  @override
  String get tabHome => 'होम';

  @override
  String get tabMasjids => 'मस्जिदें';

  @override
  String get tabMoney => 'पैसा';

  @override
  String get tabMyPayments => 'मेरा भुगतान';

  @override
  String get tabNews => 'खबरें';

  @override
  String get tabPeople => 'लोग';

  @override
  String get tabProfile => 'प्रोफ़ाइल';

  @override
  String get tabProjects => 'काम';

  @override
  String get tabRequests => 'अनुरोध';

  @override
  String get tabTimes => 'समय';

  @override
  String get tabUsers => 'उपयोगकर्ता';

  @override
  String get thisMonth => 'इस महीने';

  @override
  String get verified => 'जाँचा गया';

  @override
  String get youLeftTheMasjid => 'आपने मस्जिद छोड़ दी';

  @override
  String inHoursMinutes(int hours, int minutes) {
    return '$hours घंटे $minutes मिनट में';
  }

  @override
  String inMinutes(int minutes) {
    return '$minutes मिनट में';
  }

  @override
  String nextNamazSpoken(String prayer, String time, String countdown) {
    return 'अगली नमाज़: $prayer, $time बजे, $countdown';
  }

  @override
  String passwordTooShort(int count) {
    return 'कम से कम $count अक्षर या अंक रखें।';
  }

  @override
  String youLeft(String masjid) {
    return 'आपने $masjid छोड़ दी';
  }

  @override
  String get addFirstNews => 'पहली खबर जोड़ें';

  @override
  String get addNews => 'खबर जोड़ें';

  @override
  String get changed => 'बदला गया';

  @override
  String get delete => 'हटाएँ';

  @override
  String get deleteNewsPoint => 'यह खबर अब किसी को नहीं दिखेगी।';

  @override
  String get deleteNewsQuestion => 'यह खबर हटाएँ?';

  @override
  String get dictationTip =>
      'सुझाव: लिखने की जगह बोलने के लिए कीबोर्ड पर माइक दबाएँ।';

  @override
  String get editNews => 'खबर बदलें';

  @override
  String get friday => 'जुमे का दिन';

  @override
  String get leaveWithoutSaving => 'बिना सहेजे जाएँ?';

  @override
  String get leaveWithoutSavingConfirm => 'जाएँ';

  @override
  String get minusFiveMinutes => '5 मिनट पहले';

  @override
  String get newLabel => 'नई';

  @override
  String get newsDeleted => 'खबर हटा दी गई';

  @override
  String get newsLoadFailed => 'खबरें लोड नहीं हो सकीं';

  @override
  String get newsMessage => 'संदेश';

  @override
  String get newsPublished => 'खबर लग गई';

  @override
  String get newsTitle => 'शीर्षक';

  @override
  String get noNewsYet => 'अभी कोई खबर नहीं';

  @override
  String get noteOptional => 'नोट (ज़रूरी नहीं)';

  @override
  String get plusFiveMinutes => '5 मिनट बाद';

  @override
  String get readMore => 'और पढ़ें';

  @override
  String get saved => 'सहेज लिया';

  @override
  String get setTime => 'समय चुनें';

  @override
  String get showLess => 'कम दिखाएँ';

  @override
  String get timesSaved => 'समय सहेज लिए';

  @override
  String get addGiver => 'देने वाला जोड़ें';

  @override
  String get addNote => 'नोट जोड़ें';

  @override
  String get all => 'सब';

  @override
  String get cancelEntry => 'एंट्री रद्द करें';

  @override
  String get cancelEntryPoint =>
      'यह रकम मस्जिद के हिसाब से निकल जाएगी। एंट्री सूची में रद्द के निशान के साथ रहेगी।';

  @override
  String get cancelEntryQuestion => 'यह एंट्री रद्द करें?';

  @override
  String get cancelled => 'रद्द';

  @override
  String get catCleaning => 'सफ़ाई';

  @override
  String get catConstruction => 'निर्माण';

  @override
  String get catConstructionFund => 'निर्माण फंड';

  @override
  String get catDonationBox => 'दान पेटी';

  @override
  String get catElectricity => 'बिजली';

  @override
  String get catImamSalary => 'इमाम की तनख़्वाह';

  @override
  String get catJumma => 'जुमा';

  @override
  String get catOther => 'अन्य';

  @override
  String get catRamadanFund => 'रमज़ान फंड';

  @override
  String get catRepair => 'मरम्मत';

  @override
  String get catSadaqah => 'सदक़ा';

  @override
  String get catWater => 'पानी';

  @override
  String get catZakat => 'ज़कात';

  @override
  String get givers => 'देने वाले';

  @override
  String get howMuch => 'कितना?';

  @override
  String get moneyInSaved => 'आया पैसा सहेज लिया';

  @override
  String get moneyLoadFailed => 'पैसे का हिसाब लोड नहीं हो सका।';

  @override
  String get moneyOutSaved => 'गया पैसा सहेज लिया';

  @override
  String get noGiversYet => 'अभी कोई देने वाला नहीं';

  @override
  String get noMoneyInYet => 'अभी कोई पैसा नहीं आया';

  @override
  String get noMoneyOutYet => 'अभी कोई पैसा नहीं गया';

  @override
  String get nothingMatches => 'कुछ नहीं मिला';

  @override
  String get payCash => 'नकद';

  @override
  String get payOnline => 'ऑनलाइन';

  @override
  String get phoneOptional => 'फ़ोन (ज़रूरी नहीं)';

  @override
  String get pickAnother => 'कोई और चुनें';

  @override
  String get pickMember => 'सदस्य चुनें';

  @override
  String get someoneElse => 'सदस्य नहीं हैं';

  @override
  String get whatFor => 'किसके लिए?';

  @override
  String get whatKind => 'किस तरह का?';

  @override
  String get whoGave => 'किसने दिया?';

  @override
  String get aboutProjectOptional => 'काम के बारे में (ज़रूरी नहीं)';

  @override
  String get addFirstProject => 'पहला काम जोड़ें';

  @override
  String get addProject => 'काम जोड़ें';

  @override
  String get amountPerFamilyHelp => 'इस महीने हर परिवार कितना देगा।';

  @override
  String get cancelProject => 'काम रद्द करें';

  @override
  String get cancelProjectPoint => 'काम रुक जाएगा। दिया गया पैसा दर्ज रहेगा।';

  @override
  String get cancelProjectQuestion => 'यह काम रद्द करें?';

  @override
  String get collected => 'जमा हुआ';

  @override
  String get datesAndStatus => 'तारीख़ें और हालत';

  @override
  String get due => 'बाकी';

  @override
  String get editProject => 'काम बदलें';

  @override
  String get endDate => 'अंत';

  @override
  String get endDateOptional => 'खत्म होने की तारीख़ (ज़रूरी नहीं)';

  @override
  String get families => 'परिवार';

  @override
  String get moneyNeeded => 'कितना पैसा चाहिए';

  @override
  String get moneyNeededHelp => 'काम के लिए कुल रकम। पता न हो तो खाली छोड़ें।';

  @override
  String get mySalary => 'मेरा तनख़्वाह भुगतान';

  @override
  String get noFamiliesYet => 'अभी कोई परिवार नहीं';

  @override
  String get noPaymentsYet => 'अभी कोई भुगतान नहीं';

  @override
  String get noProjectsYet => 'अभी कोई काम नहीं';

  @override
  String get noSalaryHistory => 'अभी कोई तनख़्वाह भुगतान नहीं';

  @override
  String get payments => 'भुगतान';

  @override
  String get projectAdded => 'काम जुड़ गया';

  @override
  String get projectCancelled => 'रद्द';

  @override
  String get projectCancelledDone => 'काम रद्द हो गया';

  @override
  String get projectCompleted => 'पूरा';

  @override
  String get projectName => 'काम का नाम';

  @override
  String get projectOngoing => 'चल रहा है';

  @override
  String get projectPlanned => 'योजना में';

  @override
  String get raiseAmount => 'रकम बढ़ाएँ';

  @override
  String get salaryMonthStarted => 'तनख़्वाह का महीना शुरू हुआ';

  @override
  String get salaryNotPaid => 'नहीं दिया';

  @override
  String get salaryNotStarted => 'इस महीने की तनख़्वाह शुरू नहीं हुई';

  @override
  String get salaryPaid => 'दे दिया';

  @override
  String get salaryPartlyPaid => 'कुछ दिया';

  @override
  String get salaryPaymentSaved => 'भुगतान सहेज लिया';

  @override
  String get searchProjects => 'काम खोजें';

  @override
  String get startDate => 'शुरू';

  @override
  String get startDateOptional => 'शुरू की तारीख़ (ज़रूरी नहीं)';

  @override
  String get startSalaryMonth => 'महीना शुरू करें';

  @override
  String get status => 'हालत';

  @override
  String amountCanOnlyGoUp(String amount) {
    return 'रकम सिर्फ़ बढ़ सकती है (अभी $amount)।';
  }

  @override
  String collectedOf(String collected, String target) {
    return '$target में से $collected';
  }

  @override
  String collectedSoFar(String amount) {
    return '$amount जमा हुए';
  }

  @override
  String notPaidCount(int count) {
    return '$count ने नहीं दिया';
  }

  @override
  String outOf(String amount) {
    return '$amount में से';
  }

  @override
  String paidCount(int count) {
    return '$count ने दिया';
  }

  @override
  String paidOutOf(String paid, String expected) {
    return '$expected में से $paid दिया';
  }

  @override
  String partlyPaidCount(int count) {
    return '$count ने कुछ दिया';
  }

  @override
  String payMoreThanDue(String amount) {
    return 'यह बाकी रकम ($amount) से ज़्यादा है।';
  }

  @override
  String perFamily(String amount) {
    return 'हर परिवार $amount';
  }

  @override
  String salarySpoken(String collected, String expected, String due) {
    return 'इमाम की तनख़्वाह: $expected में से $collected जमा हुए। $due बाकी है।';
  }

  @override
  String spent(String amount) {
    return '$amount खर्च हुए';
  }

  @override
  String stillNeeded(String amount) {
    return '$amount और चाहिए';
  }

  @override
  String stillToPay(String amount) {
    return '$amount बाकी है';
  }
}
