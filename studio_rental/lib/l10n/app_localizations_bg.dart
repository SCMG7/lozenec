// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get splash_app_name => 'My Studio';

  @override
  String get splash_tagline => 'Вашето наемане, организирано.';

  @override
  String get splash_get_started => 'Започнете';

  @override
  String get splash_already_have_account => 'Вече имам акаунт';

  @override
  String get register_title => 'Създай акаунт';

  @override
  String get register_full_name_label => 'Пълно име';

  @override
  String get register_full_name_hint => 'Въведете пълното си име';

  @override
  String get register_email_label => 'Имейл адрес';

  @override
  String get register_email_hint => 'you@example.com';

  @override
  String get register_password_label => 'Парола';

  @override
  String get register_password_hint => 'Създайте парола';

  @override
  String get register_confirm_password_label => 'Потвърди парола';

  @override
  String get register_confirm_password_hint => 'Повторете паролата';

  @override
  String get register_studio_name_label => 'Име на студиото';

  @override
  String get register_studio_name_hint => 'напр. Sunset Studio';

  @override
  String get register_studio_location_label => 'Локация на студиото';

  @override
  String get register_studio_location_hint => 'Адрес (по избор)';

  @override
  String get register_button => 'Създай акаунт';

  @override
  String get register_button_loading => 'Създаване на акаунт...';

  @override
  String get register_already_have_account => 'Вече имате акаунт? Вход';

  @override
  String get register_error_name_required => 'Името е задължително';

  @override
  String get register_error_name_min => 'Името трябва да е поне 2 символа';

  @override
  String get register_error_email_required => 'Имейлът е задължителен';

  @override
  String get register_error_email_invalid => 'Невалиден имейл адрес';

  @override
  String get register_error_password_required => 'Паролата е задължителна';

  @override
  String get register_error_password_min =>
      'Паролата трябва да е поне 8 символа';

  @override
  String get register_error_password_format =>
      'Паролата трябва да съдържа главна буква и цифра';

  @override
  String get register_error_confirm_required => 'Потвърдете паролата';

  @override
  String get register_error_confirm_mismatch => 'Паролите не съвпадат';

  @override
  String get register_error_studio_required =>
      'Името на студиото е задължително';

  @override
  String get register_error_email_exists => 'Този имейл вече е регистриран';

  @override
  String get register_error_network => 'Мрежова грешка. Опитайте отново.';

  @override
  String get login_title => 'Добре дошли отново';

  @override
  String get login_email_label => 'Имейл адрес';

  @override
  String get login_email_hint => 'you@example.com';

  @override
  String get login_password_label => 'Парола';

  @override
  String get login_password_hint => 'Въведете паролата си';

  @override
  String get login_remember_me => 'Запомни ме';

  @override
  String get login_button => 'Вход';

  @override
  String get login_button_loading => 'Влизане...';

  @override
  String get login_forgot_password => 'Забравена парола?';

  @override
  String get login_no_account => 'Нямате акаунт? Регистрация';

  @override
  String get login_error_email_required => 'Имейлът е задължителен';

  @override
  String get login_error_email_invalid => 'Невалиден имейл адрес';

  @override
  String get login_error_password_required => 'Паролата е задължителна';

  @override
  String get login_error_invalid_credentials => 'Невалиден имейл или парола';

  @override
  String get login_error_network => 'Мрежова грешка. Опитайте отново.';

  @override
  String get forgot_title => 'Нулиране на парола';

  @override
  String get forgot_description =>
      'Въведете имейла си и ще ви изпратим линк за нулиране.';

  @override
  String get forgot_email_label => 'Имейл адрес';

  @override
  String get forgot_email_hint => 'you@example.com';

  @override
  String get forgot_button => 'Изпрати линк за нулиране';

  @override
  String get forgot_button_loading => 'Изпращане...';

  @override
  String get forgot_success =>
      'Ако този имейл съществува, линк за нулиране е изпратен.';

  @override
  String get forgot_back_to_login => 'Назад към Вход';

  @override
  String get forgot_error_email_required => 'Имейлът е задължителен';

  @override
  String get forgot_error_email_invalid => 'Невалиден имейл адрес';

  @override
  String get forgot_error_network => 'Мрежова грешка. Опитайте отново.';

  @override
  String get dashboard_tonight => 'Тази вечер';

  @override
  String get dashboard_tonight_free => 'Свободно';

  @override
  String get dashboard_this_month => 'Този месец';

  @override
  String get dashboard_month_revenue => 'Приход този месец';

  @override
  String get dashboard_occupancy_rate => 'Заетост';

  @override
  String get dashboard_upcoming => 'Предстоящи резервации';

  @override
  String get dashboard_see_all => 'Виж всички';

  @override
  String get dashboard_new_reservation => '+ Нова резервация';

  @override
  String get dashboard_open_calendar => 'Календар';

  @override
  String get dashboard_analytics => 'Анализи';

  @override
  String get dashboard_total_revenue => 'Общ приход';

  @override
  String get dashboard_total_expenses => 'Общи разходи';

  @override
  String get dashboard_net_profit => 'Нетна печалба';

  @override
  String dashboard_nights_booked(int booked, int total) {
    return '$booked / $total нощувки';
  }

  @override
  String get dashboard_no_upcoming => 'Няма предстоящи резервации.';

  @override
  String get dashboard_add_first => 'Добавете първата си резервация';

  @override
  String get dashboard_error_load => 'Грешка при зареждане на данните';

  @override
  String get dashboard_retry => 'Опитай отново';

  @override
  String get status_confirmed => 'Потвърдена';

  @override
  String get status_pending => 'Чакаща';

  @override
  String get status_cancelled => 'Отменена';

  @override
  String get payment_unpaid => 'Неплатена';

  @override
  String get payment_partially_paid => 'Частично платена';

  @override
  String get payment_paid => 'Платена';

  @override
  String get calendar_title => 'Календар';

  @override
  String get calendar_today => 'Днес';

  @override
  String get calendar_add_reservation_prompt => 'Добави резервация?';

  @override
  String calendar_nights_booked(int booked, int total) {
    return 'Нощувки: $booked / $total';
  }

  @override
  String calendar_revenue(String amount) {
    return 'Приход: $amount';
  }

  @override
  String get calendar_add_reservation => '+ Добави резервация';

  @override
  String get calendar_legend_available => 'Свободен';

  @override
  String get calendar_legend_reserved => 'Резервиран';

  @override
  String get calendar_legend_check_in => 'Настаняване';

  @override
  String get calendar_legend_check_out => 'Напускане';

  @override
  String get calendar_legend_past => 'Минал';

  @override
  String get calendar_error_load => 'Грешка при зареждане на календара';

  @override
  String get calendar_no_reservations => 'Няма резервации за този месец';

  @override
  String get bottom_sheet_check_in => 'Настаняване';

  @override
  String get bottom_sheet_check_out => 'Напускане';

  @override
  String bottom_sheet_nights(int count) {
    return '$count нощувки';
  }

  @override
  String get bottom_sheet_price_per_night => 'на нощ';

  @override
  String get bottom_sheet_total => 'Общо';

  @override
  String get bottom_sheet_view_details => 'Виж детайли';

  @override
  String get bottom_sheet_edit => 'Редактирай';

  @override
  String get bottom_sheet_notes => 'Бележки';

  @override
  String get bottom_sheet_error => 'Грешка при зареждане';

  @override
  String get add_reservation_title => 'Нова резервация';

  @override
  String get add_reservation_guest_section => 'Гост';

  @override
  String get add_reservation_search_guest => 'Търси гост...';

  @override
  String get add_reservation_create_guest => '+ Създай нов гост';

  @override
  String get add_reservation_dates_section => 'Дати';

  @override
  String get add_reservation_mode_nights => 'Брой нощувки';

  @override
  String get add_reservation_mode_range => 'Период';

  @override
  String get add_reservation_check_in => 'Настаняване';

  @override
  String get add_reservation_check_out => 'Напускане';

  @override
  String get add_reservation_nights => 'Нощувки';

  @override
  String get add_reservation_pricing_section => 'Цена';

  @override
  String get add_reservation_mode_per_night => 'Цена на нощ';

  @override
  String get add_reservation_mode_custom_total => 'Обща цена';

  @override
  String get add_reservation_price_per_night => 'Цена на нощ';

  @override
  String get add_reservation_total_price => 'Обща цена';

  @override
  String get add_reservation_deposit => 'Депозит';

  @override
  String get add_reservation_deposit_received => 'Депозитът получен?';

  @override
  String get add_reservation_status_section => 'Статус';

  @override
  String get add_reservation_payment_section => 'Плащане';

  @override
  String get add_reservation_amount_paid => 'Платена сума';

  @override
  String get add_reservation_notes_section => 'Бележки';

  @override
  String get add_reservation_notes_hint => 'Вътрешни бележки...';

  @override
  String get add_reservation_save => 'Запази резервация';

  @override
  String get add_reservation_cancel => 'Отказ';

  @override
  String get add_reservation_saving => 'Запазване...';

  @override
  String get add_reservation_conflict =>
      'Избраните дати се припокриват с друга резервация';

  @override
  String get add_reservation_error_guest_required => 'Изберете гост';

  @override
  String get add_reservation_error_date_required =>
      'Изберете дата за настаняване';

  @override
  String get add_reservation_error_nights_min => 'Минимум 1 нощувка';

  @override
  String get add_reservation_error_price_required => 'Въведете цена';

  @override
  String get add_reservation_error_price_positive =>
      'Цената трябва да е положителна';

  @override
  String get add_reservation_success => 'Резервацията е създадена';

  @override
  String get add_reservation_error_network =>
      'Мрежова грешка. Опитайте отново.';

  @override
  String get edit_reservation_title => 'Редактирай резервация';

  @override
  String get edit_reservation_save => 'Запази промени';

  @override
  String get edit_reservation_saving => 'Запазване...';

  @override
  String get edit_reservation_delete => 'Изтрий резервация';

  @override
  String get edit_reservation_delete_confirm_title => 'Изтриване на резервация';

  @override
  String get edit_reservation_delete_confirm_message =>
      'Сигурни ли сте? Това не може да бъде отменено.';

  @override
  String get edit_reservation_delete_confirm_cancel => 'Отказ';

  @override
  String get edit_reservation_delete_confirm_delete => 'Изтрий';

  @override
  String get edit_reservation_deleting => 'Изтриване...';

  @override
  String get edit_reservation_success => 'Резервацията е обновена';

  @override
  String get edit_reservation_deleted => 'Резервацията е изтрита';

  @override
  String get edit_reservation_not_found => 'Резервацията не е намерена';

  @override
  String get edit_reservation_error_load =>
      'Грешка при зареждане на резервацията';

  @override
  String get reservation_detail_title => 'Детайли на резервацията';

  @override
  String get reservation_detail_dates => 'Дати и продължителност';

  @override
  String get reservation_detail_check_in => 'Настаняване';

  @override
  String get reservation_detail_check_out => 'Напускане';

  @override
  String get reservation_detail_nights => 'Общо нощувки';

  @override
  String get reservation_detail_financial => 'Финансова информация';

  @override
  String get reservation_detail_price_per_night => 'Цена на нощ';

  @override
  String get reservation_detail_total_price => 'Обща цена';

  @override
  String get reservation_detail_deposit => 'Депозит';

  @override
  String get reservation_detail_amount_paid => 'Платена сума';

  @override
  String get reservation_detail_amount_remaining => 'Оставащо';

  @override
  String get reservation_detail_notes => 'Бележки';

  @override
  String get reservation_detail_no_notes => 'Няма бележки';

  @override
  String get reservation_detail_activity => 'Активност';

  @override
  String get reservation_detail_edit => 'Редактирай резервация';

  @override
  String get reservation_detail_mark_paid => 'Маркирай като платена';

  @override
  String get reservation_detail_delete => 'Изтрий резервация';

  @override
  String get reservation_detail_not_found => 'Резервацията не е намерена';

  @override
  String get reservation_detail_error_load => 'Грешка при зареждане';

  @override
  String get reservation_detail_marked_paid =>
      'Резервацията е маркирана като платена';

  @override
  String get guest_list_title => 'Гости';

  @override
  String get guest_list_search_hint => 'Търси по име, телефон, имейл...';

  @override
  String get guest_list_filter_all => 'Всички';

  @override
  String get guest_list_filter_upcoming => 'Предстоящи';

  @override
  String get guest_list_filter_past => 'Минали';

  @override
  String get guest_list_filter_cancelled => 'Отменени';

  @override
  String get guest_list_sort_name => 'Име А–Я';

  @override
  String get guest_list_sort_recent => 'Последно посещение';

  @override
  String get guest_list_sort_nights => 'Най-много нощувки';

  @override
  String guest_list_stays(int count) {
    return '$count посещения';
  }

  @override
  String get guest_list_no_stays => 'Няма посещения';

  @override
  String guest_list_last_stay(String date) {
    return 'Последно: $date';
  }

  @override
  String guest_list_upcoming_stay(String date) {
    return 'Предстои: $date';
  }

  @override
  String get guest_list_empty =>
      'Все още няма гости. Добавете първата си резервация.';

  @override
  String get guest_list_empty_search => 'Няма намерени гости';

  @override
  String get guest_list_add_guest => 'Добави гост';

  @override
  String get guest_list_error_load => 'Грешка при зареждане на гостите';

  @override
  String get guest_detail_phone => 'Телефон';

  @override
  String get guest_detail_email => 'Имейл';

  @override
  String get guest_detail_nationality => 'Националност';

  @override
  String get guest_detail_total_stays => 'Посещения';

  @override
  String get guest_detail_total_nights => 'Нощувки';

  @override
  String get guest_detail_total_revenue => 'Общ приход';

  @override
  String get guest_detail_notes => 'Бележки';

  @override
  String get guest_detail_no_notes => 'Няма бележки';

  @override
  String get guest_detail_reservations => 'История на резервациите';

  @override
  String get guest_detail_no_reservations => 'Няма резервации за този гост.';

  @override
  String get guest_detail_edit => 'Редактирай';

  @override
  String get guest_detail_delete => 'Изтрий гост';

  @override
  String get guest_detail_delete_confirm_title => 'Изтриване на гост';

  @override
  String get guest_detail_delete_confirm_message =>
      'Сигурни ли сте? Това ще премахне и всички свързани резервации.';

  @override
  String get guest_detail_delete_confirm_cancel => 'Отказ';

  @override
  String get guest_detail_delete_confirm_delete => 'Изтрий';

  @override
  String get guest_detail_deleted => 'Гостът е изтрит';

  @override
  String get guest_detail_not_found => 'Гостът не е намерен';

  @override
  String get guest_detail_error_load => 'Грешка при зареждане';

  @override
  String get guest_detail_has_upcoming =>
      'Гостът има предстоящи резервации. Първо ги отменете или изтрийте.';

  @override
  String get guest_detail_not_provided => 'Не е посочено';

  @override
  String get add_guest_title => 'Нов гост';

  @override
  String get edit_guest_title => 'Редактирай гост';

  @override
  String get guest_form_first_name => 'Име';

  @override
  String get guest_form_first_name_hint => 'Въведете име';

  @override
  String get guest_form_last_name => 'Фамилия (по избор)';

  @override
  String get guest_form_last_name_hint => 'Въведете фамилия';

  @override
  String get guest_form_phone => 'Телефонен номер';

  @override
  String get guest_form_phone_hint => '+359...';

  @override
  String get guest_form_email => 'Имейл адрес';

  @override
  String get guest_form_email_hint => 'guest@email.com';

  @override
  String get guest_form_nationality => 'Националност';

  @override
  String get guest_form_nationality_hint => 'Изберете страна';

  @override
  String get guest_form_id_number => 'ЕГН / Номер на паспорт';

  @override
  String get guest_form_id_number_hint => 'Въведете номер';

  @override
  String get guest_form_notes => 'Бележки за госта';

  @override
  String get guest_form_notes_hint => 'напр. Тих гост, Има куче';

  @override
  String get guest_form_save => 'Запази гост';

  @override
  String get guest_form_cancel => 'Отказ';

  @override
  String get guest_form_saving => 'Запазване...';

  @override
  String get guest_form_error_first_name_required => 'Името е задължително';

  @override
  String get guest_form_error_first_name_min =>
      'Името трябва да е поне 2 символа';

  @override
  String get guest_form_error_last_name_required => 'Фамилията е задължителна';

  @override
  String get guest_form_error_last_name_min =>
      'Фамилията трябва да е поне 2 символа';

  @override
  String get guest_form_error_email_invalid => 'Невалиден имейл адрес';

  @override
  String get guest_form_error_phone_invalid => 'Невалиден телефонен номер';

  @override
  String get guest_form_created => 'Гостът е създаден';

  @override
  String get guest_form_updated => 'Гостът е обновен';

  @override
  String get guest_form_error_network => 'Мрежова грешка. Опитайте отново.';

  @override
  String get expenses_title => 'Разходи';

  @override
  String get expenses_total => 'Общо разходи';

  @override
  String get expenses_largest => 'Най-голям разход';

  @override
  String expenses_count(int count) {
    return '$count записа';
  }

  @override
  String get expenses_filter_all => 'Всички';

  @override
  String get expenses_filter_maintenance => 'Поддръжка';

  @override
  String get expenses_filter_renovation => 'Ремонт';

  @override
  String get expenses_filter_utilities => 'Сметки';

  @override
  String get expenses_filter_cleaning => 'Почистване';

  @override
  String get expenses_filter_supplies => 'Консумативи';

  @override
  String get expenses_filter_taxes => 'Данъци / Такси';

  @override
  String get expenses_filter_other => 'Други';

  @override
  String get expenses_add => '+ Добави разход';

  @override
  String get expenses_empty => 'Няма записани разходи за този месец.';

  @override
  String get expenses_error_load => 'Грешка при зареждане на разходите';

  @override
  String expenses_bottom_total(String amount) {
    return 'Общо: $amount';
  }

  @override
  String get add_expense_title => 'Нов разход';

  @override
  String get edit_expense_title => 'Редактирай разход';

  @override
  String get expense_form_title_label => 'Заглавие / Описание';

  @override
  String get expense_form_title_hint => 'напр. Ремонт на водопровод';

  @override
  String get expense_form_amount_label => 'Сума';

  @override
  String get expense_form_amount_hint => '0.00';

  @override
  String get expense_form_date_label => 'Дата';

  @override
  String get expense_form_category_label => 'Категория';

  @override
  String get expense_form_category_hint => 'Изберете категория';

  @override
  String get expense_form_notes_label => 'Бележки';

  @override
  String get expense_form_notes_hint => 'Допълнителни детайли...';

  @override
  String get expense_form_recurring => 'Повтарящ се разход?';

  @override
  String get expense_form_frequency => 'Честота';

  @override
  String get expense_form_monthly => 'Месечно';

  @override
  String get expense_form_yearly => 'Годишно';

  @override
  String get expense_form_save => 'Запази разход';

  @override
  String get expense_form_cancel => 'Отказ';

  @override
  String get expense_form_saving => 'Запазване...';

  @override
  String get expense_form_delete => 'Изтрий разход';

  @override
  String get expense_form_delete_confirm =>
      'Сигурни ли сте, че искате да изтриете този разход?';

  @override
  String get expense_form_error_title_required => 'Заглавието е задължително';

  @override
  String get expense_form_error_title_min =>
      'Заглавието трябва да е поне 2 символа';

  @override
  String get expense_form_error_amount_required => 'Сумата е задължителна';

  @override
  String get expense_form_error_amount_positive =>
      'Сумата трябва да е положителна';

  @override
  String get expense_form_error_date_required => 'Датата е задължителна';

  @override
  String get expense_form_error_category_required =>
      'Категорията е задължителна';

  @override
  String get expense_form_created => 'Разходът е създаден';

  @override
  String get expense_form_updated => 'Разходът е обновен';

  @override
  String get expense_form_deleted => 'Разходът е изтрит';

  @override
  String get expense_form_error_network => 'Мрежова грешка. Опитайте отново.';

  @override
  String get analytics_title => 'Анализи';

  @override
  String get analytics_period_this_month => 'Този месец';

  @override
  String get analytics_period_last_month => 'Миналия месец';

  @override
  String get analytics_period_last_3 => 'Последни 3 месеца';

  @override
  String get analytics_period_last_6 => 'Последни 6 месеца';

  @override
  String get analytics_period_this_year => 'Тази година';

  @override
  String get analytics_period_custom => 'По избор';

  @override
  String get analytics_total_revenue => 'Общ приход';

  @override
  String get analytics_total_expenses => 'Общи разходи';

  @override
  String get analytics_net_profit => 'Нетна печалба';

  @override
  String get analytics_occupancy => 'Заетост';

  @override
  String analytics_booked_nights(int booked, int total) {
    return '$booked от $total нощувки';
  }

  @override
  String get analytics_revenue_chart => 'Приход по месеци';

  @override
  String get analytics_confirmed => 'Потвърден';

  @override
  String get analytics_pending => 'Чакащ';

  @override
  String get analytics_expenses_chart => 'Разходи по категории';

  @override
  String get analytics_avg_stay => 'Средна продължителност';

  @override
  String get analytics_avg_revenue => 'Среден приход на резервация';

  @override
  String get analytics_longest_stay => 'Най-дълго посещение';

  @override
  String get analytics_most_frequent => 'Най-чест гост';

  @override
  String get analytics_monthly_table => 'Месечно сравнение';

  @override
  String get analytics_month_col => 'Месец';

  @override
  String get analytics_nights_col => 'Нощувки';

  @override
  String get analytics_revenue_col => 'Приход';

  @override
  String get analytics_expenses_col => 'Разходи';

  @override
  String get analytics_profit_col => 'Печалба';

  @override
  String get analytics_seasonal => 'Сезонни тенденции';

  @override
  String get analytics_nights_unit => 'нощувки';

  @override
  String get analytics_stays_unit => 'посещения';

  @override
  String get analytics_empty =>
      'Няма достатъчно данни за анализ. Добавете резервации, за да видите статистики.';

  @override
  String get analytics_error_load => 'Грешка при зареждане на анализите';

  @override
  String get settings_title => 'Настройки';

  @override
  String get settings_profile => 'Профил';

  @override
  String get settings_display_name => 'Име';

  @override
  String get settings_email => 'Имейл';

  @override
  String get settings_change_password => 'Промяна на парола';

  @override
  String get settings_current_password => 'Текуща парола';

  @override
  String get settings_new_password => 'Нова парола';

  @override
  String get settings_confirm_new_password => 'Потвърди нова парола';

  @override
  String get settings_update_password => 'Обнови парола';

  @override
  String get settings_studio => 'Настройки на студиото';

  @override
  String get settings_studio_name => 'Име на студиото';

  @override
  String get settings_studio_address => 'Адрес на студиото';

  @override
  String get settings_default_price => 'Цена на нощ по подразбиране';

  @override
  String get settings_currency => 'Валута';

  @override
  String get settings_check_in_time => 'Час на настаняване';

  @override
  String get settings_check_out_time => 'Час на напускане';

  @override
  String get settings_calendar => 'Настройки на календара';

  @override
  String get settings_week_starts => 'Седмицата започва от';

  @override
  String get settings_sunday => 'Неделя';

  @override
  String get settings_monday => 'Понеделник';

  @override
  String get settings_color_theme => 'Цветова тема за резервации';

  @override
  String get settings_notifications => 'Известия';

  @override
  String get settings_push_enabled => 'Включи известия';

  @override
  String get settings_notify_checkin => 'Известие 1 ден преди настаняване';

  @override
  String get settings_notify_checkout => 'Известие в деня на напускане';

  @override
  String get settings_notify_unpaid => 'Известие за неплатени резервации';

  @override
  String get settings_data => 'Данни';

  @override
  String get settings_export => 'Експорт на данни';

  @override
  String get settings_export_csv => 'Експорт като CSV';

  @override
  String get settings_export_pdf => 'Експорт като PDF';

  @override
  String get settings_clear_data => 'Изтрий всички данни';

  @override
  String get settings_clear_data_confirm => 'Въведете DELETE за потвърждение';

  @override
  String get settings_clear_data_warning =>
      'Това действие е необратимо. Всички резервации, гости и разходи ще бъдат изтрити.';

  @override
  String get settings_about => 'Относно';

  @override
  String get settings_version => 'Версия';

  @override
  String get settings_rate_app => 'Оценете приложението';

  @override
  String get settings_privacy => 'Политика за поверителност';

  @override
  String get settings_terms => 'Условия за ползване';

  @override
  String get settings_logout => 'Изход';

  @override
  String get settings_logout_confirm =>
      'Сигурни ли сте, че искате да излезете?';

  @override
  String get settings_logout_cancel => 'Отказ';

  @override
  String get settings_logout_yes => 'Изход';

  @override
  String get settings_saved => 'Настройките са запазени';

  @override
  String get settings_password_changed => 'Паролата е променена';

  @override
  String get settings_password_error_current => 'Текущата парола е грешна';

  @override
  String get settings_password_error_match => 'Паролите не съвпадат';

  @override
  String get settings_export_success => 'Данните са експортирани';

  @override
  String get settings_data_cleared => 'Всички данни са изтрити';

  @override
  String get settings_error_save => 'Грешка при запазване';

  @override
  String get notifications_title => 'Известия';

  @override
  String get notifications_mark_all_read => 'Маркирай всички като прочетени';

  @override
  String get notifications_empty => 'Всичко е наред!';

  @override
  String get notifications_error_load => 'Грешка при зареждане на известията';

  @override
  String notifications_check_in_tomorrow(String guest) {
    return '$guest се настанява утре';
  }

  @override
  String notifications_check_out_today(String guest) {
    return '$guest напуска днес';
  }

  @override
  String notifications_unpaid(String guest) {
    return 'Резервацията с $guest е неплатена';
  }

  @override
  String get notifications_status_changed =>
      'Статусът на резервацията е променен';

  @override
  String get notifications_just_now => 'Току-що';

  @override
  String notifications_minutes_ago(int count) {
    return 'Преди $count мин';
  }

  @override
  String notifications_hours_ago(int count) {
    return 'Преди $count часа';
  }

  @override
  String get notifications_yesterday => 'Вчера';

  @override
  String notifications_days_ago(int count) {
    return 'Преди $count дни';
  }

  @override
  String get notifications_marked_read => 'Всички известия са прочетени';

  @override
  String get app_name => 'My Studio';

  @override
  String get error_generic => 'Нещо се обърка. Опитайте отново.';

  @override
  String get action_cancel => 'Отказ';

  @override
  String get action_delete => 'Изтрий';

  @override
  String get action_save => 'Запази';

  @override
  String get action_retry => 'Опитай отново';

  @override
  String get nav_home => 'Начало';

  @override
  String get nav_calendar => 'Календар';

  @override
  String get nav_guests => 'Гости';

  @override
  String get nav_analytics => 'Анализи';

  @override
  String get nav_settings => 'Настройки';

  @override
  String get error_network => 'Мрежова грешка. Моля, опитайте отново.';

  @override
  String get error_required => 'Полето е задължително';

  @override
  String get error_password_min_length => 'Паролата трябва да е поне 8 символа';

  @override
  String get error_passwords_dont_match => 'Паролите не съвпадат';

  @override
  String get button_retry => 'Опитай отново';

  @override
  String get button_cancel => 'Отказ';

  @override
  String get settings_clear_data_type_delete =>
      'Напишете DELETE за потвърждение';

  @override
  String get settings_export_data => 'Експорт на данни';

  @override
  String get settings_profile_saved => 'Профилът е запазен';

  @override
  String get settings_full_name => 'Пълно име';

  @override
  String get settings_save_profile => 'Запази профил';

  @override
  String get settings_week_starts_monday => 'Седмицата започва от понеделник';

  @override
  String get settings_notify_push => 'Включи push известия';

  @override
  String get settings_privacy_policy => 'Политика за поверителност';

  @override
  String get analytics_revenue => 'Приходи';

  @override
  String get analytics_expenses => 'Разходи';

  @override
  String get analytics_expenses_breakdown => 'Разходи по категории';

  @override
  String get analytics_reservation_stats => 'Статистика на резервациите';

  @override
  String get analytics_nights => 'нощувки';

  @override
  String get analytics_most_frequent_guest => 'Най-чест гост';

  @override
  String analytics_stays_count(int count) {
    return '$count престоя';
  }

  @override
  String get analytics_monthly_comparison => 'Месечно сравнение';

  @override
  String get analytics_month => 'Месец';

  @override
  String get analytics_nights_short => 'Нощ.';

  @override
  String get analytics_revenue_short => 'Прих.';

  @override
  String get analytics_expenses_short => 'Разх.';

  @override
  String get analytics_profit_short => 'Печ.';

  @override
  String get analytics_this_month => 'Този месец';

  @override
  String get analytics_last_month => 'Миналия месец';

  @override
  String get analytics_last_3_months => 'Последни 3 месеца';

  @override
  String get analytics_last_6_months => 'Последни 6 месеца';

  @override
  String get analytics_this_year => 'Тази година';

  @override
  String get analytics_custom => 'По избор';

  @override
  String get settings_confirm_password => 'Потвърди нова парола';
}
