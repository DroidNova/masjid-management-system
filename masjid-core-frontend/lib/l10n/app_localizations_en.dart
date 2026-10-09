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

  @override
  String get aboutMasjidOptional => 'About the masjid (optional)';

  @override
  String get addMember => 'Add member';

  @override
  String get address => 'Address';

  @override
  String get age => 'Age';

  @override
  String get appTagline => 'Namaz times, news, and accounts of your masjid';

  @override
  String get changeCountry => 'Change country';

  @override
  String get changeNumber => 'Change number';

  @override
  String get check => 'Check';

  @override
  String get cityOrVillage => 'City or village';

  @override
  String get committeeHelp =>
      'The people who will run the masjid with the imam.';

  @override
  String get committeeMissing => 'Add at least one committee member.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get country => 'Country';

  @override
  String get district => 'District';

  @override
  String get duplicateCommitteePhone =>
      'Two committee members have the same phone number.';

  @override
  String get edit => 'Edit';

  @override
  String get emailOptional => 'Email (optional)';

  @override
  String get enterCode => 'Enter the code';

  @override
  String get errorAccountInactive =>
      'This account is switched off. Please talk to your masjid committee.';

  @override
  String get errorCodeExpired => 'This code has expired. Get a new code.';

  @override
  String get errorNoInternet =>
      'No internet. Check your connection and try again.';

  @override
  String get errorTooManyTries =>
      'Too many tries. Please wait a minute and try again.';

  @override
  String get errorWrongCode => 'Wrong code. Please try again.';

  @override
  String get errorWrongPassword => 'Wrong password. Please try again.';

  @override
  String get fatherName => 'Father\'s name';

  @override
  String get fieldRequired => 'Please fill this in.';

  @override
  String get fullName => 'Name';

  @override
  String get gender => 'Gender';

  @override
  String get genderFemale => 'Woman';

  @override
  String get genderMale => 'Man';

  @override
  String get genderOther => 'Other';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get home => 'Home';

  @override
  String get imamIsCommitteeMember =>
      'The imam cannot also be a committee member.';

  @override
  String get invalidAge => 'Age must be between 1 and 120.';

  @override
  String get invalidEmail => 'Check the email address.';

  @override
  String get invalidPhone => 'Check the phone number.';

  @override
  String get login => 'Login';

  @override
  String get masjidName => 'Masjid name';

  @override
  String get masjidPhoneOptional => 'Masjid phone (optional)';

  @override
  String get newCodeSent => 'A new code has been sent.';

  @override
  String get noRequestFound => 'No request found for this number.';

  @override
  String get password => 'Password';

  @override
  String get phoneAlreadyRegistered => 'Phone number already registered';

  @override
  String get phoneInAnotherMasjid =>
      'This number already belongs to another masjid.';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get registerMasjid => 'Register masjid';

  @override
  String get removeMember => 'Remove member';

  @override
  String get requestSent => 'Request sent';

  @override
  String get requestSentHelp =>
      'We will check the details. You can see the progress any time.';

  @override
  String get requesterHelp => 'Your details, so you can follow the request.';

  @override
  String get reviewHelp => 'Check everything, then send.';

  @override
  String get searchCountry => 'Search country';

  @override
  String get sendNewCode => 'Send new code';

  @override
  String get sendRequest => 'Send request';

  @override
  String get showPassword => 'Show password';

  @override
  String get state => 'State';

  @override
  String get stepApproved => 'Approved';

  @override
  String get stepChecking => 'Being checked';

  @override
  String get stepCommittee => 'Committee';

  @override
  String get stepImam => 'Imam';

  @override
  String get stepMasjid => 'Masjid';

  @override
  String get stepPlace => 'Place';

  @override
  String get stepRejected => 'Not approved';

  @override
  String get stepReview => 'Check and send';

  @override
  String get stepSent => 'Sent';

  @override
  String get stepYou => 'About you';

  @override
  String get trackHelp => 'Enter the phone number you used when registering.';

  @override
  String get trackRequest => 'Track request';

  @override
  String get welcomeMessageOptional => 'Welcome message (optional)';

  @override
  String get yourName => 'Your name';

  @override
  String get yourPassword => 'Your password';

  @override
  String get yourPhoneNumber => 'Your phone number';

  @override
  String codeSentTo(String phone) {
    return 'Sent to $phone';
  }

  @override
  String memberNumber(int number) {
    return 'Member $number';
  }

  @override
  String membersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get account => 'Account';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordHelp =>
      'Your other phones and computers will be logged out.';

  @override
  String get changeTimes => 'Change times';

  @override
  String get currentPassword => 'Current password';

  @override
  String get errorSamePassword =>
      'The new password is the same as the old one.';

  @override
  String get errorWrongCurrentPassword => 'The current password is wrong.';

  @override
  String get familyHead => 'Family head';

  @override
  String get latestNews => 'Latest news';

  @override
  String get leave => 'Leave';

  @override
  String get leaveMasjid => 'Leave masjid';

  @override
  String get leaveMasjidQuestion => 'Leave the masjid?';

  @override
  String get leavePointAccess =>
      'You will no longer see this masjid\'s times, news, and money.';

  @override
  String get leavePointHistory => 'Your payment history stays with the masjid.';

  @override
  String get leavePointJoin => 'Another masjid can add you after you leave.';

  @override
  String get logoutQuestion => 'Log out?';

  @override
  String get masjidBalance => 'Masjid balance';

  @override
  String get memberSince => 'Member since';

  @override
  String get moneyIn => 'Money in';

  @override
  String get moneyOut => 'Money out';

  @override
  String get namazTimesNotSet => 'Namaz times are not set yet.';

  @override
  String get newPassword => 'New password';

  @override
  String get nextNamaz => 'Next namaz';

  @override
  String get notVerified => 'Not verified';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get passwordsDiffer => 'The two passwords are not the same.';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get prayerJumma => 'Jumma';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerZuhr => 'Zuhr';

  @override
  String get repeatNewPassword => 'New password again';

  @override
  String get roleCommittee => 'Committee';

  @override
  String get roleImam => 'Imam';

  @override
  String get roleMember => 'Member';

  @override
  String get roleSuperAdmin => 'Super admin';

  @override
  String get salary => 'Salary';

  @override
  String get seeAll => 'See all';

  @override
  String get setTimes => 'Set times';

  @override
  String get statusActive => 'Active';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get statusPending => 'Pending';

  @override
  String get superAdmin => 'Super admin';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String get tabHome => 'Home';

  @override
  String get tabMasjids => 'Masjids';

  @override
  String get tabMoney => 'Money';

  @override
  String get tabMyPayments => 'My payments';

  @override
  String get tabNews => 'News';

  @override
  String get tabPeople => 'People';

  @override
  String get tabProfile => 'Profile';

  @override
  String get tabProjects => 'Projects';

  @override
  String get tabRequests => 'Requests';

  @override
  String get tabTimes => 'Times';

  @override
  String get tabUsers => 'Users';

  @override
  String get thisMonth => 'This month';

  @override
  String get verified => 'Verified';

  @override
  String get youLeftTheMasjid => 'You left the masjid';

  @override
  String inHoursMinutes(int hours, int minutes) {
    return 'in $hours h $minutes min';
  }

  @override
  String inMinutes(int minutes) {
    return 'in $minutes min';
  }

  @override
  String nextNamazSpoken(String prayer, String time, String countdown) {
    return 'Next namaz: $prayer at $time, $countdown';
  }

  @override
  String passwordTooShort(int count) {
    return 'Use at least $count letters or numbers.';
  }

  @override
  String youLeft(String masjid) {
    return 'You left $masjid';
  }
}
