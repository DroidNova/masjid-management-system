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
}
