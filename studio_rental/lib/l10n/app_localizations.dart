import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bg.dart';
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
    Locale('bg'),
    Locale('en'),
  ];

  /// App name shown on splash screen
  ///
  /// In bg, this message translates to:
  /// **'My Studio'**
  String get splash_app_name;

  /// Tagline on splash screen
  ///
  /// In bg, this message translates to:
  /// **'Вашето наемане, организирано.'**
  String get splash_tagline;

  /// Get started button on splash
  ///
  /// In bg, this message translates to:
  /// **'Започнете'**
  String get splash_get_started;

  /// Link to login from splash
  ///
  /// In bg, this message translates to:
  /// **'Вече имам акаунт'**
  String get splash_already_have_account;

  /// Register screen title
  ///
  /// In bg, this message translates to:
  /// **'Създай акаунт'**
  String get register_title;

  /// Full name field label
  ///
  /// In bg, this message translates to:
  /// **'Пълно име'**
  String get register_full_name_label;

  /// Full name field hint
  ///
  /// In bg, this message translates to:
  /// **'Въведете пълното си име'**
  String get register_full_name_hint;

  /// Email field label
  ///
  /// In bg, this message translates to:
  /// **'Имейл адрес'**
  String get register_email_label;

  /// Email field hint
  ///
  /// In bg, this message translates to:
  /// **'you@example.com'**
  String get register_email_hint;

  /// Password field label
  ///
  /// In bg, this message translates to:
  /// **'Парола'**
  String get register_password_label;

  /// Password field hint
  ///
  /// In bg, this message translates to:
  /// **'Създайте парола'**
  String get register_password_hint;

  /// Confirm password field label
  ///
  /// In bg, this message translates to:
  /// **'Потвърди парола'**
  String get register_confirm_password_label;

  /// Confirm password field hint
  ///
  /// In bg, this message translates to:
  /// **'Повторете паролата'**
  String get register_confirm_password_hint;

  /// Studio name field label
  ///
  /// In bg, this message translates to:
  /// **'Име на студиото'**
  String get register_studio_name_label;

  /// Studio name field hint
  ///
  /// In bg, this message translates to:
  /// **'напр. Sunset Studio'**
  String get register_studio_name_hint;

  /// Studio location field label
  ///
  /// In bg, this message translates to:
  /// **'Локация на студиото'**
  String get register_studio_location_label;

  /// Studio location field hint
  ///
  /// In bg, this message translates to:
  /// **'Адрес (по избор)'**
  String get register_studio_location_hint;

  /// Register submit button
  ///
  /// In bg, this message translates to:
  /// **'Създай акаунт'**
  String get register_button;

  /// Register button loading state
  ///
  /// In bg, this message translates to:
  /// **'Създаване на акаунт...'**
  String get register_button_loading;

  /// Link to login from register
  ///
  /// In bg, this message translates to:
  /// **'Вече имате акаунт? Вход'**
  String get register_already_have_account;

  /// Name required validation error
  ///
  /// In bg, this message translates to:
  /// **'Името е задължително'**
  String get register_error_name_required;

  /// Name min length validation error
  ///
  /// In bg, this message translates to:
  /// **'Името трябва да е поне 2 символа'**
  String get register_error_name_min;

  /// Email required validation error
  ///
  /// In bg, this message translates to:
  /// **'Имейлът е задължителен'**
  String get register_error_email_required;

  /// Email format validation error
  ///
  /// In bg, this message translates to:
  /// **'Невалиден имейл адрес'**
  String get register_error_email_invalid;

  /// Password required validation error
  ///
  /// In bg, this message translates to:
  /// **'Паролата е задължителна'**
  String get register_error_password_required;

  /// Password min length validation error
  ///
  /// In bg, this message translates to:
  /// **'Паролата трябва да е поне 8 символа'**
  String get register_error_password_min;

  /// Password format validation error
  ///
  /// In bg, this message translates to:
  /// **'Паролата трябва да съдържа главна буква и цифра'**
  String get register_error_password_format;

  /// Confirm password required validation error
  ///
  /// In bg, this message translates to:
  /// **'Потвърдете паролата'**
  String get register_error_confirm_required;

  /// Password mismatch validation error
  ///
  /// In bg, this message translates to:
  /// **'Паролите не съвпадат'**
  String get register_error_confirm_mismatch;

  /// Studio name required validation error
  ///
  /// In bg, this message translates to:
  /// **'Името на студиото е задължително'**
  String get register_error_studio_required;

  /// Email already exists error
  ///
  /// In bg, this message translates to:
  /// **'Този имейл вече е регистриран'**
  String get register_error_email_exists;

  /// Network error on register
  ///
  /// In bg, this message translates to:
  /// **'Мрежова грешка. Опитайте отново.'**
  String get register_error_network;

  /// Login screen title
  ///
  /// In bg, this message translates to:
  /// **'Добре дошли отново'**
  String get login_title;

  /// Email field label
  ///
  /// In bg, this message translates to:
  /// **'Имейл адрес'**
  String get login_email_label;

  /// Email field hint
  ///
  /// In bg, this message translates to:
  /// **'you@example.com'**
  String get login_email_hint;

  /// Password field label
  ///
  /// In bg, this message translates to:
  /// **'Парола'**
  String get login_password_label;

  /// Password field hint
  ///
  /// In bg, this message translates to:
  /// **'Въведете паролата си'**
  String get login_password_hint;

  /// Remember me checkbox
  ///
  /// In bg, this message translates to:
  /// **'Запомни ме'**
  String get login_remember_me;

  /// Login submit button
  ///
  /// In bg, this message translates to:
  /// **'Вход'**
  String get login_button;

  /// Login button loading state
  ///
  /// In bg, this message translates to:
  /// **'Влизане...'**
  String get login_button_loading;

  /// Forgot password link
  ///
  /// In bg, this message translates to:
  /// **'Забравена парола?'**
  String get login_forgot_password;

  /// Link to register from login
  ///
  /// In bg, this message translates to:
  /// **'Нямате акаунт? Регистрация'**
  String get login_no_account;

  /// Email required validation error
  ///
  /// In bg, this message translates to:
  /// **'Имейлът е задължителен'**
  String get login_error_email_required;

  /// Email format validation error
  ///
  /// In bg, this message translates to:
  /// **'Невалиден имейл адрес'**
  String get login_error_email_invalid;

  /// Password required validation error
  ///
  /// In bg, this message translates to:
  /// **'Паролата е задължителна'**
  String get login_error_password_required;

  /// Invalid credentials error
  ///
  /// In bg, this message translates to:
  /// **'Невалиден имейл или парола'**
  String get login_error_invalid_credentials;

  /// Network error on login
  ///
  /// In bg, this message translates to:
  /// **'Мрежова грешка. Опитайте отново.'**
  String get login_error_network;

  /// Forgot password screen title
  ///
  /// In bg, this message translates to:
  /// **'Нулиране на парола'**
  String get forgot_title;

  /// Forgot password description
  ///
  /// In bg, this message translates to:
  /// **'Въведете имейла си и ще ви изпратим линк за нулиране.'**
  String get forgot_description;

  /// Email field label
  ///
  /// In bg, this message translates to:
  /// **'Имейл адрес'**
  String get forgot_email_label;

  /// Email field hint
  ///
  /// In bg, this message translates to:
  /// **'you@example.com'**
  String get forgot_email_hint;

  /// Send reset link button
  ///
  /// In bg, this message translates to:
  /// **'Изпрати линк за нулиране'**
  String get forgot_button;

  /// Sending button loading state
  ///
  /// In bg, this message translates to:
  /// **'Изпращане...'**
  String get forgot_button_loading;

  /// Success message after reset request
  ///
  /// In bg, this message translates to:
  /// **'Ако този имейл съществува, линк за нулиране е изпратен.'**
  String get forgot_success;

  /// Back to login link
  ///
  /// In bg, this message translates to:
  /// **'Назад към Вход'**
  String get forgot_back_to_login;

  /// Email required validation error
  ///
  /// In bg, this message translates to:
  /// **'Имейлът е задължителен'**
  String get forgot_error_email_required;

  /// Email format validation error
  ///
  /// In bg, this message translates to:
  /// **'Невалиден имейл адрес'**
  String get forgot_error_email_invalid;

  /// Network error on forgot password
  ///
  /// In bg, this message translates to:
  /// **'Мрежова грешка. Опитайте отново.'**
  String get forgot_error_network;

  /// Tonight label on dashboard
  ///
  /// In bg, this message translates to:
  /// **'Тази вечер'**
  String get dashboard_tonight;

  /// Free tonight indicator
  ///
  /// In bg, this message translates to:
  /// **'Свободно'**
  String get dashboard_tonight_free;

  /// This month label
  ///
  /// In bg, this message translates to:
  /// **'Този месец'**
  String get dashboard_this_month;

  /// This month revenue label
  ///
  /// In bg, this message translates to:
  /// **'Приход този месец'**
  String get dashboard_month_revenue;

  /// Occupancy rate label
  ///
  /// In bg, this message translates to:
  /// **'Заетост'**
  String get dashboard_occupancy_rate;

  /// Upcoming reservations section title
  ///
  /// In bg, this message translates to:
  /// **'Предстоящи резервации'**
  String get dashboard_upcoming;

  /// See all link
  ///
  /// In bg, this message translates to:
  /// **'Виж всички'**
  String get dashboard_see_all;

  /// New reservation button
  ///
  /// In bg, this message translates to:
  /// **'+ Нова резервация'**
  String get dashboard_new_reservation;

  /// Open calendar button
  ///
  /// In bg, this message translates to:
  /// **'Календар'**
  String get dashboard_open_calendar;

  /// Analytics button
  ///
  /// In bg, this message translates to:
  /// **'Анализи'**
  String get dashboard_analytics;

  /// Total revenue label
  ///
  /// In bg, this message translates to:
  /// **'Общ приход'**
  String get dashboard_total_revenue;

  /// Total expenses label
  ///
  /// In bg, this message translates to:
  /// **'Общи разходи'**
  String get dashboard_total_expenses;

  /// Net profit label
  ///
  /// In bg, this message translates to:
  /// **'Нетна печалба'**
  String get dashboard_net_profit;

  /// Nights booked out of total
  ///
  /// In bg, this message translates to:
  /// **'{booked} / {total} нощувки'**
  String dashboard_nights_booked(int booked, int total);

  /// Empty state for upcoming reservations
  ///
  /// In bg, this message translates to:
  /// **'Няма предстоящи резервации.'**
  String get dashboard_no_upcoming;

  /// CTA to add first reservation
  ///
  /// In bg, this message translates to:
  /// **'Добавете първата си резервация'**
  String get dashboard_add_first;

  /// Error loading dashboard data
  ///
  /// In bg, this message translates to:
  /// **'Грешка при зареждане на данните'**
  String get dashboard_error_load;

  /// Retry button
  ///
  /// In bg, this message translates to:
  /// **'Опитай отново'**
  String get dashboard_retry;

  /// Confirmed reservation status
  ///
  /// In bg, this message translates to:
  /// **'Потвърдена'**
  String get status_confirmed;

  /// Pending reservation status
  ///
  /// In bg, this message translates to:
  /// **'Чакаща'**
  String get status_pending;

  /// Cancelled reservation status
  ///
  /// In bg, this message translates to:
  /// **'Отменена'**
  String get status_cancelled;

  /// Unpaid payment status
  ///
  /// In bg, this message translates to:
  /// **'Неплатена'**
  String get payment_unpaid;

  /// Partially paid payment status
  ///
  /// In bg, this message translates to:
  /// **'Частично платена'**
  String get payment_partially_paid;

  /// Paid payment status
  ///
  /// In bg, this message translates to:
  /// **'Платена'**
  String get payment_paid;

  /// Calendar screen title
  ///
  /// In bg, this message translates to:
  /// **'Календар'**
  String get calendar_title;

  /// Today button label
  ///
  /// In bg, this message translates to:
  /// **'Днес'**
  String get calendar_today;

  /// Prompt to add reservation
  ///
  /// In bg, this message translates to:
  /// **'Добави резервация?'**
  String get calendar_add_reservation_prompt;

  /// Calendar month nights booked
  ///
  /// In bg, this message translates to:
  /// **'Нощувки: {booked} / {total}'**
  String calendar_nights_booked(int booked, int total);

  /// Calendar month revenue
  ///
  /// In bg, this message translates to:
  /// **'Приход: {amount}'**
  String calendar_revenue(String amount);

  /// Add reservation button
  ///
  /// In bg, this message translates to:
  /// **'+ Добави резервация'**
  String get calendar_add_reservation;

  /// Legend: available
  ///
  /// In bg, this message translates to:
  /// **'Свободен'**
  String get calendar_legend_available;

  /// Legend: reserved
  ///
  /// In bg, this message translates to:
  /// **'Резервиран'**
  String get calendar_legend_reserved;

  /// Legend: check-in
  ///
  /// In bg, this message translates to:
  /// **'Настаняване'**
  String get calendar_legend_check_in;

  /// Legend: check-out
  ///
  /// In bg, this message translates to:
  /// **'Напускане'**
  String get calendar_legend_check_out;

  /// Legend: past
  ///
  /// In bg, this message translates to:
  /// **'Минал'**
  String get calendar_legend_past;

  /// Error loading calendar
  ///
  /// In bg, this message translates to:
  /// **'Грешка при зареждане на календара'**
  String get calendar_error_load;

  /// No reservations this month
  ///
  /// In bg, this message translates to:
  /// **'Няма резервации за този месец'**
  String get calendar_no_reservations;

  /// Bottom sheet check-in label
  ///
  /// In bg, this message translates to:
  /// **'Настаняване'**
  String get bottom_sheet_check_in;

  /// Bottom sheet check-out label
  ///
  /// In bg, this message translates to:
  /// **'Напускане'**
  String get bottom_sheet_check_out;

  /// Number of nights in bottom sheet
  ///
  /// In bg, this message translates to:
  /// **'{count} нощувки'**
  String bottom_sheet_nights(int count);

  /// Per night label
  ///
  /// In bg, this message translates to:
  /// **'на нощ'**
  String get bottom_sheet_price_per_night;

  /// Total label
  ///
  /// In bg, this message translates to:
  /// **'Общо'**
  String get bottom_sheet_total;

  /// View full details button
  ///
  /// In bg, this message translates to:
  /// **'Виж детайли'**
  String get bottom_sheet_view_details;

  /// Edit button in bottom sheet
  ///
  /// In bg, this message translates to:
  /// **'Редактирай'**
  String get bottom_sheet_edit;

  /// Notes label in bottom sheet
  ///
  /// In bg, this message translates to:
  /// **'Бележки'**
  String get bottom_sheet_notes;

  /// Error loading bottom sheet data
  ///
  /// In bg, this message translates to:
  /// **'Грешка при зареждане'**
  String get bottom_sheet_error;

  /// Add reservation screen title
  ///
  /// In bg, this message translates to:
  /// **'Нова резервация'**
  String get add_reservation_title;

  /// Guest section header
  ///
  /// In bg, this message translates to:
  /// **'Гост'**
  String get add_reservation_guest_section;

  /// Search guest hint
  ///
  /// In bg, this message translates to:
  /// **'Търси гост...'**
  String get add_reservation_search_guest;

  /// Create new guest button
  ///
  /// In bg, this message translates to:
  /// **'+ Създай нов гост'**
  String get add_reservation_create_guest;

  /// Dates section header
  ///
  /// In bg, this message translates to:
  /// **'Дати'**
  String get add_reservation_dates_section;

  /// Nights mode toggle
  ///
  /// In bg, this message translates to:
  /// **'Брой нощувки'**
  String get add_reservation_mode_nights;

  /// Date range mode toggle
  ///
  /// In bg, this message translates to:
  /// **'Период'**
  String get add_reservation_mode_range;

  /// Check-in date label
  ///
  /// In bg, this message translates to:
  /// **'Настаняване'**
  String get add_reservation_check_in;

  /// Check-out date label
  ///
  /// In bg, this message translates to:
  /// **'Напускане'**
  String get add_reservation_check_out;

  /// Nights count label
  ///
  /// In bg, this message translates to:
  /// **'Нощувки'**
  String get add_reservation_nights;

  /// Pricing section header
  ///
  /// In bg, this message translates to:
  /// **'Цена'**
  String get add_reservation_pricing_section;

  /// Price per night mode
  ///
  /// In bg, this message translates to:
  /// **'Цена на нощ'**
  String get add_reservation_mode_per_night;

  /// Custom total price mode
  ///
  /// In bg, this message translates to:
  /// **'Обща цена'**
  String get add_reservation_mode_custom_total;

  /// Price per night field label
  ///
  /// In bg, this message translates to:
  /// **'Цена на нощ'**
  String get add_reservation_price_per_night;

  /// Total price field label
  ///
  /// In bg, this message translates to:
  /// **'Обща цена'**
  String get add_reservation_total_price;

  /// Deposit field label
  ///
  /// In bg, this message translates to:
  /// **'Депозит'**
  String get add_reservation_deposit;

  /// Deposit received toggle
  ///
  /// In bg, this message translates to:
  /// **'Депозитът получен?'**
  String get add_reservation_deposit_received;

  /// Status section header
  ///
  /// In bg, this message translates to:
  /// **'Статус'**
  String get add_reservation_status_section;

  /// Payment section header
  ///
  /// In bg, this message translates to:
  /// **'Плащане'**
  String get add_reservation_payment_section;

  /// Amount paid field label
  ///
  /// In bg, this message translates to:
  /// **'Платена сума'**
  String get add_reservation_amount_paid;

  /// Notes section header
  ///
  /// In bg, this message translates to:
  /// **'Бележки'**
  String get add_reservation_notes_section;

  /// Notes field hint
  ///
  /// In bg, this message translates to:
  /// **'Вътрешни бележки...'**
  String get add_reservation_notes_hint;

  /// Save reservation button
  ///
  /// In bg, this message translates to:
  /// **'Запази резервация'**
  String get add_reservation_save;

  /// Cancel button
  ///
  /// In bg, this message translates to:
  /// **'Отказ'**
  String get add_reservation_cancel;

  /// Saving loading state
  ///
  /// In bg, this message translates to:
  /// **'Запазване...'**
  String get add_reservation_saving;

  /// Date conflict error
  ///
  /// In bg, this message translates to:
  /// **'Избраните дати се припокриват с друга резервация'**
  String get add_reservation_conflict;

  /// Guest required validation
  ///
  /// In bg, this message translates to:
  /// **'Изберете гост'**
  String get add_reservation_error_guest_required;

  /// Date required validation
  ///
  /// In bg, this message translates to:
  /// **'Изберете дата за настаняване'**
  String get add_reservation_error_date_required;

  /// Minimum nights validation
  ///
  /// In bg, this message translates to:
  /// **'Минимум 1 нощувка'**
  String get add_reservation_error_nights_min;

  /// Price required validation
  ///
  /// In bg, this message translates to:
  /// **'Въведете цена'**
  String get add_reservation_error_price_required;

  /// Price positive validation
  ///
  /// In bg, this message translates to:
  /// **'Цената трябва да е положителна'**
  String get add_reservation_error_price_positive;

  /// Reservation created success message
  ///
  /// In bg, this message translates to:
  /// **'Резервацията е създадена'**
  String get add_reservation_success;

  /// Network error on add reservation
  ///
  /// In bg, this message translates to:
  /// **'Мрежова грешка. Опитайте отново.'**
  String get add_reservation_error_network;

  /// Edit reservation screen title
  ///
  /// In bg, this message translates to:
  /// **'Редактирай резервация'**
  String get edit_reservation_title;

  /// Save changes button
  ///
  /// In bg, this message translates to:
  /// **'Запази промени'**
  String get edit_reservation_save;

  /// Saving loading state
  ///
  /// In bg, this message translates to:
  /// **'Запазване...'**
  String get edit_reservation_saving;

  /// Delete reservation button
  ///
  /// In bg, this message translates to:
  /// **'Изтрий резервация'**
  String get edit_reservation_delete;

  /// Delete confirmation dialog title
  ///
  /// In bg, this message translates to:
  /// **'Изтриване на резервация'**
  String get edit_reservation_delete_confirm_title;

  /// Delete confirmation dialog message
  ///
  /// In bg, this message translates to:
  /// **'Сигурни ли сте? Това не може да бъде отменено.'**
  String get edit_reservation_delete_confirm_message;

  /// Cancel delete button
  ///
  /// In bg, this message translates to:
  /// **'Отказ'**
  String get edit_reservation_delete_confirm_cancel;

  /// Confirm delete button
  ///
  /// In bg, this message translates to:
  /// **'Изтрий'**
  String get edit_reservation_delete_confirm_delete;

  /// Deleting loading state
  ///
  /// In bg, this message translates to:
  /// **'Изтриване...'**
  String get edit_reservation_deleting;

  /// Reservation updated success message
  ///
  /// In bg, this message translates to:
  /// **'Резервацията е обновена'**
  String get edit_reservation_success;

  /// Reservation deleted success message
  ///
  /// In bg, this message translates to:
  /// **'Резервацията е изтрита'**
  String get edit_reservation_deleted;

  /// Reservation not found error
  ///
  /// In bg, this message translates to:
  /// **'Резервацията не е намерена'**
  String get edit_reservation_not_found;

  /// Error loading reservation
  ///
  /// In bg, this message translates to:
  /// **'Грешка при зареждане на резервацията'**
  String get edit_reservation_error_load;

  /// Reservation detail screen title
  ///
  /// In bg, this message translates to:
  /// **'Детайли на резервацията'**
  String get reservation_detail_title;

  /// Dates and duration section
  ///
  /// In bg, this message translates to:
  /// **'Дати и продължителност'**
  String get reservation_detail_dates;

  /// Check-in label
  ///
  /// In bg, this message translates to:
  /// **'Настаняване'**
  String get reservation_detail_check_in;

  /// Check-out label
  ///
  /// In bg, this message translates to:
  /// **'Напускане'**
  String get reservation_detail_check_out;

  /// Total nights label
  ///
  /// In bg, this message translates to:
  /// **'Общо нощувки'**
  String get reservation_detail_nights;

  /// Financial section header
  ///
  /// In bg, this message translates to:
  /// **'Финансова информация'**
  String get reservation_detail_financial;

  /// Price per night label
  ///
  /// In bg, this message translates to:
  /// **'Цена на нощ'**
  String get reservation_detail_price_per_night;

  /// Total price label
  ///
  /// In bg, this message translates to:
  /// **'Обща цена'**
  String get reservation_detail_total_price;

  /// Deposit label
  ///
  /// In bg, this message translates to:
  /// **'Депозит'**
  String get reservation_detail_deposit;

  /// Amount paid label
  ///
  /// In bg, this message translates to:
  /// **'Платена сума'**
  String get reservation_detail_amount_paid;

  /// Amount remaining label
  ///
  /// In bg, this message translates to:
  /// **'Оставащо'**
  String get reservation_detail_amount_remaining;

  /// Notes section header
  ///
  /// In bg, this message translates to:
  /// **'Бележки'**
  String get reservation_detail_notes;

  /// No notes placeholder
  ///
  /// In bg, this message translates to:
  /// **'Няма бележки'**
  String get reservation_detail_no_notes;

  /// Activity log section header
  ///
  /// In bg, this message translates to:
  /// **'Активност'**
  String get reservation_detail_activity;

  /// Edit reservation button
  ///
  /// In bg, this message translates to:
  /// **'Редактирай резервация'**
  String get reservation_detail_edit;

  /// Mark as paid button
  ///
  /// In bg, this message translates to:
  /// **'Маркирай като платена'**
  String get reservation_detail_mark_paid;

  /// Delete reservation button
  ///
  /// In bg, this message translates to:
  /// **'Изтрий резервация'**
  String get reservation_detail_delete;

  /// Reservation not found error
  ///
  /// In bg, this message translates to:
  /// **'Резервацията не е намерена'**
  String get reservation_detail_not_found;

  /// Error loading reservation detail
  ///
  /// In bg, this message translates to:
  /// **'Грешка при зареждане'**
  String get reservation_detail_error_load;

  /// Marked as paid success message
  ///
  /// In bg, this message translates to:
  /// **'Резервацията е маркирана като платена'**
  String get reservation_detail_marked_paid;

  /// Guest list screen title
  ///
  /// In bg, this message translates to:
  /// **'Гости'**
  String get guest_list_title;

  /// Guest search hint
  ///
  /// In bg, this message translates to:
  /// **'Търси по име, телефон, имейл...'**
  String get guest_list_search_hint;

  /// All filter chip
  ///
  /// In bg, this message translates to:
  /// **'Всички'**
  String get guest_list_filter_all;

  /// Upcoming filter chip
  ///
  /// In bg, this message translates to:
  /// **'Предстоящи'**
  String get guest_list_filter_upcoming;

  /// Past filter chip
  ///
  /// In bg, this message translates to:
  /// **'Минали'**
  String get guest_list_filter_past;

  /// Cancelled filter chip
  ///
  /// In bg, this message translates to:
  /// **'Отменени'**
  String get guest_list_filter_cancelled;

  /// Sort by name option
  ///
  /// In bg, this message translates to:
  /// **'Име А–Я'**
  String get guest_list_sort_name;

  /// Sort by most recent stay
  ///
  /// In bg, this message translates to:
  /// **'Последно посещение'**
  String get guest_list_sort_recent;

  /// Sort by most nights stayed
  ///
  /// In bg, this message translates to:
  /// **'Най-много нощувки'**
  String get guest_list_sort_nights;

  /// Number of stays for a guest
  ///
  /// In bg, this message translates to:
  /// **'{count} посещения'**
  String guest_list_stays(int count);

  /// No stays label
  ///
  /// In bg, this message translates to:
  /// **'Няма посещения'**
  String get guest_list_no_stays;

  /// Last stay date
  ///
  /// In bg, this message translates to:
  /// **'Последно: {date}'**
  String guest_list_last_stay(String date);

  /// Upcoming stay date
  ///
  /// In bg, this message translates to:
  /// **'Предстои: {date}'**
  String guest_list_upcoming_stay(String date);

  /// Empty state for guest list
  ///
  /// In bg, this message translates to:
  /// **'Все още няма гости. Добавете първата си резервация.'**
  String get guest_list_empty;

  /// Empty search results
  ///
  /// In bg, this message translates to:
  /// **'Няма намерени гости'**
  String get guest_list_empty_search;

  /// Add guest button
  ///
  /// In bg, this message translates to:
  /// **'Добави гост'**
  String get guest_list_add_guest;

  /// Error loading guests
  ///
  /// In bg, this message translates to:
  /// **'Грешка при зареждане на гостите'**
  String get guest_list_error_load;

  /// Phone label
  ///
  /// In bg, this message translates to:
  /// **'Телефон'**
  String get guest_detail_phone;

  /// Email label
  ///
  /// In bg, this message translates to:
  /// **'Имейл'**
  String get guest_detail_email;

  /// Nationality label
  ///
  /// In bg, this message translates to:
  /// **'Националност'**
  String get guest_detail_nationality;

  /// Total stays label
  ///
  /// In bg, this message translates to:
  /// **'Посещения'**
  String get guest_detail_total_stays;

  /// Total nights label
  ///
  /// In bg, this message translates to:
  /// **'Нощувки'**
  String get guest_detail_total_nights;

  /// Total revenue from guest
  ///
  /// In bg, this message translates to:
  /// **'Общ приход'**
  String get guest_detail_total_revenue;

  /// Notes section header
  ///
  /// In bg, this message translates to:
  /// **'Бележки'**
  String get guest_detail_notes;

  /// No notes placeholder
  ///
  /// In bg, this message translates to:
  /// **'Няма бележки'**
  String get guest_detail_no_notes;

  /// Reservation history section
  ///
  /// In bg, this message translates to:
  /// **'История на резервациите'**
  String get guest_detail_reservations;

  /// No reservations for guest
  ///
  /// In bg, this message translates to:
  /// **'Няма резервации за този гост.'**
  String get guest_detail_no_reservations;

  /// Edit guest button
  ///
  /// In bg, this message translates to:
  /// **'Редактирай'**
  String get guest_detail_edit;

  /// Delete guest button
  ///
  /// In bg, this message translates to:
  /// **'Изтрий гост'**
  String get guest_detail_delete;

  /// Delete guest confirmation title
  ///
  /// In bg, this message translates to:
  /// **'Изтриване на гост'**
  String get guest_detail_delete_confirm_title;

  /// Delete guest confirmation message
  ///
  /// In bg, this message translates to:
  /// **'Сигурни ли сте? Това ще премахне и всички свързани резервации.'**
  String get guest_detail_delete_confirm_message;

  /// Cancel delete button
  ///
  /// In bg, this message translates to:
  /// **'Отказ'**
  String get guest_detail_delete_confirm_cancel;

  /// Confirm delete button
  ///
  /// In bg, this message translates to:
  /// **'Изтрий'**
  String get guest_detail_delete_confirm_delete;

  /// Guest deleted success message
  ///
  /// In bg, this message translates to:
  /// **'Гостът е изтрит'**
  String get guest_detail_deleted;

  /// Guest not found error
  ///
  /// In bg, this message translates to:
  /// **'Гостът не е намерен'**
  String get guest_detail_not_found;

  /// Error loading guest detail
  ///
  /// In bg, this message translates to:
  /// **'Грешка при зареждане'**
  String get guest_detail_error_load;

  /// Cannot delete guest with upcoming reservations
  ///
  /// In bg, this message translates to:
  /// **'Гостът има предстоящи резервации. Първо ги отменете или изтрийте.'**
  String get guest_detail_has_upcoming;

  /// Not provided placeholder
  ///
  /// In bg, this message translates to:
  /// **'Не е посочено'**
  String get guest_detail_not_provided;

  /// Add guest screen title
  ///
  /// In bg, this message translates to:
  /// **'Нов гост'**
  String get add_guest_title;

  /// Edit guest screen title
  ///
  /// In bg, this message translates to:
  /// **'Редактирай гост'**
  String get edit_guest_title;

  /// First name field label
  ///
  /// In bg, this message translates to:
  /// **'Име'**
  String get guest_form_first_name;

  /// First name field hint
  ///
  /// In bg, this message translates to:
  /// **'Въведете име'**
  String get guest_form_first_name_hint;

  /// Last name field label
  ///
  /// In bg, this message translates to:
  /// **'Фамилия'**
  String get guest_form_last_name;

  /// Last name field hint
  ///
  /// In bg, this message translates to:
  /// **'Въведете фамилия'**
  String get guest_form_last_name_hint;

  /// Phone number field label
  ///
  /// In bg, this message translates to:
  /// **'Телефонен номер'**
  String get guest_form_phone;

  /// Phone number field hint
  ///
  /// In bg, this message translates to:
  /// **'+359...'**
  String get guest_form_phone_hint;

  /// Email field label
  ///
  /// In bg, this message translates to:
  /// **'Имейл адрес'**
  String get guest_form_email;

  /// Email field hint
  ///
  /// In bg, this message translates to:
  /// **'guest@email.com'**
  String get guest_form_email_hint;

  /// Nationality field label
  ///
  /// In bg, this message translates to:
  /// **'Националност'**
  String get guest_form_nationality;

  /// Nationality field hint
  ///
  /// In bg, this message translates to:
  /// **'Изберете страна'**
  String get guest_form_nationality_hint;

  /// ID/passport number field label
  ///
  /// In bg, this message translates to:
  /// **'ЕГН / Номер на паспорт'**
  String get guest_form_id_number;

  /// ID number field hint
  ///
  /// In bg, this message translates to:
  /// **'Въведете номер'**
  String get guest_form_id_number_hint;

  /// Guest notes field label
  ///
  /// In bg, this message translates to:
  /// **'Бележки за госта'**
  String get guest_form_notes;

  /// Guest notes field hint
  ///
  /// In bg, this message translates to:
  /// **'напр. Тих гост, Има куче'**
  String get guest_form_notes_hint;

  /// Save guest button
  ///
  /// In bg, this message translates to:
  /// **'Запази гост'**
  String get guest_form_save;

  /// Cancel button
  ///
  /// In bg, this message translates to:
  /// **'Отказ'**
  String get guest_form_cancel;

  /// Saving loading state
  ///
  /// In bg, this message translates to:
  /// **'Запазване...'**
  String get guest_form_saving;

  /// First name required validation
  ///
  /// In bg, this message translates to:
  /// **'Името е задължително'**
  String get guest_form_error_first_name_required;

  /// First name min length validation
  ///
  /// In bg, this message translates to:
  /// **'Името трябва да е поне 2 символа'**
  String get guest_form_error_first_name_min;

  /// Last name required validation
  ///
  /// In bg, this message translates to:
  /// **'Фамилията е задължителна'**
  String get guest_form_error_last_name_required;

  /// Last name min length validation
  ///
  /// In bg, this message translates to:
  /// **'Фамилията трябва да е поне 2 символа'**
  String get guest_form_error_last_name_min;

  /// Email format validation
  ///
  /// In bg, this message translates to:
  /// **'Невалиден имейл адрес'**
  String get guest_form_error_email_invalid;

  /// Phone format validation
  ///
  /// In bg, this message translates to:
  /// **'Невалиден телефонен номер'**
  String get guest_form_error_phone_invalid;

  /// Guest created success message
  ///
  /// In bg, this message translates to:
  /// **'Гостът е създаден'**
  String get guest_form_created;

  /// Guest updated success message
  ///
  /// In bg, this message translates to:
  /// **'Гостът е обновен'**
  String get guest_form_updated;

  /// Network error on guest form
  ///
  /// In bg, this message translates to:
  /// **'Мрежова грешка. Опитайте отново.'**
  String get guest_form_error_network;

  /// Expenses screen title
  ///
  /// In bg, this message translates to:
  /// **'Разходи'**
  String get expenses_title;

  /// Total expenses label
  ///
  /// In bg, this message translates to:
  /// **'Общо разходи'**
  String get expenses_total;

  /// Largest expense label
  ///
  /// In bg, this message translates to:
  /// **'Най-голям разход'**
  String get expenses_largest;

  /// Number of expense entries
  ///
  /// In bg, this message translates to:
  /// **'{count} записа'**
  String expenses_count(int count);

  /// All categories filter
  ///
  /// In bg, this message translates to:
  /// **'Всички'**
  String get expenses_filter_all;

  /// Maintenance category
  ///
  /// In bg, this message translates to:
  /// **'Поддръжка'**
  String get expenses_filter_maintenance;

  /// Renovation category
  ///
  /// In bg, this message translates to:
  /// **'Ремонт'**
  String get expenses_filter_renovation;

  /// Utilities category
  ///
  /// In bg, this message translates to:
  /// **'Сметки'**
  String get expenses_filter_utilities;

  /// Cleaning category
  ///
  /// In bg, this message translates to:
  /// **'Почистване'**
  String get expenses_filter_cleaning;

  /// Supplies category
  ///
  /// In bg, this message translates to:
  /// **'Консумативи'**
  String get expenses_filter_supplies;

  /// Taxes/Fees category
  ///
  /// In bg, this message translates to:
  /// **'Данъци / Такси'**
  String get expenses_filter_taxes;

  /// Other category
  ///
  /// In bg, this message translates to:
  /// **'Други'**
  String get expenses_filter_other;

  /// Add expense button
  ///
  /// In bg, this message translates to:
  /// **'+ Добави разход'**
  String get expenses_add;

  /// Empty state for expenses
  ///
  /// In bg, this message translates to:
  /// **'Няма записани разходи за този месец.'**
  String get expenses_empty;

  /// Error loading expenses
  ///
  /// In bg, this message translates to:
  /// **'Грешка при зареждане на разходите'**
  String get expenses_error_load;

  /// Bottom bar total amount
  ///
  /// In bg, this message translates to:
  /// **'Общо: {amount}'**
  String expenses_bottom_total(String amount);

  /// Add expense screen title
  ///
  /// In bg, this message translates to:
  /// **'Нов разход'**
  String get add_expense_title;

  /// Edit expense screen title
  ///
  /// In bg, this message translates to:
  /// **'Редактирай разход'**
  String get edit_expense_title;

  /// Expense title field label
  ///
  /// In bg, this message translates to:
  /// **'Заглавие / Описание'**
  String get expense_form_title_label;

  /// Expense title field hint
  ///
  /// In bg, this message translates to:
  /// **'напр. Ремонт на водопровод'**
  String get expense_form_title_hint;

  /// Amount field label
  ///
  /// In bg, this message translates to:
  /// **'Сума'**
  String get expense_form_amount_label;

  /// Amount field hint
  ///
  /// In bg, this message translates to:
  /// **'0.00'**
  String get expense_form_amount_hint;

  /// Date field label
  ///
  /// In bg, this message translates to:
  /// **'Дата'**
  String get expense_form_date_label;

  /// Category field label
  ///
  /// In bg, this message translates to:
  /// **'Категория'**
  String get expense_form_category_label;

  /// Category field hint
  ///
  /// In bg, this message translates to:
  /// **'Изберете категория'**
  String get expense_form_category_hint;

  /// Notes field label
  ///
  /// In bg, this message translates to:
  /// **'Бележки'**
  String get expense_form_notes_label;

  /// Notes field hint
  ///
  /// In bg, this message translates to:
  /// **'Допълнителни детайли...'**
  String get expense_form_notes_hint;

  /// Recurring expense toggle
  ///
  /// In bg, this message translates to:
  /// **'Повтарящ се разход?'**
  String get expense_form_recurring;

  /// Frequency label
  ///
  /// In bg, this message translates to:
  /// **'Честота'**
  String get expense_form_frequency;

  /// Monthly frequency option
  ///
  /// In bg, this message translates to:
  /// **'Месечно'**
  String get expense_form_monthly;

  /// Yearly frequency option
  ///
  /// In bg, this message translates to:
  /// **'Годишно'**
  String get expense_form_yearly;

  /// Save expense button
  ///
  /// In bg, this message translates to:
  /// **'Запази разход'**
  String get expense_form_save;

  /// Cancel button
  ///
  /// In bg, this message translates to:
  /// **'Отказ'**
  String get expense_form_cancel;

  /// Saving loading state
  ///
  /// In bg, this message translates to:
  /// **'Запазване...'**
  String get expense_form_saving;

  /// Delete expense button
  ///
  /// In bg, this message translates to:
  /// **'Изтрий разход'**
  String get expense_form_delete;

  /// Delete expense confirmation
  ///
  /// In bg, this message translates to:
  /// **'Сигурни ли сте, че искате да изтриете този разход?'**
  String get expense_form_delete_confirm;

  /// Title required validation
  ///
  /// In bg, this message translates to:
  /// **'Заглавието е задължително'**
  String get expense_form_error_title_required;

  /// Title min length validation
  ///
  /// In bg, this message translates to:
  /// **'Заглавието трябва да е поне 2 символа'**
  String get expense_form_error_title_min;

  /// Amount required validation
  ///
  /// In bg, this message translates to:
  /// **'Сумата е задължителна'**
  String get expense_form_error_amount_required;

  /// Amount positive validation
  ///
  /// In bg, this message translates to:
  /// **'Сумата трябва да е положителна'**
  String get expense_form_error_amount_positive;

  /// Date required validation
  ///
  /// In bg, this message translates to:
  /// **'Датата е задължителна'**
  String get expense_form_error_date_required;

  /// Category required validation
  ///
  /// In bg, this message translates to:
  /// **'Категорията е задължителна'**
  String get expense_form_error_category_required;

  /// Expense created success message
  ///
  /// In bg, this message translates to:
  /// **'Разходът е създаден'**
  String get expense_form_created;

  /// Expense updated success message
  ///
  /// In bg, this message translates to:
  /// **'Разходът е обновен'**
  String get expense_form_updated;

  /// Expense deleted success message
  ///
  /// In bg, this message translates to:
  /// **'Разходът е изтрит'**
  String get expense_form_deleted;

  /// Network error on expense form
  ///
  /// In bg, this message translates to:
  /// **'Мрежова грешка. Опитайте отново.'**
  String get expense_form_error_network;

  /// Analytics screen title
  ///
  /// In bg, this message translates to:
  /// **'Анализи'**
  String get analytics_title;

  /// This month period option
  ///
  /// In bg, this message translates to:
  /// **'Този месец'**
  String get analytics_period_this_month;

  /// Last month period option
  ///
  /// In bg, this message translates to:
  /// **'Миналия месец'**
  String get analytics_period_last_month;

  /// Last 3 months period option
  ///
  /// In bg, this message translates to:
  /// **'Последни 3 месеца'**
  String get analytics_period_last_3;

  /// Last 6 months period option
  ///
  /// In bg, this message translates to:
  /// **'Последни 6 месеца'**
  String get analytics_period_last_6;

  /// This year period option
  ///
  /// In bg, this message translates to:
  /// **'Тази година'**
  String get analytics_period_this_year;

  /// Custom range period option
  ///
  /// In bg, this message translates to:
  /// **'По избор'**
  String get analytics_period_custom;

  /// Total revenue label
  ///
  /// In bg, this message translates to:
  /// **'Общ приход'**
  String get analytics_total_revenue;

  /// Total expenses label
  ///
  /// In bg, this message translates to:
  /// **'Общи разходи'**
  String get analytics_total_expenses;

  /// Net profit label
  ///
  /// In bg, this message translates to:
  /// **'Нетна печалба'**
  String get analytics_net_profit;

  /// Occupancy label
  ///
  /// In bg, this message translates to:
  /// **'Заетост'**
  String get analytics_occupancy;

  /// Booked nights out of total
  ///
  /// In bg, this message translates to:
  /// **'{booked} от {total} нощувки'**
  String analytics_booked_nights(int booked, int total);

  /// Revenue breakdown chart title
  ///
  /// In bg, this message translates to:
  /// **'Приход по месеци'**
  String get analytics_revenue_chart;

  /// Confirmed label in chart
  ///
  /// In bg, this message translates to:
  /// **'Потвърден'**
  String get analytics_confirmed;

  /// Pending label in chart
  ///
  /// In bg, this message translates to:
  /// **'Чакащ'**
  String get analytics_pending;

  /// Expenses by category chart title
  ///
  /// In bg, this message translates to:
  /// **'Разходи по категории'**
  String get analytics_expenses_chart;

  /// Average length of stay
  ///
  /// In bg, this message translates to:
  /// **'Средна продължителност'**
  String get analytics_avg_stay;

  /// Average revenue per reservation
  ///
  /// In bg, this message translates to:
  /// **'Среден приход на резервация'**
  String get analytics_avg_revenue;

  /// Longest stay label
  ///
  /// In bg, this message translates to:
  /// **'Най-дълго посещение'**
  String get analytics_longest_stay;

  /// Most frequent guest label
  ///
  /// In bg, this message translates to:
  /// **'Най-чест гост'**
  String get analytics_most_frequent;

  /// Monthly comparison table title
  ///
  /// In bg, this message translates to:
  /// **'Месечно сравнение'**
  String get analytics_monthly_table;

  /// Month column header
  ///
  /// In bg, this message translates to:
  /// **'Месец'**
  String get analytics_month_col;

  /// Nights column header
  ///
  /// In bg, this message translates to:
  /// **'Нощувки'**
  String get analytics_nights_col;

  /// Revenue column header
  ///
  /// In bg, this message translates to:
  /// **'Приход'**
  String get analytics_revenue_col;

  /// Expenses column header
  ///
  /// In bg, this message translates to:
  /// **'Разходи'**
  String get analytics_expenses_col;

  /// Profit column header
  ///
  /// In bg, this message translates to:
  /// **'Печалба'**
  String get analytics_profit_col;

  /// Seasonal trends section title
  ///
  /// In bg, this message translates to:
  /// **'Сезонни тенденции'**
  String get analytics_seasonal;

  /// Nights unit label
  ///
  /// In bg, this message translates to:
  /// **'нощувки'**
  String get analytics_nights_unit;

  /// Stays unit label
  ///
  /// In bg, this message translates to:
  /// **'посещения'**
  String get analytics_stays_unit;

  /// Empty state for analytics
  ///
  /// In bg, this message translates to:
  /// **'Няма достатъчно данни за анализ. Добавете резервации, за да видите статистики.'**
  String get analytics_empty;

  /// Error loading analytics
  ///
  /// In bg, this message translates to:
  /// **'Грешка при зареждане на анализите'**
  String get analytics_error_load;

  /// Settings screen title
  ///
  /// In bg, this message translates to:
  /// **'Настройки'**
  String get settings_title;

  /// Profile section header
  ///
  /// In bg, this message translates to:
  /// **'Профил'**
  String get settings_profile;

  /// Display name label
  ///
  /// In bg, this message translates to:
  /// **'Име'**
  String get settings_display_name;

  /// Email label
  ///
  /// In bg, this message translates to:
  /// **'Имейл'**
  String get settings_email;

  /// Change password section
  ///
  /// In bg, this message translates to:
  /// **'Промяна на парола'**
  String get settings_change_password;

  /// Current password field
  ///
  /// In bg, this message translates to:
  /// **'Текуща парола'**
  String get settings_current_password;

  /// New password field
  ///
  /// In bg, this message translates to:
  /// **'Нова парола'**
  String get settings_new_password;

  /// Confirm new password field
  ///
  /// In bg, this message translates to:
  /// **'Потвърди нова парола'**
  String get settings_confirm_new_password;

  /// Update password button
  ///
  /// In bg, this message translates to:
  /// **'Обнови парола'**
  String get settings_update_password;

  /// Studio settings section
  ///
  /// In bg, this message translates to:
  /// **'Настройки на студиото'**
  String get settings_studio;

  /// Studio name field
  ///
  /// In bg, this message translates to:
  /// **'Име на студиото'**
  String get settings_studio_name;

  /// Studio address field
  ///
  /// In bg, this message translates to:
  /// **'Адрес на студиото'**
  String get settings_studio_address;

  /// Default price per night field
  ///
  /// In bg, this message translates to:
  /// **'Цена на нощ по подразбиране'**
  String get settings_default_price;

  /// Currency field
  ///
  /// In bg, this message translates to:
  /// **'Валута'**
  String get settings_currency;

  /// Default check-in time
  ///
  /// In bg, this message translates to:
  /// **'Час на настаняване'**
  String get settings_check_in_time;

  /// Default check-out time
  ///
  /// In bg, this message translates to:
  /// **'Час на напускане'**
  String get settings_check_out_time;

  /// Calendar settings section
  ///
  /// In bg, this message translates to:
  /// **'Настройки на календара'**
  String get settings_calendar;

  /// Week starts on setting
  ///
  /// In bg, this message translates to:
  /// **'Седмицата започва от'**
  String get settings_week_starts;

  /// Sunday option
  ///
  /// In bg, this message translates to:
  /// **'Неделя'**
  String get settings_sunday;

  /// Monday option
  ///
  /// In bg, this message translates to:
  /// **'Понеделник'**
  String get settings_monday;

  /// Color theme for reserved days
  ///
  /// In bg, this message translates to:
  /// **'Цветова тема за резервации'**
  String get settings_color_theme;

  /// Notifications section
  ///
  /// In bg, this message translates to:
  /// **'Известия'**
  String get settings_notifications;

  /// Enable push notifications toggle
  ///
  /// In bg, this message translates to:
  /// **'Включи известия'**
  String get settings_push_enabled;

  /// Check-in notification setting
  ///
  /// In bg, this message translates to:
  /// **'Известие 1 ден преди настаняване'**
  String get settings_notify_checkin;

  /// Check-out notification setting
  ///
  /// In bg, this message translates to:
  /// **'Известие в деня на напускане'**
  String get settings_notify_checkout;

  /// Unpaid notification setting
  ///
  /// In bg, this message translates to:
  /// **'Известие за неплатени резервации'**
  String get settings_notify_unpaid;

  /// Data section header
  ///
  /// In bg, this message translates to:
  /// **'Данни'**
  String get settings_data;

  /// Export data section
  ///
  /// In bg, this message translates to:
  /// **'Експорт на данни'**
  String get settings_export;

  /// Export as CSV button
  ///
  /// In bg, this message translates to:
  /// **'Експорт като CSV'**
  String get settings_export_csv;

  /// Export as PDF button
  ///
  /// In bg, this message translates to:
  /// **'Експорт като PDF'**
  String get settings_export_pdf;

  /// Clear all data button
  ///
  /// In bg, this message translates to:
  /// **'Изтрий всички данни'**
  String get settings_clear_data;

  /// Clear data confirmation prompt
  ///
  /// In bg, this message translates to:
  /// **'Въведете DELETE за потвърждение'**
  String get settings_clear_data_confirm;

  /// Clear data warning message
  ///
  /// In bg, this message translates to:
  /// **'Това действие е необратимо. Всички резервации, гости и разходи ще бъдат изтрити.'**
  String get settings_clear_data_warning;

  /// About section header
  ///
  /// In bg, this message translates to:
  /// **'Относно'**
  String get settings_about;

  /// Version label
  ///
  /// In bg, this message translates to:
  /// **'Версия'**
  String get settings_version;

  /// Rate the app button
  ///
  /// In bg, this message translates to:
  /// **'Оценете приложението'**
  String get settings_rate_app;

  /// Privacy policy link
  ///
  /// In bg, this message translates to:
  /// **'Политика за поверителност'**
  String get settings_privacy;

  /// Terms of use link
  ///
  /// In bg, this message translates to:
  /// **'Условия за ползване'**
  String get settings_terms;

  /// Logout button
  ///
  /// In bg, this message translates to:
  /// **'Изход'**
  String get settings_logout;

  /// Logout confirmation message
  ///
  /// In bg, this message translates to:
  /// **'Сигурни ли сте, че искате да излезете?'**
  String get settings_logout_confirm;

  /// Cancel logout button
  ///
  /// In bg, this message translates to:
  /// **'Отказ'**
  String get settings_logout_cancel;

  /// Confirm logout button
  ///
  /// In bg, this message translates to:
  /// **'Изход'**
  String get settings_logout_yes;

  /// Settings saved success message
  ///
  /// In bg, this message translates to:
  /// **'Настройките са запазени'**
  String get settings_saved;

  /// Password changed success message
  ///
  /// In bg, this message translates to:
  /// **'Паролата е променена'**
  String get settings_password_changed;

  /// Current password incorrect error
  ///
  /// In bg, this message translates to:
  /// **'Текущата парола е грешна'**
  String get settings_password_error_current;

  /// Passwords do not match error
  ///
  /// In bg, this message translates to:
  /// **'Паролите не съвпадат'**
  String get settings_password_error_match;

  /// Data exported success message
  ///
  /// In bg, this message translates to:
  /// **'Данните са експортирани'**
  String get settings_export_success;

  /// Data cleared success message
  ///
  /// In bg, this message translates to:
  /// **'Всички данни са изтрити'**
  String get settings_data_cleared;

  /// Error saving settings
  ///
  /// In bg, this message translates to:
  /// **'Грешка при запазване'**
  String get settings_error_save;

  /// Notifications screen title
  ///
  /// In bg, this message translates to:
  /// **'Известия'**
  String get notifications_title;

  /// Mark all as read button
  ///
  /// In bg, this message translates to:
  /// **'Маркирай всички като прочетени'**
  String get notifications_mark_all_read;

  /// Empty notifications state
  ///
  /// In bg, this message translates to:
  /// **'Всичко е наред!'**
  String get notifications_empty;

  /// Error loading notifications
  ///
  /// In bg, this message translates to:
  /// **'Грешка при зареждане на известията'**
  String get notifications_error_load;

  /// Check-in tomorrow notification
  ///
  /// In bg, this message translates to:
  /// **'{guest} се настанява утре'**
  String notifications_check_in_tomorrow(String guest);

  /// Check-out today notification
  ///
  /// In bg, this message translates to:
  /// **'{guest} напуска днес'**
  String notifications_check_out_today(String guest);

  /// Unpaid reservation notification
  ///
  /// In bg, this message translates to:
  /// **'Резервацията с {guest} е неплатена'**
  String notifications_unpaid(String guest);

  /// Reservation status changed notification
  ///
  /// In bg, this message translates to:
  /// **'Статусът на резервацията е променен'**
  String get notifications_status_changed;

  /// Just now time label
  ///
  /// In bg, this message translates to:
  /// **'Току-що'**
  String get notifications_just_now;

  /// Minutes ago time label
  ///
  /// In bg, this message translates to:
  /// **'Преди {count} мин'**
  String notifications_minutes_ago(int count);

  /// Hours ago time label
  ///
  /// In bg, this message translates to:
  /// **'Преди {count} часа'**
  String notifications_hours_ago(int count);

  /// Yesterday time label
  ///
  /// In bg, this message translates to:
  /// **'Вчера'**
  String get notifications_yesterday;

  /// Days ago time label
  ///
  /// In bg, this message translates to:
  /// **'Преди {count} дни'**
  String notifications_days_ago(int count);

  /// All notifications marked as read message
  ///
  /// In bg, this message translates to:
  /// **'Всички известия са прочетени'**
  String get notifications_marked_read;

  /// Application name
  ///
  /// In bg, this message translates to:
  /// **'My Studio'**
  String get app_name;

  /// Generic error message
  ///
  /// In bg, this message translates to:
  /// **'Нещо се обърка. Опитайте отново.'**
  String get error_generic;

  /// Generic cancel action
  ///
  /// In bg, this message translates to:
  /// **'Отказ'**
  String get action_cancel;

  /// Generic delete action
  ///
  /// In bg, this message translates to:
  /// **'Изтрий'**
  String get action_delete;

  /// Generic save action
  ///
  /// In bg, this message translates to:
  /// **'Запази'**
  String get action_save;

  /// Generic retry action
  ///
  /// In bg, this message translates to:
  /// **'Опитай отново'**
  String get action_retry;

  /// Home navigation tab
  ///
  /// In bg, this message translates to:
  /// **'Начало'**
  String get nav_home;

  /// Calendar navigation tab
  ///
  /// In bg, this message translates to:
  /// **'Календар'**
  String get nav_calendar;

  /// Guests navigation tab
  ///
  /// In bg, this message translates to:
  /// **'Гости'**
  String get nav_guests;

  /// Analytics navigation tab
  ///
  /// In bg, this message translates to:
  /// **'Анализи'**
  String get nav_analytics;

  /// Settings navigation tab
  ///
  /// In bg, this message translates to:
  /// **'Настройки'**
  String get nav_settings;

  /// Generic network error message
  ///
  /// In bg, this message translates to:
  /// **'Мрежова грешка. Моля, опитайте отново.'**
  String get error_network;

  /// Generic field required validation error
  ///
  /// In bg, this message translates to:
  /// **'Полето е задължително'**
  String get error_required;

  /// Password min length validation error
  ///
  /// In bg, this message translates to:
  /// **'Паролата трябва да е поне 8 символа'**
  String get error_password_min_length;

  /// Passwords do not match validation error
  ///
  /// In bg, this message translates to:
  /// **'Паролите не съвпадат'**
  String get error_passwords_dont_match;

  /// Generic retry button
  ///
  /// In bg, this message translates to:
  /// **'Опитай отново'**
  String get button_retry;

  /// Generic cancel button
  ///
  /// In bg, this message translates to:
  /// **'Отказ'**
  String get button_cancel;

  /// Instruction to type DELETE to confirm data clearing
  ///
  /// In bg, this message translates to:
  /// **'Напишете DELETE за потвърждение'**
  String get settings_clear_data_type_delete;

  /// Export data button label
  ///
  /// In bg, this message translates to:
  /// **'Експорт на данни'**
  String get settings_export_data;

  /// Profile saved success message
  ///
  /// In bg, this message translates to:
  /// **'Профилът е запазен'**
  String get settings_profile_saved;

  /// Full name field label in settings
  ///
  /// In bg, this message translates to:
  /// **'Пълно име'**
  String get settings_full_name;

  /// Save profile button label
  ///
  /// In bg, this message translates to:
  /// **'Запази профил'**
  String get settings_save_profile;

  /// Week starts on Monday toggle
  ///
  /// In bg, this message translates to:
  /// **'Седмицата започва от понеделник'**
  String get settings_week_starts_monday;

  /// Enable push notifications toggle
  ///
  /// In bg, this message translates to:
  /// **'Включи push известия'**
  String get settings_notify_push;

  /// Privacy policy link
  ///
  /// In bg, this message translates to:
  /// **'Политика за поверителност'**
  String get settings_privacy_policy;

  /// Revenue label in analytics overview
  ///
  /// In bg, this message translates to:
  /// **'Приходи'**
  String get analytics_revenue;

  /// Expenses label in analytics overview
  ///
  /// In bg, this message translates to:
  /// **'Разходи'**
  String get analytics_expenses;

  /// Expenses breakdown section title
  ///
  /// In bg, this message translates to:
  /// **'Разходи по категории'**
  String get analytics_expenses_breakdown;

  /// Reservation stats section title
  ///
  /// In bg, this message translates to:
  /// **'Статистика на резервациите'**
  String get analytics_reservation_stats;

  /// Nights unit label
  ///
  /// In bg, this message translates to:
  /// **'нощувки'**
  String get analytics_nights;

  /// Most frequent guest label
  ///
  /// In bg, this message translates to:
  /// **'Най-чест гост'**
  String get analytics_most_frequent_guest;

  /// Number of stays
  ///
  /// In bg, this message translates to:
  /// **'{count} престоя'**
  String analytics_stays_count(int count);

  /// Monthly comparison section title
  ///
  /// In bg, this message translates to:
  /// **'Месечно сравнение'**
  String get analytics_monthly_comparison;

  /// Month column header
  ///
  /// In bg, this message translates to:
  /// **'Месец'**
  String get analytics_month;

  /// Nights column header abbreviated
  ///
  /// In bg, this message translates to:
  /// **'Нощ.'**
  String get analytics_nights_short;

  /// Revenue column header abbreviated
  ///
  /// In bg, this message translates to:
  /// **'Прих.'**
  String get analytics_revenue_short;

  /// Expenses column header abbreviated
  ///
  /// In bg, this message translates to:
  /// **'Разх.'**
  String get analytics_expenses_short;

  /// Profit column header abbreviated
  ///
  /// In bg, this message translates to:
  /// **'Печ.'**
  String get analytics_profit_short;

  /// This month period filter
  ///
  /// In bg, this message translates to:
  /// **'Този месец'**
  String get analytics_this_month;

  /// Last month period filter
  ///
  /// In bg, this message translates to:
  /// **'Миналия месец'**
  String get analytics_last_month;

  /// Last 3 months period filter
  ///
  /// In bg, this message translates to:
  /// **'Последни 3 месеца'**
  String get analytics_last_3_months;

  /// Last 6 months period filter
  ///
  /// In bg, this message translates to:
  /// **'Последни 6 месеца'**
  String get analytics_last_6_months;

  /// This year period filter
  ///
  /// In bg, this message translates to:
  /// **'Тази година'**
  String get analytics_this_year;

  /// Custom range period filter
  ///
  /// In bg, this message translates to:
  /// **'По избор'**
  String get analytics_custom;

  /// Confirm new password field label
  ///
  /// In bg, this message translates to:
  /// **'Потвърди нова парола'**
  String get settings_confirm_password;
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
      <String>['bg', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bg':
      return AppLocalizationsBg();
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
