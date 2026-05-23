import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('km'),
    Locale('zh'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'AppleTech'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get wishlist;

  /// No description provided for @bag.
  ///
  /// In en, this message translates to:
  /// **'Store Selection'**
  String get bag;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @khmer.
  ///
  /// In en, this message translates to:
  /// **'Khmer'**
  String get khmer;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @yourEmail.
  ///
  /// In en, this message translates to:
  /// **'Your Email'**
  String get yourEmail;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @useAtLeast6Digits.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 digits'**
  String get useAtLeast6Digits;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet? '**
  String get dontHaveAccount;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// No description provided for @checkInbox.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox for verification code'**
  String get checkInbox;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email to receive reset instructions'**
  String get resetInstructions;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? Resend'**
  String get resend;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// Resend button text with countdown
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String resendInSeconds(int seconds);

  /// Message showing where verification code was sent
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to {email}'**
  String verificationCodeSent(String email);

  /// No description provided for @verifyInstructions.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox for verification code'**
  String get verifyInstructions;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @recentCategories.
  ///
  /// In en, this message translates to:
  /// **'Recent Categories'**
  String get recentCategories;

  /// No description provided for @theLatest.
  ///
  /// In en, this message translates to:
  /// **'The latest.'**
  String get theLatest;

  /// No description provided for @takeCloserLook.
  ///
  /// In en, this message translates to:
  /// **'Take a closer look at what is new.'**
  String get takeCloserLook;

  /// No description provided for @appleDifference.
  ///
  /// In en, this message translates to:
  /// **'Apple Difference.'**
  String get appleDifference;

  /// No description provided for @moreReasonsToShop.
  ///
  /// In en, this message translates to:
  /// **'More reasons to shop with us.'**
  String get moreReasonsToShop;

  /// No description provided for @allModels.
  ///
  /// In en, this message translates to:
  /// **'All models.'**
  String get allModels;

  /// No description provided for @browseLineup.
  ///
  /// In en, this message translates to:
  /// **'Browse our entire lineup.'**
  String get browseLineup;

  /// No description provided for @shopOneOnOne.
  ///
  /// In en, this message translates to:
  /// **'Shop one on one'**
  String get shopOneOnOne;

  /// No description provided for @getHelpChoosing.
  ///
  /// In en, this message translates to:
  /// **'Get help choosing the right device.'**
  String get getHelpChoosing;

  /// No description provided for @customizeYours.
  ///
  /// In en, this message translates to:
  /// **'Customize yours'**
  String get customizeYours;

  /// No description provided for @pickFinishes.
  ///
  /// In en, this message translates to:
  /// **'Pick finishes, storage, and bands.'**
  String get pickFinishes;

  /// No description provided for @easyDelivery.
  ///
  /// In en, this message translates to:
  /// **'Visit Planning'**
  String get easyDelivery;

  /// No description provided for @trackEveryOrder.
  ///
  /// In en, this message translates to:
  /// **'View your scheduled visits.'**
  String get trackEveryOrder;

  /// No description provided for @shopMacBook.
  ///
  /// In en, this message translates to:
  /// **'Shop MacBook'**
  String get shopMacBook;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learnMore;

  /// No description provided for @exploreUltra.
  ///
  /// In en, this message translates to:
  /// **'Explore Ultra'**
  String get exploreUltra;

  /// No description provided for @latestRelease.
  ///
  /// In en, this message translates to:
  /// **'LATEST RELEASE'**
  String get latestRelease;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// No description provided for @nameEmailProfile.
  ///
  /// In en, this message translates to:
  /// **'Name, email, and customer profile'**
  String get nameEmailProfile;

  /// No description provided for @deliveryAddresses.
  ///
  /// In en, this message translates to:
  /// **'Store Visits'**
  String get deliveryAddresses;

  /// No description provided for @defaultShipping.
  ///
  /// In en, this message translates to:
  /// **'Scheduled visits and contact details'**
  String get defaultShipping;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'saved'**
  String get saved;

  /// No description provided for @secureCheckout.
  ///
  /// In en, this message translates to:
  /// **'Plan Visit'**
  String get secureCheckout;

  /// No description provided for @requireFaceId.
  ///
  /// In en, this message translates to:
  /// **'Secure your visit reservation'**
  String get requireFaceId;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Dark mode enabled'**
  String get darkModeEnabled;

  /// No description provided for @lightModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Light mode enabled'**
  String get lightModeEnabled;

  /// No description provided for @orderUpdates.
  ///
  /// In en, this message translates to:
  /// **'Visit updates'**
  String get orderUpdates;

  /// No description provided for @deliveryAlerts.
  ///
  /// In en, this message translates to:
  /// **'Visit reminders and confirmation'**
  String get deliveryAlerts;

  /// No description provided for @offersAndNews.
  ///
  /// In en, this message translates to:
  /// **'Offers and product news'**
  String get offersAndNews;

  /// No description provided for @personalizedDeals.
  ///
  /// In en, this message translates to:
  /// **'Personalized deals, launches, and availability'**
  String get personalizedDeals;

  /// No description provided for @appleTechCareReminders.
  ///
  /// In en, this message translates to:
  /// **'AppleTech Care reminders'**
  String get appleTechCareReminders;

  /// No description provided for @coverageRenewal.
  ///
  /// In en, this message translates to:
  /// **'Coverage renewal and warranty notifications'**
  String get coverageRenewal;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @getHelpWithOrders.
  ///
  /// In en, this message translates to:
  /// **'Get help with visits and setup'**
  String get getHelpWithOrders;

  /// No description provided for @privacyAndTerms.
  ///
  /// In en, this message translates to:
  /// **'Privacy and terms'**
  String get privacyAndTerms;

  /// No description provided for @dataUse.
  ///
  /// In en, this message translates to:
  /// **'Data use and visit policy'**
  String get dataUse;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Visit History'**
  String get orderHistory;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No Visits Scheduled'**
  String get noOrdersYet;

  /// No description provided for @orderHistoryAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your visit history will appear here once you schedule a visit.'**
  String get orderHistoryAppearHere;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get allCaughtUp;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'You have no notifications right now.'**
  String get noNotifications;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search MacBook M5, iPad, iMac, RAM, SSD…'**
  String get searchHint;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for products...'**
  String get searchPlaceholder;

  /// No description provided for @emptyWishlist.
  ///
  /// In en, this message translates to:
  /// **'Nothing Saved Yet'**
  String get emptyWishlist;

  /// No description provided for @wishlistEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Products you love or want to keep track of will appear here.'**
  String get wishlistEmptyDesc;

  /// No description provided for @yourBag.
  ///
  /// In en, this message translates to:
  /// **'Items to Buy at Store'**
  String get yourBag;

  /// No description provided for @emptyBag.
  ///
  /// In en, this message translates to:
  /// **'Your selection is empty'**
  String get emptyBag;

  /// No description provided for @bagEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Add items you intend to test and buy at the store.'**
  String get bagEmptyDesc;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Estimated Tax'**
  String get tax;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Finalize Visit Selection'**
  String get checkout;
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
      <String>['en', 'km', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
