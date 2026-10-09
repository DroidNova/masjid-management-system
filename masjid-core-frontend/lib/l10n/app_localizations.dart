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
  /// **'Masjid Core'**
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
