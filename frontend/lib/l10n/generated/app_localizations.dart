import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('ta'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Heal Gui AI'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'AI Powered Smart Healthcare'**
  String get tagline;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

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

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get createNewAccount;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Login Successful'**
  String get loginSuccessful;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRate;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroup;

  /// No description provided for @familyHistory.
  ///
  /// In en, this message translates to:
  /// **'Family History'**
  String get familyHistory;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @diabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes'**
  String get diabetes;

  /// No description provided for @smoking.
  ///
  /// In en, this message translates to:
  /// **'Smoking'**
  String get smoking;

  /// No description provided for @alcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get alcohol;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @sleepHours.
  ///
  /// In en, this message translates to:
  /// **'Sleep Hours'**
  String get sleepHours;

  /// No description provided for @waterIntake.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get waterIntake;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @preferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get preferNotToSay;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @formerSmoker.
  ///
  /// In en, this message translates to:
  /// **'Former smoker'**
  String get formerSmoker;

  /// No description provided for @currentSmoker.
  ///
  /// In en, this message translates to:
  /// **'Current smoker'**
  String get currentSmoker;

  /// No description provided for @occasionally.
  ///
  /// In en, this message translates to:
  /// **'Occasionally'**
  String get occasionally;

  /// No description provided for @frequently.
  ///
  /// In en, this message translates to:
  /// **'Frequently'**
  String get frequently;

  /// No description provided for @oneTwoDaysWeek.
  ///
  /// In en, this message translates to:
  /// **'1-2 days/week'**
  String get oneTwoDaysWeek;

  /// No description provided for @threeFiveDaysWeek.
  ///
  /// In en, this message translates to:
  /// **'3-5 days/week'**
  String get threeFiveDaysWeek;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @helloJohn.
  ///
  /// In en, this message translates to:
  /// **'Hello John'**
  String get helloJohn;

  /// No description provided for @healthScore.
  ///
  /// In en, this message translates to:
  /// **'Health score'**
  String get healthScore;

  /// No description provided for @excellentBalance.
  ///
  /// In en, this message translates to:
  /// **'Excellent balance'**
  String get excellentBalance;

  /// No description provided for @keepWalkingHydrate.
  ///
  /// In en, this message translates to:
  /// **'Keep walking and hydrate today'**
  String get keepWalkingHydrate;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @biologicalAge.
  ///
  /// In en, this message translates to:
  /// **'Biological Age'**
  String get biologicalAge;

  /// No description provided for @twoYearsYounger.
  ///
  /// In en, this message translates to:
  /// **'2 years younger'**
  String get twoYearsYounger;

  /// No description provided for @bpm.
  ///
  /// In en, this message translates to:
  /// **'bpm'**
  String get bpm;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @goalThreeL.
  ///
  /// In en, this message translates to:
  /// **'Goal 3L'**
  String get goalThreeL;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @burned.
  ///
  /// In en, this message translates to:
  /// **'Burned'**
  String get burned;

  /// No description provided for @dailyLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get dailyLabel;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// No description provided for @aiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get aiChat;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'John'**
  String get profileName;

  /// No description provided for @miniGames.
  ///
  /// In en, this message translates to:
  /// **'Mini Games'**
  String get miniGames;

  /// No description provided for @medicalReports.
  ///
  /// In en, this message translates to:
  /// **'Medical Reports'**
  String get medicalReports;

  /// No description provided for @healthAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Health Analysis'**
  String get healthAnalysis;

  /// No description provided for @futureHealth.
  ///
  /// In en, this message translates to:
  /// **'Future Health'**
  String get futureHealth;

  /// No description provided for @diet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get diet;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @eyeTest.
  ///
  /// In en, this message translates to:
  /// **'Eye Test'**
  String get eyeTest;

  /// No description provided for @memoryTest.
  ///
  /// In en, this message translates to:
  /// **'Memory Test'**
  String get memoryTest;

  /// No description provided for @brainSpeed.
  ///
  /// In en, this message translates to:
  /// **'Brain Speed'**
  String get brainSpeed;

  /// No description provided for @reactionTest.
  ///
  /// In en, this message translates to:
  /// **'Reaction Test'**
  String get reactionTest;

  /// No description provided for @colorBlindTest.
  ///
  /// In en, this message translates to:
  /// **'Color Blind Test'**
  String get colorBlindTest;

  /// No description provided for @hearingTest.
  ///
  /// In en, this message translates to:
  /// **'Hearing Test'**
  String get hearingTest;

  /// No description provided for @lungBreathing.
  ///
  /// In en, this message translates to:
  /// **'Lung Breathing'**
  String get lungBreathing;

  /// No description provided for @heartFitness.
  ///
  /// In en, this message translates to:
  /// **'Heart Fitness'**
  String get heartFitness;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @medicalReportUpload.
  ///
  /// In en, this message translates to:
  /// **'Medical Report Upload'**
  String get medicalReportUpload;

  /// No description provided for @uploadPdf.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF'**
  String get uploadPdf;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @previewReady.
  ///
  /// In en, this message translates to:
  /// **'Preview ready for dummy analysis'**
  String get previewReady;

  /// No description provided for @dummyAiReport.
  ///
  /// In en, this message translates to:
  /// **'Dummy AI Report'**
  String get dummyAiReport;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @vitals.
  ///
  /// In en, this message translates to:
  /// **'Vitals'**
  String get vitals;

  /// No description provided for @openAiHealthReport.
  ///
  /// In en, this message translates to:
  /// **'Open AI Health Report'**
  String get openAiHealthReport;

  /// No description provided for @aiHealthReport.
  ///
  /// In en, this message translates to:
  /// **'AI Health Report'**
  String get aiHealthReport;

  /// No description provided for @healthSummary.
  ///
  /// In en, this message translates to:
  /// **'Health Summary'**
  String get healthSummary;

  /// No description provided for @healthSummaryText.
  ///
  /// In en, this message translates to:
  /// **'Your core markers are stable with strong activity consistency.'**
  String get healthSummaryText;

  /// No description provided for @detectedRisks.
  ///
  /// In en, this message translates to:
  /// **'Detected Risks'**
  String get detectedRisks;

  /// No description provided for @detectedRisksText.
  ///
  /// In en, this message translates to:
  /// **'Low cardiovascular risk. Cholesterol needs light attention.'**
  String get detectedRisksText;

  /// No description provided for @lifestyleSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle Suggestions'**
  String get lifestyleSuggestions;

  /// No description provided for @lifestyleSuggestionsText.
  ///
  /// In en, this message translates to:
  /// **'Add two strength sessions and keep sleep above seven hours.'**
  String get lifestyleSuggestionsText;

  /// No description provided for @priorityLevel.
  ///
  /// In en, this message translates to:
  /// **'Priority Level'**
  String get priorityLevel;

  /// No description provided for @priorityLevelText.
  ///
  /// In en, this message translates to:
  /// **'Medium priority: nutrition optimization.'**
  String get priorityLevelText;

  /// No description provided for @healthyHabits.
  ///
  /// In en, this message translates to:
  /// **'Healthy Habits'**
  String get healthyHabits;

  /// No description provided for @healthyHabitsText.
  ///
  /// In en, this message translates to:
  /// **'Walking, hydration, and steady sleep are working well.'**
  String get healthyHabitsText;

  /// No description provided for @doctorRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Doctor Recommendation'**
  String get doctorRecommendation;

  /// No description provided for @doctorRecommendationText.
  ///
  /// In en, this message translates to:
  /// **'Routine annual checkup is enough unless symptoms change.'**
  String get doctorRecommendationText;

  /// No description provided for @healGuiAiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Heal Gui AI Analysis'**
  String get healGuiAiAnalysis;

  /// No description provided for @shareReport.
  ///
  /// In en, this message translates to:
  /// **'Share Report'**
  String get shareReport;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @healGuiAiAssistant.
  ///
  /// In en, this message translates to:
  /// **'Heal Gui AI Assistant'**
  String get healGuiAiAssistant;

  /// No description provided for @chatGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi John, I can explain your health score, reports, diet, and sleep.'**
  String get chatGreeting;

  /// No description provided for @chatReply.
  ///
  /// In en, this message translates to:
  /// **'Based on your current data, your Health Score is 91/100. Your BMI is normal. Continue daily walking and drink more water.'**
  String get chatReply;

  /// No description provided for @whatIsMyBmi.
  ///
  /// In en, this message translates to:
  /// **'What is my BMI?'**
  String get whatIsMyBmi;

  /// No description provided for @analyzeMyReport.
  ///
  /// In en, this message translates to:
  /// **'Analyze my report'**
  String get analyzeMyReport;

  /// No description provided for @suggestHealthyFood.
  ///
  /// In en, this message translates to:
  /// **'Suggest healthy food'**
  String get suggestHealthyFood;

  /// No description provided for @todaysWorkout.
  ///
  /// In en, this message translates to:
  /// **'Today\'s workout'**
  String get todaysWorkout;

  /// No description provided for @improveMySleep.
  ///
  /// In en, this message translates to:
  /// **'Can I improve my sleep?'**
  String get improveMySleep;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing;

  /// No description provided for @askAboutHealth.
  ///
  /// In en, this message translates to:
  /// **'Ask about your health'**
  String get askAboutHealth;

  /// No description provided for @walking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get walking;

  /// No description provided for @predict.
  ///
  /// In en, this message translates to:
  /// **'Predict'**
  String get predict;

  /// No description provided for @prediction.
  ///
  /// In en, this message translates to:
  /// **'Prediction'**
  String get prediction;

  /// No description provided for @personalizedDiet.
  ///
  /// In en, this message translates to:
  /// **'Personalized Diet'**
  String get personalizedDiet;

  /// No description provided for @targets.
  ///
  /// In en, this message translates to:
  /// **'Targets'**
  String get targets;

  /// No description provided for @dailyPlan.
  ///
  /// In en, this message translates to:
  /// **'Daily Plan'**
  String get dailyPlan;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @breakfastText.
  ///
  /// In en, this message translates to:
  /// **'Greek yogurt, berries, oats'**
  String get breakfastText;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @lunchText.
  ///
  /// In en, this message translates to:
  /// **'Quinoa bowl with paneer and greens'**
  String get lunchText;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @dinnerText.
  ///
  /// In en, this message translates to:
  /// **'Grilled protein, vegetables, lentil soup'**
  String get dinnerText;

  /// No description provided for @snacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get snacks;

  /// No description provided for @snacksText.
  ///
  /// In en, this message translates to:
  /// **'Fruit, nuts, coconut water'**
  String get snacksText;

  /// No description provided for @bmiAdvice.
  ///
  /// In en, this message translates to:
  /// **'BMI Advice'**
  String get bmiAdvice;

  /// No description provided for @bmiAdviceText.
  ///
  /// In en, this message translates to:
  /// **'Maintain current range with strength work'**
  String get bmiAdviceText;

  /// No description provided for @exerciseTips.
  ///
  /// In en, this message translates to:
  /// **'Exercise Tips'**
  String get exerciseTips;

  /// No description provided for @exerciseTipsText.
  ///
  /// In en, this message translates to:
  /// **'Walk 8k steps and add mobility'**
  String get exerciseTipsText;

  /// No description provided for @shoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingList;

  /// No description provided for @shoppingListText.
  ///
  /// In en, this message translates to:
  /// **'Leafy greens, eggs, pulses, curd, citrus'**
  String get shoppingListText;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @medicalTimeline.
  ///
  /// In en, this message translates to:
  /// **'Medical Timeline'**
  String get medicalTimeline;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @todayTimeline.
  ///
  /// In en, this message translates to:
  /// **'AI report generated'**
  String get todayTimeline;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get lastWeek;

  /// No description provided for @lastWeekTimeline.
  ///
  /// In en, this message translates to:
  /// **'Blood report analyzed'**
  String get lastWeekTimeline;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get lastMonth;

  /// No description provided for @lastMonthTimeline.
  ///
  /// In en, this message translates to:
  /// **'New walking streak achieved'**
  String get lastMonthTimeline;

  /// No description provided for @reportHistory.
  ///
  /// In en, this message translates to:
  /// **'Report History'**
  String get reportHistory;

  /// No description provided for @searchReports.
  ///
  /// In en, this message translates to:
  /// **'Search reports'**
  String get searchReports;

  /// No description provided for @bloodWorkAug.
  ///
  /// In en, this message translates to:
  /// **'Blood Work - Aug'**
  String get bloodWorkAug;

  /// No description provided for @aiHealthReportShort.
  ///
  /// In en, this message translates to:
  /// **'AI Health Report'**
  String get aiHealthReportShort;

  /// No description provided for @lipidProfile.
  ///
  /// In en, this message translates to:
  /// **'Lipid Profile'**
  String get lipidProfile;

  /// No description provided for @sleepSummary.
  ///
  /// In en, this message translates to:
  /// **'Sleep Summary'**
  String get sleepSummary;

  /// No description provided for @previousReport.
  ///
  /// In en, this message translates to:
  /// **'Previous AI and medical report'**
  String get previousReport;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @medicalDetails.
  ///
  /// In en, this message translates to:
  /// **'Medical Details'**
  String get medicalDetails;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @metric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metric;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get tamil;

  /// No description provided for @tamilWithEnglish.
  ///
  /// In en, this message translates to:
  /// **'தமிழ் (Tamil)'**
  String get tamilWithEnglish;

  /// No description provided for @noHealthDataYet.
  ///
  /// In en, this message translates to:
  /// **'No health data yet.'**
  String get noHealthDataYet;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @bloodSugar.
  ///
  /// In en, this message translates to:
  /// **'Blood Sugar'**
  String get bloodSugar;

  /// No description provided for @cholesterol.
  ///
  /// In en, this message translates to:
  /// **'Cholesterol'**
  String get cholesterol;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @slightlyHigh.
  ///
  /// In en, this message translates to:
  /// **'Slightly High'**
  String get slightlyHigh;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @futureHealthScore.
  ///
  /// In en, this message translates to:
  /// **'Future Health Score'**
  String get futureHealthScore;

  /// No description provided for @bioAge.
  ///
  /// In en, this message translates to:
  /// **'Bio Age'**
  String get bioAge;

  /// No description provided for @risk.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get risk;

  /// No description provided for @veryLow.
  ///
  /// In en, this message translates to:
  /// **'Very Low'**
  String get veryLow;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @stress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get stress;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;
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
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
