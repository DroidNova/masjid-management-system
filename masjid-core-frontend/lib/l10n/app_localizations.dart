import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ur'),
  ];

  /// App name shown in the window title and splash screen.
  ///
  /// In en, this message translates to:
  /// **'Masjid'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @notAllowedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get notAllowedTitle;

  /// No description provided for @notAllowedMessage.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to perform this action.'**
  String get notAllowedMessage;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please login again.'**
  String get sessionExpired;

  /// No description provided for @noMasjidAssigned.
  ///
  /// In en, this message translates to:
  /// **'You are not assigned to any masjid yet.'**
  String get noMasjidAssigned;

  /// No description provided for @dashboardLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load dashboard'**
  String get dashboardLoadFailed;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get pickDate;

  /// No description provided for @readAloud.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get readAloud;

  /// No description provided for @stopReading.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopReading;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get pleaseWait;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone'**
  String get searchPeople;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get amountHint;

  /// Backspace key on the amount number pad (screen reader label).
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteDigit;

  /// Hint under a dangerous button that must be held for 2 seconds.
  ///
  /// In en, this message translates to:
  /// **'Press and hold'**
  String get pressAndHold;

  /// Screen reader label for a hold-to-confirm button. {action} is the button's own label, e.g. 'Leave'.
  ///
  /// In en, this message translates to:
  /// **'Hold to {action}'**
  String holdTo(String action);

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @largeText.
  ///
  /// In en, this message translates to:
  /// **'Large text'**
  String get largeText;

  /// No description provided for @aboutMasjidOptional.
  ///
  /// In en, this message translates to:
  /// **'About the masjid (optional)'**
  String get aboutMasjidOptional;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addMember;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Namaz times, news, and accounts of your masjid'**
  String get appTagline;

  /// No description provided for @changeCountry.
  ///
  /// In en, this message translates to:
  /// **'Change country'**
  String get changeCountry;

  /// No description provided for @changeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get changeNumber;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @cityOrVillage.
  ///
  /// In en, this message translates to:
  /// **'City or village'**
  String get cityOrVillage;

  /// No description provided for @committeeHelp.
  ///
  /// In en, this message translates to:
  /// **'The people who will run the masjid with the imam.'**
  String get committeeHelp;

  /// No description provided for @committeeMissing.
  ///
  /// In en, this message translates to:
  /// **'Add at least one committee member.'**
  String get committeeMissing;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @duplicateCommitteePhone.
  ///
  /// In en, this message translates to:
  /// **'Two committee members have the same phone number.'**
  String get duplicateCommitteePhone;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get enterCode;

  /// No description provided for @errorAccountInactive.
  ///
  /// In en, this message translates to:
  /// **'This account is switched off. Please talk to your masjid committee.'**
  String get errorAccountInactive;

  /// No description provided for @errorCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired. Get a new code.'**
  String get errorCodeExpired;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet. Check your connection and try again.'**
  String get errorNoInternet;

  /// No description provided for @errorTooManyTries.
  ///
  /// In en, this message translates to:
  /// **'Too many tries. Please wait a minute and try again.'**
  String get errorTooManyTries;

  /// No description provided for @errorWrongCode.
  ///
  /// In en, this message translates to:
  /// **'Wrong code. Please try again.'**
  String get errorWrongCode;

  /// No description provided for @errorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password. Please try again.'**
  String get errorWrongPassword;

  /// No description provided for @fatherName.
  ///
  /// In en, this message translates to:
  /// **'Father\'s name'**
  String get fatherName;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill this in.'**
  String get fieldRequired;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fullName;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Woman'**
  String get genderFemale;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Man'**
  String get genderMale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @imamIsCommitteeMember.
  ///
  /// In en, this message translates to:
  /// **'The imam cannot also be a committee member.'**
  String get imamIsCommitteeMember;

  /// No description provided for @invalidAge.
  ///
  /// In en, this message translates to:
  /// **'Age must be between 1 and 120.'**
  String get invalidAge;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Check the email address.'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Check the phone number.'**
  String get invalidPhone;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @masjidName.
  ///
  /// In en, this message translates to:
  /// **'Masjid name'**
  String get masjidName;

  /// No description provided for @masjidPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Masjid phone (optional)'**
  String get masjidPhoneOptional;

  /// No description provided for @newCodeSent.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent.'**
  String get newCodeSent;

  /// No description provided for @noRequestFound.
  ///
  /// In en, this message translates to:
  /// **'No request found for this number.'**
  String get noRequestFound;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @phoneAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Phone number already registered'**
  String get phoneAlreadyRegistered;

  /// No description provided for @phoneInAnotherMasjid.
  ///
  /// In en, this message translates to:
  /// **'This number already belongs to another masjid.'**
  String get phoneInAnotherMasjid;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @registerMasjid.
  ///
  /// In en, this message translates to:
  /// **'Register masjid'**
  String get registerMasjid;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get removeMember;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get requestSent;

  /// No description provided for @requestSentHelp.
  ///
  /// In en, this message translates to:
  /// **'We will check the details. You can see the progress any time.'**
  String get requestSentHelp;

  /// No description provided for @requesterHelp.
  ///
  /// In en, this message translates to:
  /// **'Your details, so you can follow the request.'**
  String get requesterHelp;

  /// No description provided for @reviewHelp.
  ///
  /// In en, this message translates to:
  /// **'Check everything, then send.'**
  String get reviewHelp;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get searchCountry;

  /// No description provided for @sendNewCode.
  ///
  /// In en, this message translates to:
  /// **'Send new code'**
  String get sendNewCode;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @stepApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get stepApproved;

  /// No description provided for @stepChecking.
  ///
  /// In en, this message translates to:
  /// **'Being checked'**
  String get stepChecking;

  /// No description provided for @stepCommittee.
  ///
  /// In en, this message translates to:
  /// **'Committee'**
  String get stepCommittee;

  /// No description provided for @stepImam.
  ///
  /// In en, this message translates to:
  /// **'Imam'**
  String get stepImam;

  /// No description provided for @stepMasjid.
  ///
  /// In en, this message translates to:
  /// **'Masjid'**
  String get stepMasjid;

  /// No description provided for @stepPlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get stepPlace;

  /// No description provided for @stepRejected.
  ///
  /// In en, this message translates to:
  /// **'Not approved'**
  String get stepRejected;

  /// No description provided for @stepReview.
  ///
  /// In en, this message translates to:
  /// **'Check and send'**
  String get stepReview;

  /// No description provided for @stepSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get stepSent;

  /// No description provided for @stepYou.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get stepYou;

  /// No description provided for @trackHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number you used when registering.'**
  String get trackHelp;

  /// No description provided for @trackRequest.
  ///
  /// In en, this message translates to:
  /// **'Track request'**
  String get trackRequest;

  /// No description provided for @welcomeMessageOptional.
  ///
  /// In en, this message translates to:
  /// **'Welcome message (optional)'**
  String get welcomeMessageOptional;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @yourPassword.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get yourPassword;

  /// No description provided for @yourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Your phone number'**
  String get yourPhoneNumber;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Sent to {phone}'**
  String codeSentTo(String phone);

  /// No description provided for @memberNumber.
  ///
  /// In en, this message translates to:
  /// **'Member {number}'**
  String memberNumber(int number);

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String membersCount(int count);

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @changePasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'Your other phones and computers will be logged out.'**
  String get changePasswordHelp;

  /// No description provided for @changeTimes.
  ///
  /// In en, this message translates to:
  /// **'Change times'**
  String get changeTimes;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @errorSamePassword.
  ///
  /// In en, this message translates to:
  /// **'The new password is the same as the old one.'**
  String get errorSamePassword;

  /// No description provided for @errorWrongCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'The current password is wrong.'**
  String get errorWrongCurrentPassword;

  /// No description provided for @familyHead.
  ///
  /// In en, this message translates to:
  /// **'Family head'**
  String get familyHead;

  /// No description provided for @latestNews.
  ///
  /// In en, this message translates to:
  /// **'Latest news'**
  String get latestNews;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @leaveMasjid.
  ///
  /// In en, this message translates to:
  /// **'Leave masjid'**
  String get leaveMasjid;

  /// No description provided for @leaveMasjidQuestion.
  ///
  /// In en, this message translates to:
  /// **'Leave the masjid?'**
  String get leaveMasjidQuestion;

  /// No description provided for @leavePointAccess.
  ///
  /// In en, this message translates to:
  /// **'You will no longer see this masjid\'s times, news, and money.'**
  String get leavePointAccess;

  /// No description provided for @leavePointHistory.
  ///
  /// In en, this message translates to:
  /// **'Your payment history stays with the masjid.'**
  String get leavePointHistory;

  /// No description provided for @leavePointJoin.
  ///
  /// In en, this message translates to:
  /// **'Another masjid can add you after you leave.'**
  String get leavePointJoin;

  /// No description provided for @logoutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutQuestion;

  /// No description provided for @masjidBalance.
  ///
  /// In en, this message translates to:
  /// **'Masjid balance'**
  String get masjidBalance;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @moneyIn.
  ///
  /// In en, this message translates to:
  /// **'Money in'**
  String get moneyIn;

  /// No description provided for @moneyOut.
  ///
  /// In en, this message translates to:
  /// **'Money out'**
  String get moneyOut;

  /// No description provided for @namazTimesNotSet.
  ///
  /// In en, this message translates to:
  /// **'Namaz times are not set yet.'**
  String get namazTimesNotSet;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @nextNamaz.
  ///
  /// In en, this message translates to:
  /// **'Next namaz'**
  String get nextNamaz;

  /// No description provided for @notVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get notVerified;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @passwordsDiffer.
  ///
  /// In en, this message translates to:
  /// **'The two passwords are not the same.'**
  String get passwordsDiffer;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @prayerJumma.
  ///
  /// In en, this message translates to:
  /// **'Jumma'**
  String get prayerJumma;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerZuhr.
  ///
  /// In en, this message translates to:
  /// **'Zuhr'**
  String get prayerZuhr;

  /// No description provided for @repeatNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password again'**
  String get repeatNewPassword;

  /// No description provided for @roleCommittee.
  ///
  /// In en, this message translates to:
  /// **'Committee'**
  String get roleCommittee;

  /// No description provided for @roleImam.
  ///
  /// In en, this message translates to:
  /// **'Imam'**
  String get roleImam;

  /// No description provided for @roleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get roleMember;

  /// No description provided for @roleSuperAdmin.
  ///
  /// In en, this message translates to:
  /// **'Super admin'**
  String get roleSuperAdmin;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @setTimes.
  ///
  /// In en, this message translates to:
  /// **'Set times'**
  String get setTimes;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @superAdmin.
  ///
  /// In en, this message translates to:
  /// **'Super admin'**
  String get superAdmin;

  /// No description provided for @tabDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get tabDashboard;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabMasjids.
  ///
  /// In en, this message translates to:
  /// **'Masjids'**
  String get tabMasjids;

  /// No description provided for @tabMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get tabMoney;

  /// No description provided for @tabMyPayments.
  ///
  /// In en, this message translates to:
  /// **'My payments'**
  String get tabMyPayments;

  /// No description provided for @tabNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get tabNews;

  /// No description provided for @tabPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get tabPeople;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @tabProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get tabProjects;

  /// No description provided for @tabRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get tabRequests;

  /// No description provided for @tabTimes.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get tabTimes;

  /// No description provided for @tabUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get tabUsers;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @youLeftTheMasjid.
  ///
  /// In en, this message translates to:
  /// **'You left the masjid'**
  String get youLeftTheMasjid;

  /// No description provided for @inHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {hours} h {minutes} min'**
  String inHoursMinutes(int hours, int minutes);

  /// No description provided for @inMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {minutes} min'**
  String inMinutes(int minutes);

  /// No description provided for @nextNamazSpoken.
  ///
  /// In en, this message translates to:
  /// **'Next namaz: {prayer} at {time}, {countdown}'**
  String nextNamazSpoken(String prayer, String time, String countdown);

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least {count} letters or numbers.'**
  String passwordTooShort(int count);

  /// No description provided for @youLeft.
  ///
  /// In en, this message translates to:
  /// **'You left {masjid}'**
  String youLeft(String masjid);

  /// No description provided for @addFirstNews.
  ///
  /// In en, this message translates to:
  /// **'Add the first news'**
  String get addFirstNews;

  /// No description provided for @addNews.
  ///
  /// In en, this message translates to:
  /// **'Add news'**
  String get addNews;

  /// No description provided for @changed.
  ///
  /// In en, this message translates to:
  /// **'Changed'**
  String get changed;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteNewsPoint.
  ///
  /// In en, this message translates to:
  /// **'Nobody will see this news any more.'**
  String get deleteNewsPoint;

  /// No description provided for @deleteNewsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this news?'**
  String get deleteNewsQuestion;

  /// No description provided for @dictationTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: tap the microphone on your keyboard to speak instead of typing.'**
  String get dictationTip;

  /// No description provided for @editNews.
  ///
  /// In en, this message translates to:
  /// **'Edit news'**
  String get editNews;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @leaveWithoutSaving.
  ///
  /// In en, this message translates to:
  /// **'Leave without saving?'**
  String get leaveWithoutSaving;

  /// No description provided for @leaveWithoutSavingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveWithoutSavingConfirm;

  /// No description provided for @minusFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes earlier'**
  String get minusFiveMinutes;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @newsDeleted.
  ///
  /// In en, this message translates to:
  /// **'News deleted'**
  String get newsDeleted;

  /// No description provided for @newsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load news'**
  String get newsLoadFailed;

  /// No description provided for @newsMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get newsMessage;

  /// No description provided for @newsPublished.
  ///
  /// In en, this message translates to:
  /// **'News published'**
  String get newsPublished;

  /// No description provided for @newsTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get newsTitle;

  /// No description provided for @noNewsYet.
  ///
  /// In en, this message translates to:
  /// **'No news yet'**
  String get noNewsYet;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @plusFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes later'**
  String get plusFiveMinutes;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @setTime.
  ///
  /// In en, this message translates to:
  /// **'Set time'**
  String get setTime;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @timesSaved.
  ///
  /// In en, this message translates to:
  /// **'Times saved'**
  String get timesSaved;

  /// No description provided for @addGiver.
  ///
  /// In en, this message translates to:
  /// **'Add giver'**
  String get addGiver;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get addNote;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @cancelEntry.
  ///
  /// In en, this message translates to:
  /// **'Cancel entry'**
  String get cancelEntry;

  /// No description provided for @cancelEntryPoint.
  ///
  /// In en, this message translates to:
  /// **'The amount is taken out of the masjid\'s totals. The entry stays in the list, marked cancelled.'**
  String get cancelEntryPoint;

  /// No description provided for @cancelEntryQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cancel this entry?'**
  String get cancelEntryQuestion;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @catCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get catCleaning;

  /// No description provided for @catConstruction.
  ///
  /// In en, this message translates to:
  /// **'Construction'**
  String get catConstruction;

  /// No description provided for @catConstructionFund.
  ///
  /// In en, this message translates to:
  /// **'Building fund'**
  String get catConstructionFund;

  /// No description provided for @catDonationBox.
  ///
  /// In en, this message translates to:
  /// **'Donation box'**
  String get catDonationBox;

  /// No description provided for @catElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get catElectricity;

  /// No description provided for @catImamSalary.
  ///
  /// In en, this message translates to:
  /// **'Imam salary'**
  String get catImamSalary;

  /// No description provided for @catJumma.
  ///
  /// In en, this message translates to:
  /// **'Jumma'**
  String get catJumma;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @catRamadanFund.
  ///
  /// In en, this message translates to:
  /// **'Ramadan fund'**
  String get catRamadanFund;

  /// No description provided for @catRepair.
  ///
  /// In en, this message translates to:
  /// **'Repair'**
  String get catRepair;

  /// No description provided for @catSadaqah.
  ///
  /// In en, this message translates to:
  /// **'Sadaqah'**
  String get catSadaqah;

  /// No description provided for @catWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get catWater;

  /// No description provided for @catZakat.
  ///
  /// In en, this message translates to:
  /// **'Zakat'**
  String get catZakat;

  /// No description provided for @givers.
  ///
  /// In en, this message translates to:
  /// **'Givers'**
  String get givers;

  /// No description provided for @howMuch.
  ///
  /// In en, this message translates to:
  /// **'How much?'**
  String get howMuch;

  /// No description provided for @moneyInSaved.
  ///
  /// In en, this message translates to:
  /// **'Money in saved'**
  String get moneyInSaved;

  /// No description provided for @moneyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the money totals.'**
  String get moneyLoadFailed;

  /// No description provided for @moneyOutSaved.
  ///
  /// In en, this message translates to:
  /// **'Money out saved'**
  String get moneyOutSaved;

  /// No description provided for @noGiversYet.
  ///
  /// In en, this message translates to:
  /// **'No givers yet'**
  String get noGiversYet;

  /// No description provided for @noMoneyInYet.
  ///
  /// In en, this message translates to:
  /// **'No money in yet'**
  String get noMoneyInYet;

  /// No description provided for @noMoneyOutYet.
  ///
  /// In en, this message translates to:
  /// **'No money out yet'**
  String get noMoneyOutYet;

  /// No description provided for @nothingMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get nothingMatches;

  /// No description provided for @payCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get payCash;

  /// No description provided for @payOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get payOnline;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneOptional;

  /// No description provided for @pickAnother.
  ///
  /// In en, this message translates to:
  /// **'Pick someone else'**
  String get pickAnother;

  /// No description provided for @pickMember.
  ///
  /// In en, this message translates to:
  /// **'Pick a member'**
  String get pickMember;

  /// No description provided for @someoneElse.
  ///
  /// In en, this message translates to:
  /// **'Not a member'**
  String get someoneElse;

  /// No description provided for @whatFor.
  ///
  /// In en, this message translates to:
  /// **'What for?'**
  String get whatFor;

  /// No description provided for @whatKind.
  ///
  /// In en, this message translates to:
  /// **'What kind?'**
  String get whatKind;

  /// No description provided for @whoGave.
  ///
  /// In en, this message translates to:
  /// **'Who gave?'**
  String get whoGave;

  /// No description provided for @aboutProjectOptional.
  ///
  /// In en, this message translates to:
  /// **'About the project (optional)'**
  String get aboutProjectOptional;

  /// No description provided for @addFirstProject.
  ///
  /// In en, this message translates to:
  /// **'Add the first project'**
  String get addFirstProject;

  /// No description provided for @addProject.
  ///
  /// In en, this message translates to:
  /// **'Add project'**
  String get addProject;

  /// No description provided for @amountPerFamilyHelp.
  ///
  /// In en, this message translates to:
  /// **'How much each family pays this month.'**
  String get amountPerFamilyHelp;

  /// No description provided for @cancelProject.
  ///
  /// In en, this message translates to:
  /// **'Cancel project'**
  String get cancelProject;

  /// No description provided for @cancelProjectPoint.
  ///
  /// In en, this message translates to:
  /// **'The project stops. Money already given stays recorded.'**
  String get cancelProjectPoint;

  /// No description provided for @cancelProjectQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cancel this project?'**
  String get cancelProjectQuestion;

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collected;

  /// No description provided for @datesAndStatus.
  ///
  /// In en, this message translates to:
  /// **'Dates and status'**
  String get datesAndStatus;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @editProject.
  ///
  /// In en, this message translates to:
  /// **'Edit project'**
  String get editProject;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endDate;

  /// No description provided for @endDateOptional.
  ///
  /// In en, this message translates to:
  /// **'End date (optional)'**
  String get endDateOptional;

  /// No description provided for @families.
  ///
  /// In en, this message translates to:
  /// **'Families'**
  String get families;

  /// No description provided for @moneyNeeded.
  ///
  /// In en, this message translates to:
  /// **'Money needed'**
  String get moneyNeeded;

  /// No description provided for @moneyNeededHelp.
  ///
  /// In en, this message translates to:
  /// **'The total the project needs. Leave it empty if not known.'**
  String get moneyNeededHelp;

  /// No description provided for @mySalary.
  ///
  /// In en, this message translates to:
  /// **'My salary payments'**
  String get mySalary;

  /// No description provided for @noFamiliesYet.
  ///
  /// In en, this message translates to:
  /// **'No families yet'**
  String get noFamiliesYet;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get noPaymentsYet;

  /// No description provided for @noProjectsYet.
  ///
  /// In en, this message translates to:
  /// **'No projects yet'**
  String get noProjectsYet;

  /// No description provided for @noSalaryHistory.
  ///
  /// In en, this message translates to:
  /// **'No salary payments yet'**
  String get noSalaryHistory;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @projectAdded.
  ///
  /// In en, this message translates to:
  /// **'Project added'**
  String get projectAdded;

  /// No description provided for @projectCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get projectCancelled;

  /// No description provided for @projectCancelledDone.
  ///
  /// In en, this message translates to:
  /// **'Project cancelled'**
  String get projectCancelledDone;

  /// No description provided for @projectCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get projectCompleted;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectName;

  /// No description provided for @projectOngoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get projectOngoing;

  /// No description provided for @projectPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get projectPlanned;

  /// No description provided for @raiseAmount.
  ///
  /// In en, this message translates to:
  /// **'Raise amount'**
  String get raiseAmount;

  /// No description provided for @salaryMonthStarted.
  ///
  /// In en, this message translates to:
  /// **'Salary month started'**
  String get salaryMonthStarted;

  /// No description provided for @salaryNotPaid.
  ///
  /// In en, this message translates to:
  /// **'Not paid'**
  String get salaryNotPaid;

  /// No description provided for @salaryNotStarted.
  ///
  /// In en, this message translates to:
  /// **'This month\'s salary is not started'**
  String get salaryNotStarted;

  /// No description provided for @salaryPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get salaryPaid;

  /// No description provided for @salaryPartlyPaid.
  ///
  /// In en, this message translates to:
  /// **'Part paid'**
  String get salaryPartlyPaid;

  /// No description provided for @salaryPaymentSaved.
  ///
  /// In en, this message translates to:
  /// **'Payment saved'**
  String get salaryPaymentSaved;

  /// No description provided for @searchProjects.
  ///
  /// In en, this message translates to:
  /// **'Search projects'**
  String get searchProjects;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startDate;

  /// No description provided for @startDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Start date (optional)'**
  String get startDateOptional;

  /// No description provided for @startSalaryMonth.
  ///
  /// In en, this message translates to:
  /// **'Start month'**
  String get startSalaryMonth;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @amountCanOnlyGoUp.
  ///
  /// In en, this message translates to:
  /// **'The amount can only go up (now {amount}).'**
  String amountCanOnlyGoUp(String amount);

  /// No description provided for @collectedOf.
  ///
  /// In en, this message translates to:
  /// **'{collected} of {target}'**
  String collectedOf(String collected, String target);

  /// No description provided for @collectedSoFar.
  ///
  /// In en, this message translates to:
  /// **'{amount} collected'**
  String collectedSoFar(String amount);

  /// No description provided for @notPaidCount.
  ///
  /// In en, this message translates to:
  /// **'{count} not paid'**
  String notPaidCount(int count);

  /// No description provided for @outOf.
  ///
  /// In en, this message translates to:
  /// **'of {amount}'**
  String outOf(String amount);

  /// No description provided for @paidCount.
  ///
  /// In en, this message translates to:
  /// **'{count} paid'**
  String paidCount(int count);

  /// No description provided for @paidOutOf.
  ///
  /// In en, this message translates to:
  /// **'Paid {paid} of {expected}'**
  String paidOutOf(String paid, String expected);

  /// No description provided for @partlyPaidCount.
  ///
  /// In en, this message translates to:
  /// **'{count} part paid'**
  String partlyPaidCount(int count);

  /// No description provided for @payMoreThanDue.
  ///
  /// In en, this message translates to:
  /// **'This is more than what is due ({amount}).'**
  String payMoreThanDue(String amount);

  /// No description provided for @perFamily.
  ///
  /// In en, this message translates to:
  /// **'{amount} per family'**
  String perFamily(String amount);

  /// No description provided for @salarySpoken.
  ///
  /// In en, this message translates to:
  /// **'Imam salary: {collected} collected of {expected}. {due} still to pay.'**
  String salarySpoken(String collected, String expected, String due);

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'{amount} spent'**
  String spent(String amount);

  /// No description provided for @stillNeeded.
  ///
  /// In en, this message translates to:
  /// **'{amount} still needed'**
  String stillNeeded(String amount);

  /// No description provided for @stillToPay.
  ///
  /// In en, this message translates to:
  /// **'{amount} still to pay'**
  String stillToPay(String amount);

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Turn on again'**
  String get activate;

  /// No description provided for @activateQuestion.
  ///
  /// In en, this message translates to:
  /// **'Let this person use the app again?'**
  String get activateQuestion;

  /// No description provided for @addPerson.
  ///
  /// In en, this message translates to:
  /// **'Add person'**
  String get addPerson;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get deactivate;

  /// No description provided for @deactivatePointHistory.
  ///
  /// In en, this message translates to:
  /// **'Their payments and history stay saved.'**
  String get deactivatePointHistory;

  /// No description provided for @deactivatePointLogin.
  ///
  /// In en, this message translates to:
  /// **'They cannot log in to the app.'**
  String get deactivatePointLogin;

  /// No description provided for @deactivateQuestion.
  ///
  /// In en, this message translates to:
  /// **'Turn off this person?'**
  String get deactivateQuestion;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @donations.
  ///
  /// In en, this message translates to:
  /// **'Donations'**
  String get donations;

  /// No description provided for @editPerson.
  ///
  /// In en, this message translates to:
  /// **'Edit person'**
  String get editPerson;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @familyHeadHelp.
  ///
  /// In en, this message translates to:
  /// **'The family head pays the imam salary for the family.'**
  String get familyHeadHelp;

  /// No description provided for @familyMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 family member} other{{count} family members}}'**
  String familyMembersCount(int count);

  /// No description provided for @familyMembersOptional.
  ///
  /// In en, this message translates to:
  /// **'Family members (optional)'**
  String get familyMembersOptional;

  /// No description provided for @masjidId.
  ///
  /// In en, this message translates to:
  /// **'Masjid ID'**
  String get masjidId;

  /// No description provided for @myPaymentsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your payments.'**
  String get myPaymentsLoadFailed;

  /// No description provided for @noFamilyForRole.
  ///
  /// In en, this message translates to:
  /// **'Only members have a family here.'**
  String get noFamilyForRole;

  /// No description provided for @noGiftsYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing given yet'**
  String get noGiftsYet;

  /// No description provided for @noPeopleYet.
  ///
  /// In en, this message translates to:
  /// **'No people yet'**
  String get noPeopleYet;

  /// No description provided for @peopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String peopleCount(int count);

  /// No description provided for @peopleMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get peopleMembers;

  /// No description provided for @personAdded.
  ///
  /// In en, this message translates to:
  /// **'Person added'**
  String get personAdded;

  /// No description provided for @personCanLoginWithCode.
  ///
  /// In en, this message translates to:
  /// **'They can log in with their phone number and a code.'**
  String get personCanLoginWithCode;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @roleAndFamily.
  ///
  /// In en, this message translates to:
  /// **'Role and family'**
  String get roleAndFamily;

  /// No description provided for @salaryStillDue.
  ///
  /// In en, this message translates to:
  /// **'{amount} salary still to pay'**
  String salaryStillDue(String amount);

  /// No description provided for @temporaryPasswordHelp.
  ///
  /// In en, this message translates to:
  /// **'Give this password to the person. They can change it later.'**
  String get temporaryPasswordHelp;

  /// No description provided for @whoIsIt.
  ///
  /// In en, this message translates to:
  /// **'Who is it?'**
  String get whoIsIt;

  /// No description provided for @youGaveInTotal.
  ///
  /// In en, this message translates to:
  /// **'You gave in total'**
  String get youGaveInTotal;

  /// No description provided for @aboutMasjid.
  ///
  /// In en, this message translates to:
  /// **'About the masjid'**
  String get aboutMasjid;

  /// No description provided for @allRoles.
  ///
  /// In en, this message translates to:
  /// **'All roles'**
  String get allRoles;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @approveHelp.
  ///
  /// In en, this message translates to:
  /// **'This adds the masjid, its imam, and its committee.'**
  String get approveHelp;

  /// No description provided for @approveQuestion.
  ///
  /// In en, this message translates to:
  /// **'Approve this masjid?'**
  String get approveQuestion;

  /// No description provided for @cannotApprove.
  ///
  /// In en, this message translates to:
  /// **'Cannot approve'**
  String get cannotApprove;

  /// No description provided for @changeRoles.
  ///
  /// In en, this message translates to:
  /// **'Change roles'**
  String get changeRoles;

  /// No description provided for @changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get changeStatus;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go home'**
  String get goHome;

  /// No description provided for @joinedOn.
  ///
  /// In en, this message translates to:
  /// **'Joined on'**
  String get joinedOn;

  /// No description provided for @masjid.
  ///
  /// In en, this message translates to:
  /// **'Masjid'**
  String get masjid;

  /// No description provided for @noMasjids.
  ///
  /// In en, this message translates to:
  /// **'No masjids'**
  String get noMasjids;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests'**
  String get noRequests;

  /// No description provided for @noRequestsWaiting.
  ///
  /// In en, this message translates to:
  /// **'No requests waiting'**
  String get noRequestsWaiting;

  /// No description provided for @noUsers.
  ///
  /// In en, this message translates to:
  /// **'No users'**
  String get noUsers;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @pageNotFoundHelp.
  ///
  /// In en, this message translates to:
  /// **'This link is old or wrong.'**
  String get pageNotFoundHelp;

  /// No description provided for @person.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get person;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @pickToSeeDetails.
  ///
  /// In en, this message translates to:
  /// **'Pick one from the list to see it here.'**
  String get pickToSeeDetails;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @reasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get reasonOptional;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @rejectQuestion.
  ///
  /// In en, this message translates to:
  /// **'Reject this request?'**
  String get rejectQuestion;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @requestApproved.
  ///
  /// In en, this message translates to:
  /// **'Request approved'**
  String get requestApproved;

  /// No description provided for @requestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected'**
  String get requestRejected;

  /// No description provided for @requester.
  ///
  /// In en, this message translates to:
  /// **'Who asked'**
  String get requester;

  /// No description provided for @requestsWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 request waiting} other{{count} requests waiting}}'**
  String requestsWaiting(int count);

  /// No description provided for @rolesChanged.
  ///
  /// In en, this message translates to:
  /// **'Roles changed'**
  String get rolesChanged;

  /// No description provided for @searchMasjids.
  ///
  /// In en, this message translates to:
  /// **'Search masjid or place'**
  String get searchMasjids;

  /// No description provided for @searchRequests.
  ///
  /// In en, this message translates to:
  /// **'Search masjid, place, or phone'**
  String get searchRequests;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search name, phone, or email'**
  String get searchUsers;

  /// No description provided for @sentOn.
  ///
  /// In en, this message translates to:
  /// **'Sent on'**
  String get sentOn;

  /// No description provided for @statusChanged.
  ///
  /// In en, this message translates to:
  /// **'Status changed'**
  String get statusChanged;

  /// No description provided for @statusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get statusSuspended;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome message'**
  String get welcomeMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
