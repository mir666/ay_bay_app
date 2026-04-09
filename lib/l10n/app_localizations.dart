import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

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
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'LogIn'**
  String get logIn;

  /// No description provided for @logIntoYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Log into your account and keep track of your money.'**
  String get logIntoYourAccount;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forget Password ?'**
  String get forgetPassword;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get submit;

  /// No description provided for @wantToOpenNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Want to open a new account?'**
  String get wantToOpenNewAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'SignUp'**
  String get signUp;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get createNewAccount;

  /// No description provided for @signUpIntro.
  ///
  /// In en, this message translates to:
  /// **'Open a new account and keep track of your money. Stay worry-free.'**
  String get signUpIntro;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get name;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account?'**
  String get haveAccount;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get noNotifications;

  /// No description provided for @makeAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get makeAllAsRead;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @openNewMonth.
  ///
  /// In en, this message translates to:
  /// **'Open new month'**
  String get openNewMonth;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// No description provided for @loan.
  ///
  /// In en, this message translates to:
  /// **'Dues Summary'**
  String get loan;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get setting;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help / FAQ'**
  String get help;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @findMonthTransaction.
  ///
  /// In en, this message translates to:
  /// **'Find month, transaction, or date...'**
  String get findMonthTransaction;

  /// No description provided for @updateTransaction.
  ///
  /// In en, this message translates to:
  /// **'Update transaction'**
  String get updateTransaction;

  /// No description provided for @addIncomeAndExpenses.
  ///
  /// In en, this message translates to:
  /// **'Add income and expenses'**
  String get addIncomeAndExpenses;

  /// No description provided for @reAdd.
  ///
  /// In en, this message translates to:
  /// **'Re-add'**
  String get reAdd;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTransaction;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @amountOfMoney.
  ///
  /// In en, this message translates to:
  /// **'Amount of money (Ex: 100+50-30*2)'**
  String get amountOfMoney;

  /// No description provided for @addMonth.
  ///
  /// In en, this message translates to:
  /// **'Add Month'**
  String get addMonth;

  /// No description provided for @budgetUpdate.
  ///
  /// In en, this message translates to:
  /// **'Balance Update'**
  String get budgetUpdate;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Balance'**
  String get monthlyBudget;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @noBudget.
  ///
  /// In en, this message translates to:
  /// **'No budget.'**
  String get noBudget;

  /// No description provided for @addNewBudget.
  ///
  /// In en, this message translates to:
  /// **'Add new budget'**
  String get addNewBudget;

  /// No description provided for @totalBudget.
  ///
  /// In en, this message translates to:
  /// **'Total budget'**
  String get totalBudget;

  /// No description provided for @newBudget.
  ///
  /// In en, this message translates to:
  /// **'New Budget'**
  String get newBudget;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @money.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get money;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @budgetAdded.
  ///
  /// In en, this message translates to:
  /// **'Budget added'**
  String get budgetAdded;

  /// No description provided for @noMonthAdded.
  ///
  /// In en, this message translates to:
  /// **'No month added'**
  String get noMonthAdded;

  /// No description provided for @wantToDeleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this transaction?'**
  String get wantToDeleteTransaction;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No Transactions'**
  String get noTransactions;

  /// No description provided for @monthlyAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Monthly Analysis'**
  String get monthlyAnalysis;

  /// No description provided for @wantToDeleteMonth.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this month?'**
  String get wantToDeleteMonth;

  /// No description provided for @monthReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly report'**
  String get monthReport;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @backUpData.
  ///
  /// In en, this message translates to:
  /// **'Back Up Data'**
  String get backUpData;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @defaultCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default Currency'**
  String get defaultCurrency;

  /// No description provided for @enableNotification.
  ///
  /// In en, this message translates to:
  /// **'Enable Notification'**
  String get enableNotification;

  /// No description provided for @enableAppLock.
  ///
  /// In en, this message translates to:
  /// **'Enable App Lock'**
  String get enableAppLock;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @currencyAndBudget.
  ///
  /// In en, this message translates to:
  /// **'Currency & Budget'**
  String get currencyAndBudget;

  /// No description provided for @dataAndBackup.
  ///
  /// In en, this message translates to:
  /// **'Data & Backup'**
  String get dataAndBackup;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @pleaseLogInFirst.
  ///
  /// In en, this message translates to:
  /// **'Please log in first!'**
  String get pleaseLogInFirst;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @appLockIsEnabled.
  ///
  /// In en, this message translates to:
  /// **'App Lock is enabled'**
  String get appLockIsEnabled;

  /// No description provided for @appLockIsDisabled.
  ///
  /// In en, this message translates to:
  /// **'App Lock is disabled'**
  String get appLockIsDisabled;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get selectMonth;

  /// No description provided for @noTransactionThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No transactions this month'**
  String get noTransactionThisMonth;

  /// No description provided for @categoryWiseAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Category-wise Analysis'**
  String get categoryWiseAnalysis;

  /// No description provided for @ayBayApp.
  ///
  /// In en, this message translates to:
  /// **'AyBay App'**
  String get ayBayApp;

  /// No description provided for @ayBayAppPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'AyBay App Privacy Policy'**
  String get ayBayAppPrivacyPolicy;

  /// No description provided for @effectiveDate.
  ///
  /// In en, this message translates to:
  /// **'Effective Date: January 2026'**
  String get effectiveDate;

  /// No description provided for @informationWeCollect.
  ///
  /// In en, this message translates to:
  /// **'Information We Collect'**
  String get informationWeCollect;

  /// No description provided for @readFullName.
  ///
  /// In en, this message translates to:
  /// **'• Full Name\n'**
  String get readFullName;

  /// No description provided for @readPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'• Phone Number\n'**
  String get readPhoneNumber;

  /// No description provided for @readProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'• Profile Picture (Avatar)\n'**
  String get readProfilePicture;

  /// No description provided for @readEmail.
  ///
  /// In en, this message translates to:
  /// **'• Email (for password reset via Firebase)\n'**
  String get readEmail;

  /// No description provided for @readTransactionsCategoriesMonthlyRecords.
  ///
  /// In en, this message translates to:
  /// **'• Transactions, categories, monthly records'**
  String get readTransactionsCategoriesMonthlyRecords;

  /// No description provided for @howWeUseYourInformation.
  ///
  /// In en, this message translates to:
  /// **'How We Use Your Information'**
  String get howWeUseYourInformation;

  /// No description provided for @readAccountCreationAndLogin.
  ///
  /// In en, this message translates to:
  /// **'• Account creation and login\n'**
  String get readAccountCreationAndLogin;

  /// No description provided for @readSavingAndRetrievingTransactions.
  ///
  /// In en, this message translates to:
  /// **'• Saving and retrieving transactions\n'**
  String get readSavingAndRetrievingTransactions;

  /// No description provided for @incomeAndExpenseAnalysis.
  ///
  /// In en, this message translates to:
  /// **'• Income & expense analysis\n'**
  String get incomeAndExpenseAnalysis;

  /// No description provided for @monthlyReportsAndSummaries.
  ///
  /// In en, this message translates to:
  /// **'• Monthly reports and summaries\n'**
  String get monthlyReportsAndSummaries;

  /// No description provided for @displayingYourProfileInformation.
  ///
  /// In en, this message translates to:
  /// **'• Displaying your profile information'**
  String get displayingYourProfileInformation;

  /// No description provided for @dataSharingAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Data Sharing & Security'**
  String get dataSharingAndSecurity;

  /// No description provided for @weNeverShareYourDataWithThirdParties.
  ///
  /// In en, this message translates to:
  /// **'• We never share your data with third parties\n'**
  String get weNeverShareYourDataWithThirdParties;

  /// No description provided for @securelyStoredInFirebaseFirestore.
  ///
  /// In en, this message translates to:
  /// **'• Securely stored in Firebase Firestore\n'**
  String get securelyStoredInFirebaseFirestore;

  /// No description provided for @accessibleOnlyByYouViaAuthentication.
  ///
  /// In en, this message translates to:
  /// **'• Accessible only by you via authentication\n'**
  String get accessibleOnlyByYouViaAuthentication;

  /// No description provided for @encryptedUsingAndAtRest.
  ///
  /// In en, this message translates to:
  /// **'• Encrypted using TLS/HTTPS and at rest'**
  String get encryptedUsingAndAtRest;

  /// No description provided for @thirdPartyServices.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Services'**
  String get thirdPartyServices;

  /// No description provided for @flutterPackagesForUIAndCharts.
  ///
  /// In en, this message translates to:
  /// **'• Flutter packages for UI & charts\n'**
  String get flutterPackagesForUIAndCharts;

  /// No description provided for @firebaseAuthenticationFirestore.
  ///
  /// In en, this message translates to:
  /// **'• Firebase Authentication & Firestore\n'**
  String get firebaseAuthenticationFirestore;

  /// No description provided for @noThirdPartyDataCollectionWithoutConsent.
  ///
  /// In en, this message translates to:
  /// **'• No third-party data collection without consent'**
  String get noThirdPartyDataCollectionWithoutConsent;

  /// No description provided for @userControl.
  ///
  /// In en, this message translates to:
  /// **'User Control'**
  String get userControl;

  /// No description provided for @editProfileAnytime.
  ///
  /// In en, this message translates to:
  /// **'• Edit profile anytime\n'**
  String get editProfileAnytime;

  /// No description provided for @addUpdateOrDeleteTransactions.
  ///
  /// In en, this message translates to:
  /// **'• Add, update, or delete transactions\n'**
  String get addUpdateOrDeleteTransactions;

  /// No description provided for @yourDataAlwaysRemainsPrivate.
  ///
  /// In en, this message translates to:
  /// **'• Your data always remains private'**
  String get yourDataAlwaysRemainsPrivate;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @monthlyReportsCanBeDownloaded.
  ///
  /// In en, this message translates to:
  /// **'• Monthly reports can be downloaded\n'**
  String get monthlyReportsCanBeDownloaded;

  /// No description provided for @reportsIncludeOnlyYourPersonalData.
  ///
  /// In en, this message translates to:
  /// **'• Reports include only your personal data'**
  String get reportsIncludeOnlyYourPersonalData;

  /// No description provided for @consent.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get consent;

  /// No description provided for @byUsingAyBayAppYouAgreeToThisPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'By using AyBay App, you agree to this Privacy Policy.\n'**
  String get byUsingAyBayAppYouAgreeToThisPrivacyPolicy;

  /// No description provided for @minimumUserAge.
  ///
  /// In en, this message translates to:
  /// **'Minimum user age: 13+'**
  String get minimumUserAge;

  /// No description provided for @latestVersionAvailableAt.
  ///
  /// In en, this message translates to:
  /// **'Latest version available at:\n'**
  String get latestVersionAvailableAt;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 AyBay App'**
  String get copyright;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact:'**
  String get contact;

  /// No description provided for @aboutAppTitle.
  ///
  /// In en, this message translates to:
  /// **'AyBay App'**
  String get aboutAppTitle;

  /// No description provided for @aboutAppDescription.
  ///
  /// In en, this message translates to:
  /// **'AyBay App helps you track your income and expenses, manage monthly budgets, and analyze your financial activities with clarity and confidence.'**
  String get aboutAppDescription;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @readCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 AyBay App\nAll rights reserved.'**
  String get readCopyright;

  /// No description provided for @helpFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpFaqTitle;

  /// No description provided for @faqAddBudgetQ.
  ///
  /// In en, this message translates to:
  /// **'How do I add a budget?'**
  String get faqAddBudgetQ;

  /// No description provided for @faqAddBudgetA.
  ///
  /// In en, this message translates to:
  /// **'Go to the Home screen and tap the + button.\nAfter first sign up, start a new month and add a budget.'**
  String get faqAddBudgetA;

  /// No description provided for @faqAddTransactionQ.
  ///
  /// In en, this message translates to:
  /// **'How do I add a new transaction?'**
  String get faqAddTransactionQ;

  /// No description provided for @faqAddTransactionA.
  ///
  /// In en, this message translates to:
  /// **'From the Home screen, tap the + button to add income or expense.'**
  String get faqAddTransactionA;

  /// No description provided for @faqMonthlyReportQ.
  ///
  /// In en, this message translates to:
  /// **'How do I view monthly reports?'**
  String get faqMonthlyReportQ;

  /// No description provided for @faqMonthlyReportA.
  ///
  /// In en, this message translates to:
  /// **'Select a month from the month list to view monthly summaries.'**
  String get faqMonthlyReportA;

  /// No description provided for @faqEditProfileQ.
  ///
  /// In en, this message translates to:
  /// **'How do I edit my profile?'**
  String get faqEditProfileQ;

  /// No description provided for @faqEditProfileA.
  ///
  /// In en, this message translates to:
  /// **'Go to the Profile screen and tap the Edit button.'**
  String get faqEditProfileA;

  /// No description provided for @faqDataSafeQ.
  ///
  /// In en, this message translates to:
  /// **'Is my financial data safe?'**
  String get faqDataSafeQ;

  /// No description provided for @faqDataSafeA.
  ///
  /// In en, this message translates to:
  /// **'Yes. Your data is securely stored in Firebase and only accessible by you.'**
  String get faqDataSafeA;

  /// No description provided for @faqContactQ.
  ///
  /// In en, this message translates to:
  /// **'How do I contact support?'**
  String get faqContactQ;

  /// No description provided for @faqContactA.
  ///
  /// In en, this message translates to:
  /// **'Email us at:\nfarhanaakter10506264robi@gmail.com'**
  String get faqContactA;

  /// No description provided for @category_salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get category_salary;

  /// No description provided for @category_gift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get category_gift;

  /// No description provided for @category_tuition.
  ///
  /// In en, this message translates to:
  /// **'Tuition'**
  String get category_tuition;

  /// No description provided for @category_bonus.
  ///
  /// In en, this message translates to:
  /// **'Bonuses'**
  String get category_bonus;

  /// No description provided for @category_business.
  ///
  /// In en, this message translates to:
  /// **'Business Income'**
  String get category_business;

  /// No description provided for @category_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get category_food;

  /// No description provided for @category_transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get category_transport;

  /// No description provided for @category_shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get category_shopping;

  /// No description provided for @category_electric_bill.
  ///
  /// In en, this message translates to:
  /// **'Electric Bill'**
  String get category_electric_bill;

  /// No description provided for @category_net_bill.
  ///
  /// In en, this message translates to:
  /// **'Net Bill'**
  String get category_net_bill;

  /// No description provided for @category_gas_bill.
  ///
  /// In en, this message translates to:
  /// **'Gas Bill'**
  String get category_gas_bill;

  /// No description provided for @category_bazaar.
  ///
  /// In en, this message translates to:
  /// **'Bazaar'**
  String get category_bazaar;

  /// No description provided for @category_hospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get category_hospital;

  /// No description provided for @category_school.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get category_school;

  /// No description provided for @category_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get category_other;

  /// No description provided for @category_describe_other.
  ///
  /// In en, this message translates to:
  /// **'Enter a description of the expense.'**
  String get category_describe_other;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @versionNumber.
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get versionNumber;

  /// No description provided for @personName.
  ///
  /// In en, this message translates to:
  /// **'Person Name'**
  String get personName;

  /// No description provided for @debt.
  ///
  /// In en, this message translates to:
  /// **'Payable'**
  String get debt;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Receivable'**
  String get due;

  /// No description provided for @totalDebt.
  ///
  /// In en, this message translates to:
  /// **'Total Debt'**
  String get totalDebt;

  /// No description provided for @totalDue.
  ///
  /// In en, this message translates to:
  /// **'Total Due'**
  String get totalDue;

  /// No description provided for @editDebtDue.
  ///
  /// In en, this message translates to:
  /// **'Edit Debt/Due'**
  String get editDebtDue;

  /// No description provided for @newDebtDue.
  ///
  /// In en, this message translates to:
  /// **'New Debt/Due'**
  String get newDebtDue;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @confirmToDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmToDelete;

  /// No description provided for @wantToDeleteThisDebtDue.
  ///
  /// In en, this message translates to:
  /// **'Want to Delete Debt/Due?'**
  String get wantToDeleteThisDebtDue;

  /// No description provided for @saveMoney.
  ///
  /// In en, this message translates to:
  /// **'Save Money'**
  String get saveMoney;

  /// No description provided for @logout_success.
  ///
  /// In en, this message translates to:
  /// **'Successfully logged out'**
  String get logout_success;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @deleteTheTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete The Transaction'**
  String get deleteTheTransaction;

  /// No description provided for @thisIsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'This Is Last Month'**
  String get thisIsLastMonth;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **''**
  String get info;

  /// No description provided for @noMonth.
  ///
  /// In en, this message translates to:
  /// **'No data for previous months'**
  String get noMonth;

  /// No description provided for @monthDeleted.
  ///
  /// In en, this message translates to:
  /// **'Month Deleted'**
  String get monthDeleted;

  /// No description provided for @updateTotalBalance.
  ///
  /// In en, this message translates to:
  /// **'Update Total Balance'**
  String get updateTotalBalance;

  /// No description provided for @addANewMonth.
  ///
  /// In en, this message translates to:
  /// **'Add A New Month'**
  String get addANewMonth;

  /// No description provided for @thisMonthAccountIsAlreadyOpen.
  ///
  /// In en, this message translates to:
  /// **'This month\'s account is already open'**
  String get thisMonthAccountIsAlreadyOpen;

  /// No description provided for @alreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Already Exists'**
  String get alreadyExists;

  /// No description provided for @categorySelect.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY SELECT'**
  String get categorySelect;

  /// No description provided for @enterTheCorrectAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter the correct amount'**
  String get enterTheCorrectAmount;

  /// No description provided for @selectACategory.
  ///
  /// In en, this message translates to:
  /// **'Select A Category'**
  String get selectACategory;

  /// No description provided for @writeACategoryName.
  ///
  /// In en, this message translates to:
  /// **'Write A Category Name'**
  String get writeACategoryName;

  /// No description provided for @successfullyAddYourTransaction.
  ///
  /// In en, this message translates to:
  /// **'Transaction added successfully'**
  String get successfullyAddYourTransaction;

  /// No description provided for @onlyBalance.
  ///
  /// In en, this message translates to:
  /// **'@balance'**
  String get onlyBalance;

  /// No description provided for @onlySettingDefaultCurrency.
  ///
  /// In en, this message translates to:
  /// **'@defaultCurrency'**
  String get onlySettingDefaultCurrency;

  /// No description provided for @balanceAmount.
  ///
  /// In en, this message translates to:
  /// **'@defaultCurrency @balance'**
  String get balanceAmount;

  /// No description provided for @incomeAmount.
  ///
  /// In en, this message translates to:
  /// **'@income @defaultCurrency'**
  String get incomeAmount;

  /// No description provided for @expenseAmount.
  ///
  /// In en, this message translates to:
  /// **'@expense @defaultCurrency'**
  String get expenseAmount;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogout;

  /// No description provided for @wantToConfirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get wantToConfirmLogout;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @appLockPasswordSet.
  ///
  /// In en, this message translates to:
  /// **'App Lock password set'**
  String get appLockPasswordSet;

  /// No description provided for @noTransactionsInThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No transactions in this month'**
  String get noTransactionsInThisMonth;

  /// No description provided for @accountOpen.
  ///
  /// In en, this message translates to:
  /// **'Account Open:'**
  String get accountOpen;
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
