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

  @override
  String get addFirstNews => 'Add the first news';

  @override
  String get addNews => 'Add news';

  @override
  String get changed => 'Changed';

  @override
  String get delete => 'Delete';

  @override
  String get deleteNewsPoint => 'Nobody will see this news any more.';

  @override
  String get deleteNewsQuestion => 'Delete this news?';

  @override
  String get dictationTip =>
      'Tip: tap the microphone on your keyboard to speak instead of typing.';

  @override
  String get editNews => 'Edit news';

  @override
  String get friday => 'Friday';

  @override
  String get leaveWithoutSaving => 'Leave without saving?';

  @override
  String get leaveWithoutSavingConfirm => 'Leave';

  @override
  String get minusFiveMinutes => '5 minutes earlier';

  @override
  String get newLabel => 'New';

  @override
  String get newsDeleted => 'News deleted';

  @override
  String get newsLoadFailed => 'Unable to load news';

  @override
  String get newsMessage => 'Message';

  @override
  String get newsPublished => 'News published';

  @override
  String get newsTitle => 'Title';

  @override
  String get noNewsYet => 'No news yet';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get plusFiveMinutes => '5 minutes later';

  @override
  String get readMore => 'Read more';

  @override
  String get saved => 'Saved';

  @override
  String get setTime => 'Set time';

  @override
  String get showLess => 'Show less';

  @override
  String get timesSaved => 'Times saved';

  @override
  String get addGiver => 'Add giver';

  @override
  String get addNote => 'Add a note';

  @override
  String get all => 'All';

  @override
  String get cancelEntry => 'Cancel entry';

  @override
  String get cancelEntryPoint =>
      'The amount is taken out of the masjid\'s totals. The entry stays in the list, marked cancelled.';

  @override
  String get cancelEntryQuestion => 'Cancel this entry?';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get catCleaning => 'Cleaning';

  @override
  String get catConstruction => 'Construction';

  @override
  String get catConstructionFund => 'Building fund';

  @override
  String get catDonationBox => 'Donation box';

  @override
  String get catElectricity => 'Electricity';

  @override
  String get catImamSalary => 'Imam salary';

  @override
  String get catJumma => 'Jumma';

  @override
  String get catOther => 'Other';

  @override
  String get catRamadanFund => 'Ramadan fund';

  @override
  String get catRepair => 'Repair';

  @override
  String get catSadaqah => 'Sadaqah';

  @override
  String get catWater => 'Water';

  @override
  String get catZakat => 'Zakat';

  @override
  String get givers => 'Givers';

  @override
  String get howMuch => 'How much?';

  @override
  String get moneyInSaved => 'Money in saved';

  @override
  String get moneyLoadFailed => 'Unable to load the money totals.';

  @override
  String get moneyOutSaved => 'Money out saved';

  @override
  String get noGiversYet => 'No givers yet';

  @override
  String get noMoneyInYet => 'No money in yet';

  @override
  String get noMoneyOutYet => 'No money out yet';

  @override
  String get nothingMatches => 'Nothing matches';

  @override
  String get payCash => 'Cash';

  @override
  String get payOnline => 'Online';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get pickAnother => 'Pick someone else';

  @override
  String get pickMember => 'Pick a member';

  @override
  String get someoneElse => 'Not a member';

  @override
  String get whatFor => 'What for?';

  @override
  String get whatKind => 'What kind?';

  @override
  String get whoGave => 'Who gave?';

  @override
  String get aboutProjectOptional => 'About the project (optional)';

  @override
  String get addFirstProject => 'Add the first project';

  @override
  String get addProject => 'Add project';

  @override
  String get amountPerFamilyHelp => 'How much each family pays this month.';

  @override
  String get cancelProject => 'Cancel project';

  @override
  String get cancelProjectPoint =>
      'The project stops. Money already given stays recorded.';

  @override
  String get cancelProjectQuestion => 'Cancel this project?';

  @override
  String get collected => 'Collected';

  @override
  String get datesAndStatus => 'Dates and status';

  @override
  String get due => 'Due';

  @override
  String get editProject => 'Edit project';

  @override
  String get endDate => 'End';

  @override
  String get endDateOptional => 'End date (optional)';

  @override
  String get families => 'Families';

  @override
  String get moneyNeeded => 'Money needed';

  @override
  String get moneyNeededHelp =>
      'The total the project needs. Leave it empty if not known.';

  @override
  String get mySalary => 'My salary payments';

  @override
  String get noFamiliesYet => 'No families yet';

  @override
  String get noPaymentsYet => 'No payments yet';

  @override
  String get noProjectsYet => 'No projects yet';

  @override
  String get noSalaryHistory => 'No salary payments yet';

  @override
  String get payments => 'Payments';

  @override
  String get projectAdded => 'Project added';

  @override
  String get projectCancelled => 'Cancelled';

  @override
  String get projectCancelledDone => 'Project cancelled';

  @override
  String get projectCompleted => 'Completed';

  @override
  String get projectName => 'Project name';

  @override
  String get projectOngoing => 'Ongoing';

  @override
  String get projectPlanned => 'Planned';

  @override
  String get raiseAmount => 'Raise amount';

  @override
  String get salaryMonthStarted => 'Salary month started';

  @override
  String get salaryNotPaid => 'Not paid';

  @override
  String get salaryNotStarted => 'This month\'s salary is not started';

  @override
  String get salaryPaid => 'Paid';

  @override
  String get salaryPartlyPaid => 'Part paid';

  @override
  String get salaryPaymentSaved => 'Payment saved';

  @override
  String get searchProjects => 'Search projects';

  @override
  String get startDate => 'Start';

  @override
  String get startDateOptional => 'Start date (optional)';

  @override
  String get startSalaryMonth => 'Start month';

  @override
  String get status => 'Status';

  @override
  String amountCanOnlyGoUp(String amount) {
    return 'The amount can only go up (now $amount).';
  }

  @override
  String collectedOf(String collected, String target) {
    return '$collected of $target';
  }

  @override
  String collectedSoFar(String amount) {
    return '$amount collected';
  }

  @override
  String notPaidCount(int count) {
    return '$count not paid';
  }

  @override
  String outOf(String amount) {
    return 'of $amount';
  }

  @override
  String paidCount(int count) {
    return '$count paid';
  }

  @override
  String paidOutOf(String paid, String expected) {
    return 'Paid $paid of $expected';
  }

  @override
  String partlyPaidCount(int count) {
    return '$count part paid';
  }

  @override
  String payMoreThanDue(String amount) {
    return 'This is more than what is due ($amount).';
  }

  @override
  String perFamily(String amount) {
    return '$amount per family';
  }

  @override
  String salarySpoken(String collected, String expected, String due) {
    return 'Imam salary: $collected collected of $expected. $due still to pay.';
  }

  @override
  String spent(String amount) {
    return '$amount spent';
  }

  @override
  String stillNeeded(String amount) {
    return '$amount still needed';
  }

  @override
  String stillToPay(String amount) {
    return '$amount still to pay';
  }
}
