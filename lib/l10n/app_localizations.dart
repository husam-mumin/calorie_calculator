import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Patient'**
  String get appTitle;

  /// No description provided for @auth_login_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get auth_login_title;

  /// No description provided for @auth_login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get auth_login_subtitle;

  /// No description provided for @auth_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get auth_email_label;

  /// No description provided for @auth_email_hint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get auth_email_hint;

  /// No description provided for @auth_password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password_label;

  /// No description provided for @auth_password_show.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get auth_password_show;

  /// No description provided for @auth_password_hide.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get auth_password_hide;

  /// No description provided for @auth_remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get auth_remember_me;

  /// No description provided for @auth_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get auth_forgot_password;

  /// No description provided for @auth_sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get auth_sign_in;

  /// No description provided for @auth_signing_in.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get auth_signing_in;

  /// No description provided for @auth_no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get auth_no_account;

  /// No description provided for @auth_create_one.
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get auth_create_one;

  /// No description provided for @auth_invalid_credentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get auth_invalid_credentials;

  /// No description provided for @auth_logged_in.
  ///
  /// In en, this message translates to:
  /// **'Logged in'**
  String get auth_logged_in;

  /// No description provided for @auth_signup_title.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get auth_signup_title;

  /// No description provided for @auth_signup_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get auth_signup_subtitle;

  /// No description provided for @auth_full_name_label.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get auth_full_name_label;

  /// No description provided for @auth_confirm_password_label.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get auth_confirm_password_label;

  /// No description provided for @auth_create_account.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get auth_create_account;

  /// No description provided for @auth_creating.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get auth_creating;

  /// No description provided for @auth_already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get auth_already_have_account;

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login;

  /// No description provided for @auth_account_created.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get auth_account_created;

  /// No description provided for @auth_email_in_use.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get auth_email_in_use;

  /// No description provided for @auth_failed_create.
  ///
  /// In en, this message translates to:
  /// **'Failed to create account'**
  String get auth_failed_create;

  /// No description provided for @auth_unexpected_error.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error'**
  String get auth_unexpected_error;

  /// No description provided for @form_email_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get form_email_required;

  /// No description provided for @form_email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get form_email_invalid;

  /// No description provided for @form_password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get form_password_required;

  /// No description provided for @form_password_min.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get form_password_min;

  /// No description provided for @form_name_required.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get form_name_required;

  /// No description provided for @form_confirm_required.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get form_confirm_required;

  /// No description provided for @form_passwords_no_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get form_passwords_no_match;

  /// No description provided for @add_meal_title.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get add_meal_title;

  /// No description provided for @field_meal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get field_meal;

  /// No description provided for @meal_breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get meal_breakfast;

  /// No description provided for @meal_lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get meal_lunch;

  /// No description provided for @meal_dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get meal_dinner;

  /// No description provided for @meal_snacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get meal_snacks;

  /// No description provided for @field_food_name.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get field_food_name;

  /// No description provided for @field_calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get field_calories;

  /// No description provided for @form_required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get form_required;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @food_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get food_saved;

  /// No description provided for @records_title.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records_title;

  /// No description provided for @records_select_date.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get records_select_date;

  /// No description provided for @records_empty.
  ///
  /// In en, this message translates to:
  /// **'No records'**
  String get records_empty;

  /// No description provided for @records_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit record'**
  String get records_edit_title;

  /// No description provided for @records_confirm_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete this record?'**
  String get records_confirm_delete;

  /// No description provided for @records_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get records_date;

  /// No description provided for @records_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get records_total;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @food_database_title.
  ///
  /// In en, this message translates to:
  /// **'Food Database'**
  String get food_database_title;

  /// No description provided for @food_add_custom.
  ///
  /// In en, this message translates to:
  /// **'Add custom food'**
  String get food_add_custom;

  /// No description provided for @food_search.
  ///
  /// In en, this message translates to:
  /// **'Search foods'**
  String get food_search;

  /// No description provided for @bottom_navigation_records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get bottom_navigation_records;

  /// No description provided for @bottom_navigation_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get bottom_navigation_food;

  /// No description provided for @bottom_navigation_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get bottom_navigation_settings;

  /// No description provided for @bottom_navigation_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottom_navigation_home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settings_logout;

  /// No description provided for @settings_logout_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get settings_logout_confirm;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_language_select.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get settings_language_select;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_theme_dark;

  /// No description provided for @settings_theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_theme_system;

  /// No description provided for @settings_profile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get settings_profile;

  /// No description provided for @settings_profile_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settings_profile_name;

  /// No description provided for @settings_profile_gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get settings_profile_gender;

  /// No description provided for @settings_profile_age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get settings_profile_age;

  /// No description provided for @settings_profile_height.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get settings_profile_height;

  /// No description provided for @settings_profile_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get settings_profile_weight;

  /// No description provided for @settings_profile_save.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get settings_profile_save;

  /// No description provided for @settings_profile_saved.
  ///
  /// In en, this message translates to:
  /// **'Profile Saved'**
  String get settings_profile_saved;

  /// No description provided for @settings_profile_activty_level.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get settings_profile_activty_level;

  /// No description provided for @settings_profile_activty_sedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get settings_profile_activty_sedentary;

  /// No description provided for @settings_profile_activty_light.
  ///
  /// In en, this message translates to:
  /// **'Lightly Active'**
  String get settings_profile_activty_light;

  /// No description provided for @settings_profile_activty_moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderately Active'**
  String get settings_profile_activty_moderate;

  /// No description provided for @settings_profile_activty_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get settings_profile_activty_active;

  /// No description provided for @settings_profile_activty_very_active.
  ///
  /// In en, this message translates to:
  /// **'Very Active'**
  String get settings_profile_activty_very_active;

  /// No description provided for @settings_goal_setup.
  ///
  /// In en, this message translates to:
  /// **'Goal Setup'**
  String get settings_goal_setup;

  /// No description provided for @settings_goal_weight_loss.
  ///
  /// In en, this message translates to:
  /// **'Weight Loss'**
  String get settings_goal_weight_loss;

  /// No description provided for @settings_goal_weight_gain.
  ///
  /// In en, this message translates to:
  /// **'Weight Gain'**
  String get settings_goal_weight_gain;

  /// No description provided for @settings_goal_maintain_weight.
  ///
  /// In en, this message translates to:
  /// **'Maintain Weight'**
  String get settings_goal_maintain_weight;

  /// No description provided for @settings_goal_target_weight.
  ///
  /// In en, this message translates to:
  /// **'Target Weight (kg)'**
  String get settings_goal_target_weight;

  /// No description provided for @settings_goal_save.
  ///
  /// In en, this message translates to:
  /// **'Save Goal'**
  String get settings_goal_save;

  /// No description provided for @settings_goal_saved.
  ///
  /// In en, this message translates to:
  /// **'Goal Saved'**
  String get settings_goal_saved;

  /// No description provided for @settings_daily_targets.
  ///
  /// In en, this message translates to:
  /// **'Daily Targets'**
  String get settings_daily_targets;

  /// No description provided for @settings_daily_setup_your_profile.
  ///
  /// In en, this message translates to:
  /// **'Setup your profile to calculate daily targets.'**
  String get settings_daily_setup_your_profile;

  /// No description provided for @settings_daily_button_recalculate.
  ///
  /// In en, this message translates to:
  /// **'Recalculate'**
  String get settings_daily_button_recalculate;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_language_system_default.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settings_language_system_default;

  /// No description provided for @language_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get language_system;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @language_arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get language_arabic;

  /// No description provided for @settings_units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settings_units;

  /// No description provided for @settings_units_metric_label.
  ///
  /// In en, this message translates to:
  /// **'Metric (kg, cm)'**
  String get settings_units_metric_label;

  /// No description provided for @settings_units_imperial_label.
  ///
  /// In en, this message translates to:
  /// **'Imperial (lb, ft)'**
  String get settings_units_imperial_label;

  /// No description provided for @settings_units_metric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get settings_units_metric;

  /// No description provided for @settings_units_imperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get settings_units_imperial;

  /// No description provided for @settings_backup_db.
  ///
  /// In en, this message translates to:
  /// **'Backup foods & records DB'**
  String get settings_backup_db;

  /// No description provided for @settings_backup_export_title.
  ///
  /// In en, this message translates to:
  /// **'Export database'**
  String get settings_backup_export_title;

  /// No description provided for @settings_backup_exported.
  ///
  /// In en, this message translates to:
  /// **'Backup exported'**
  String get settings_backup_exported;

  /// No description provided for @settings_restore_backup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get settings_restore_backup;

  /// No description provided for @settings_restore_title.
  ///
  /// In en, this message translates to:
  /// **'Restore DB'**
  String get settings_restore_title;

  /// No description provided for @settings_restore_overwrite_confirm.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite current data. Continue?'**
  String get settings_restore_overwrite_confirm;

  /// No description provided for @common_restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get common_restore;

  /// No description provided for @settings_restore_done_restart.
  ///
  /// In en, this message translates to:
  /// **'Backup restored. Restart app.'**
  String get settings_restore_done_restart;

  /// No description provided for @settings_clear_all_data.
  ///
  /// In en, this message translates to:
  /// **'Clear all data'**
  String get settings_clear_all_data;

  /// No description provided for @settings_clear_title.
  ///
  /// In en, this message translates to:
  /// **'Clear data'**
  String get settings_clear_title;

  /// No description provided for @settings_clear_confirm.
  ///
  /// In en, this message translates to:
  /// **'This will remove foods, meals, and settings. Continue?'**
  String get settings_clear_confirm;

  /// No description provided for @common_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get common_clear;

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// No description provided for @settings_data_cleared.
  ///
  /// In en, this message translates to:
  /// **'Data cleared'**
  String get settings_data_cleared;

  /// No description provided for @home_title.
  ///
  /// In en, this message translates to:
  /// **'Calorie Calculator'**
  String get home_title;

  /// No description provided for @home_enter_valid_anthro.
  ///
  /// In en, this message translates to:
  /// **'Enter valid age, height (cm), and weight (kg)'**
  String get home_enter_valid_anthro;

  /// No description provided for @form_sex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get form_sex;

  /// No description provided for @sex_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get sex_male;

  /// No description provided for @sex_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get sex_female;

  /// No description provided for @form_age_years.
  ///
  /// In en, this message translates to:
  /// **'Age (years)'**
  String get form_age_years;

  /// No description provided for @form_height_cm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get form_height_cm;

  /// No description provided for @form_weight_kg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get form_weight_kg;

  /// No description provided for @form_activity_level.
  ///
  /// In en, this message translates to:
  /// **'Activity level'**
  String get form_activity_level;

  /// No description provided for @home_activity_sedentary_desc.
  ///
  /// In en, this message translates to:
  /// **'Sedentary (little or no exercise)'**
  String get home_activity_sedentary_desc;

  /// No description provided for @home_activity_light_desc.
  ///
  /// In en, this message translates to:
  /// **'Light (1–3 days/week)'**
  String get home_activity_light_desc;

  /// No description provided for @home_activity_moderate_desc.
  ///
  /// In en, this message translates to:
  /// **'Moderate (3–5 days/week)'**
  String get home_activity_moderate_desc;

  /// No description provided for @home_activity_very_desc.
  ///
  /// In en, this message translates to:
  /// **'Very (6–7 days/week)'**
  String get home_activity_very_desc;

  /// No description provided for @home_activity_extra_desc.
  ///
  /// In en, this message translates to:
  /// **'Extra active'**
  String get home_activity_extra_desc;

  /// No description provided for @form_goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get form_goal;

  /// No description provided for @home_goal_lose_desc.
  ///
  /// In en, this message translates to:
  /// **'Lose weight (~-500 kcal/day)'**
  String get home_goal_lose_desc;

  /// No description provided for @home_goal_maintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain'**
  String get home_goal_maintain;

  /// No description provided for @home_goal_gain_desc.
  ///
  /// In en, this message translates to:
  /// **'Gain (~+300 kcal/day)'**
  String get home_goal_gain_desc;

  /// No description provided for @common_calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get common_calculate;

  /// No description provided for @result_bmr.
  ///
  /// In en, this message translates to:
  /// **'BMR'**
  String get result_bmr;

  /// No description provided for @result_tdee.
  ///
  /// In en, this message translates to:
  /// **'TDEE'**
  String get result_tdee;

  /// No description provided for @result_target_calories.
  ///
  /// In en, this message translates to:
  /// **'Target calories'**
  String get result_target_calories;

  /// No description provided for @unit_kcal_per_day.
  ///
  /// In en, this message translates to:
  /// **'kcal/day'**
  String get unit_kcal_per_day;

  /// No description provided for @unit_kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get unit_kcal;

  /// No description provided for @home_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get home_today;

  /// No description provided for @home_add_meal.
  ///
  /// In en, this message translates to:
  /// **'Add meal'**
  String get home_add_meal;

  /// No description provided for @home_remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get home_remaining;

  /// No description provided for @food_export_csv_button.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get food_export_csv_button;

  /// No description provided for @food_import_csv_button.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get food_import_csv_button;

  /// No description provided for @food_export_csv_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Export foods CSV'**
  String get food_export_csv_dialog_title;

  /// No description provided for @food_import_csv_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Import foods CSV'**
  String get food_import_csv_dialog_title;

  /// No description provided for @food_exported_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Foods exported'**
  String get food_exported_snackbar;

  /// No description provided for @food_imported_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} foods'**
  String food_imported_snackbar(int count);

  /// No description provided for @food_empty_list.
  ///
  /// In en, this message translates to:
  /// **'No foods'**
  String get food_empty_list;

  /// No description provided for @food_add_to_meal.
  ///
  /// In en, this message translates to:
  /// **'Add to meal'**
  String get food_add_to_meal;

  /// No description provided for @food_macro_line.
  ///
  /// In en, this message translates to:
  /// **'Cal/100g: {cal} • C: {carbs}g • P: {protein}g • F: {fat}g'**
  String food_macro_line(num cal, num carbs, num protein, num fat);

  /// No description provided for @field_carbs_g.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get field_carbs_g;

  /// No description provided for @field_protein_g.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get field_protein_g;

  /// No description provided for @field_fat_g.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get field_fat_g;

  /// No description provided for @reports_title.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports_title;

  /// No description provided for @report_tab_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get report_tab_daily;

  /// No description provided for @report_tab_weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get report_tab_weekly;

  /// No description provided for @report_tab_monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get report_tab_monthly;

  /// No description provided for @report_tab_progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get report_tab_progress;

  /// No description provided for @report_date_label.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String report_date_label(String date);

  /// No description provided for @report_calories_eaten.
  ///
  /// In en, this message translates to:
  /// **'Calories eaten'**
  String get report_calories_eaten;

  /// No description provided for @report_week_range.
  ///
  /// In en, this message translates to:
  /// **'Week: {start} - {end}'**
  String report_week_range(String start, String end);

  /// No description provided for @report_month_day_n.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String report_month_day_n(int day);

  /// No description provided for @report_starting_weight.
  ///
  /// In en, this message translates to:
  /// **'Starting weight'**
  String get report_starting_weight;

  /// No description provided for @report_current_weight.
  ///
  /// In en, this message translates to:
  /// **'Current weight'**
  String get report_current_weight;

  /// No description provided for @report_goal_weight.
  ///
  /// In en, this message translates to:
  /// **'Goal weight'**
  String get report_goal_weight;

  /// No description provided for @report_select_week_title.
  ///
  /// In en, this message translates to:
  /// **'Select week'**
  String get report_select_week_title;

  /// No description provided for @report_year_label.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get report_year_label;

  /// No description provided for @report_week_label.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get report_week_label;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @report_select_month_title.
  ///
  /// In en, this message translates to:
  /// **'Select month'**
  String get report_select_month_title;

  /// No description provided for @report_month_label.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get report_month_label;

  /// No description provided for @food_export_default_filename.
  ///
  /// In en, this message translates to:
  /// **'foods.csv'**
  String get food_export_default_filename;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get profile_title;

  /// No description provided for @profile_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profile_name;

  /// No description provided for @profile_age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profile_age;

  /// No description provided for @profile_gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profile_gender;

  /// No description provided for @profile_gender_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get profile_gender_male;

  /// No description provided for @profile_gender_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get profile_gender_female;

  /// No description provided for @profile_height_cm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get profile_height_cm;

  /// No description provided for @profile_weight_kg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get profile_weight_kg;

  /// No description provided for @profile_activity_level.
  ///
  /// In en, this message translates to:
  /// **'Activity level'**
  String get profile_activity_level;

  /// No description provided for @profile_activity_sedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get profile_activity_sedentary;

  /// No description provided for @profile_activity_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profile_activity_light;

  /// No description provided for @profile_activity_moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get profile_activity_moderate;

  /// No description provided for @profile_activity_very.
  ///
  /// In en, this message translates to:
  /// **'Very active'**
  String get profile_activity_very;

  /// No description provided for @profile_activity_extra.
  ///
  /// In en, this message translates to:
  /// **'Extra active'**
  String get profile_activity_extra;

  /// No description provided for @profile_saved_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profile_saved_snackbar;

  /// No description provided for @goal_setup_title.
  ///
  /// In en, this message translates to:
  /// **'Goal Setup'**
  String get goal_setup_title;

  /// No description provided for @goal_choose_title.
  ///
  /// In en, this message translates to:
  /// **'Choose your goal'**
  String get goal_choose_title;

  /// No description provided for @goal_option_lose.
  ///
  /// In en, this message translates to:
  /// **'Lose'**
  String get goal_option_lose;

  /// No description provided for @goal_option_maintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain'**
  String get goal_option_maintain;

  /// No description provided for @goal_option_gain.
  ///
  /// In en, this message translates to:
  /// **'Gain'**
  String get goal_option_gain;

  /// No description provided for @goal_target_rate.
  ///
  /// In en, this message translates to:
  /// **'Target rate (kg/week)'**
  String get goal_target_rate;

  /// No description provided for @goal_rate_option.
  ///
  /// In en, this message translates to:
  /// **'{rate} kg/week'**
  String goal_rate_option(Object rate);

  /// No description provided for @goal_saved_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Goal saved'**
  String get goal_saved_snackbar;

  /// No description provided for @daily_target_macros_title.
  ///
  /// In en, this message translates to:
  /// **'Macros (g/day)'**
  String get daily_target_macros_title;

  /// No description provided for @label_carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get label_carbs;

  /// No description provided for @label_protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get label_protein;

  /// No description provided for @label_fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get label_fat;

  /// No description provided for @unit_g.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unit_g;

  /// No description provided for @form_number_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get form_number_invalid;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
