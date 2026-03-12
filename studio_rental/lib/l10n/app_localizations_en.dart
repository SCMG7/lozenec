// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get splash_app_name => 'My Studio';

  @override
  String get splash_tagline => 'Your rental, organized.';

  @override
  String get splash_get_started => 'Get Started';

  @override
  String get splash_already_have_account => 'I already have an account';

  @override
  String get register_title => 'Create Account';

  @override
  String get register_full_name_label => 'Full Name';

  @override
  String get register_full_name_hint => 'Enter your full name';

  @override
  String get register_email_label => 'Email Address';

  @override
  String get register_email_hint => 'you@example.com';

  @override
  String get register_password_label => 'Password';

  @override
  String get register_password_hint => 'Create a password';

  @override
  String get register_confirm_password_label => 'Confirm Password';

  @override
  String get register_confirm_password_hint => 'Repeat your password';

  @override
  String get register_studio_name_label => 'Studio Name';

  @override
  String get register_studio_name_hint => 'e.g. Sunset Studio';

  @override
  String get register_studio_location_label => 'Studio Location';

  @override
  String get register_studio_location_hint => 'Address (optional)';

  @override
  String get register_button => 'Create Account';

  @override
  String get register_button_loading => 'Creating Account...';

  @override
  String get register_already_have_account => 'Already have an account? Log In';

  @override
  String get register_error_name_required => 'Name is required';

  @override
  String get register_error_name_min => 'Name must be at least 2 characters';

  @override
  String get register_error_email_required => 'Email is required';

  @override
  String get register_error_email_invalid => 'Invalid email address';

  @override
  String get register_error_password_required => 'Password is required';

  @override
  String get register_error_password_min =>
      'Password must be at least 8 characters';

  @override
  String get register_error_password_format =>
      'Password must contain an uppercase letter and a number';

  @override
  String get register_error_confirm_required => 'Please confirm your password';

  @override
  String get register_error_confirm_mismatch => 'Passwords do not match';

  @override
  String get register_error_studio_required => 'Studio name is required';

  @override
  String get register_error_email_exists => 'This email is already registered';

  @override
  String get register_error_network => 'Network error. Please try again.';

  @override
  String get login_title => 'Welcome Back';

  @override
  String get login_email_label => 'Email Address';

  @override
  String get login_email_hint => 'you@example.com';

  @override
  String get login_password_label => 'Password';

  @override
  String get login_password_hint => 'Enter your password';

  @override
  String get login_remember_me => 'Remember me';

  @override
  String get login_button => 'Log In';

  @override
  String get login_button_loading => 'Logging in...';

  @override
  String get login_forgot_password => 'Forgot Password?';

  @override
  String get login_no_account => 'Don\'t have an account? Register';

  @override
  String get login_error_email_required => 'Email is required';

  @override
  String get login_error_email_invalid => 'Invalid email address';

  @override
  String get login_error_password_required => 'Password is required';

  @override
  String get login_error_invalid_credentials => 'Invalid email or password';

  @override
  String get login_error_network => 'Network error. Please try again.';

  @override
  String get forgot_title => 'Reset Password';

  @override
  String get forgot_description =>
      'Enter your email and we\'ll send you a reset link.';

  @override
  String get forgot_email_label => 'Email Address';

  @override
  String get forgot_email_hint => 'you@example.com';

  @override
  String get forgot_button => 'Send Reset Link';

  @override
  String get forgot_button_loading => 'Sending...';

  @override
  String get forgot_success =>
      'If this email exists, a reset link has been sent.';

  @override
  String get forgot_back_to_login => 'Back to Login';

  @override
  String get forgot_error_email_required => 'Email is required';

  @override
  String get forgot_error_email_invalid => 'Invalid email address';

  @override
  String get forgot_error_network => 'Network error. Please try again.';

  @override
  String get dashboard_tonight => 'Tonight';

  @override
  String get dashboard_tonight_free => 'Free';

  @override
  String get dashboard_this_month => 'This Month';

  @override
  String get dashboard_month_revenue => 'This Month\'s Revenue';

  @override
  String get dashboard_occupancy_rate => 'Occupancy Rate';

  @override
  String get dashboard_upcoming => 'Upcoming Reservations';

  @override
  String get dashboard_see_all => 'See All';

  @override
  String get dashboard_new_reservation => '+ New Reservation';

  @override
  String get dashboard_open_calendar => 'Open Calendar';

  @override
  String get dashboard_analytics => 'Analytics';

  @override
  String get dashboard_total_revenue => 'Total Revenue';

  @override
  String get dashboard_total_expenses => 'Total Expenses';

  @override
  String get dashboard_net_profit => 'Net Profit';

  @override
  String dashboard_nights_booked(int booked, int total) {
    return '$booked / $total nights';
  }

  @override
  String get dashboard_no_upcoming => 'No upcoming reservations.';

  @override
  String get dashboard_add_first => 'Add your first reservation';

  @override
  String get dashboard_error_load => 'Error loading data';

  @override
  String get dashboard_retry => 'Retry';

  @override
  String get status_confirmed => 'Confirmed';

  @override
  String get status_pending => 'Pending';

  @override
  String get status_cancelled => 'Cancelled';

  @override
  String get payment_unpaid => 'Unpaid';

  @override
  String get payment_partially_paid => 'Partially Paid';

  @override
  String get payment_paid => 'Paid';

  @override
  String get calendar_title => 'Calendar';

  @override
  String get calendar_today => 'Today';

  @override
  String get calendar_add_reservation_prompt => 'Add Reservation?';

  @override
  String calendar_nights_booked(int booked, int total) {
    return 'Nights booked: $booked / $total';
  }

  @override
  String calendar_revenue(String amount) {
    return 'Revenue: $amount';
  }

  @override
  String get calendar_add_reservation => '+ Add Reservation';

  @override
  String get calendar_legend_available => 'Available';

  @override
  String get calendar_legend_reserved => 'Reserved';

  @override
  String get calendar_legend_check_in => 'Check-in';

  @override
  String get calendar_legend_check_out => 'Check-out';

  @override
  String get calendar_legend_past => 'Past';

  @override
  String get calendar_error_load => 'Error loading calendar';

  @override
  String get calendar_no_reservations => 'No reservations this month';

  @override
  String get bottom_sheet_check_in => 'Check-in';

  @override
  String get bottom_sheet_check_out => 'Check-out';

  @override
  String bottom_sheet_nights(int count) {
    return '$count nights';
  }

  @override
  String get bottom_sheet_price_per_night => 'per night';

  @override
  String get bottom_sheet_total => 'Total';

  @override
  String get bottom_sheet_view_details => 'View Full Details';

  @override
  String get bottom_sheet_edit => 'Edit';

  @override
  String get bottom_sheet_notes => 'Notes';

  @override
  String get bottom_sheet_error => 'Error loading data';

  @override
  String get add_reservation_title => 'New Reservation';

  @override
  String get add_reservation_guest_section => 'Guest';

  @override
  String get add_reservation_search_guest => 'Search guest...';

  @override
  String get add_reservation_create_guest => '+ Create New Guest';

  @override
  String get add_reservation_dates_section => 'Dates';

  @override
  String get add_reservation_mode_nights => 'Number of Nights';

  @override
  String get add_reservation_mode_range => 'Date Range';

  @override
  String get add_reservation_check_in => 'Check-in';

  @override
  String get add_reservation_check_out => 'Check-out';

  @override
  String get add_reservation_nights => 'Nights';

  @override
  String get add_reservation_pricing_section => 'Pricing';

  @override
  String get add_reservation_mode_per_night => 'Price per Night';

  @override
  String get add_reservation_mode_custom_total => 'Custom Total Price';

  @override
  String get add_reservation_price_per_night => 'Price per night';

  @override
  String get add_reservation_total_price => 'Total price';

  @override
  String get add_reservation_deposit => 'Deposit';

  @override
  String get add_reservation_deposit_received => 'Deposit received?';

  @override
  String get add_reservation_status_section => 'Status';

  @override
  String get add_reservation_payment_section => 'Payment';

  @override
  String get add_reservation_amount_paid => 'Amount paid';

  @override
  String get add_reservation_notes_section => 'Notes';

  @override
  String get add_reservation_notes_hint => 'Internal notes...';

  @override
  String get add_reservation_save => 'Save Reservation';

  @override
  String get add_reservation_cancel => 'Cancel';

  @override
  String get add_reservation_saving => 'Saving...';

  @override
  String get add_reservation_conflict =>
      'Selected dates overlap with an existing reservation';

  @override
  String get add_reservation_error_guest_required => 'Please select a guest';

  @override
  String get add_reservation_error_date_required =>
      'Please select a check-in date';

  @override
  String get add_reservation_error_nights_min => 'Minimum 1 night';

  @override
  String get add_reservation_error_price_required => 'Please enter a price';

  @override
  String get add_reservation_error_price_positive => 'Price must be positive';

  @override
  String get add_reservation_success => 'Reservation created successfully';

  @override
  String get add_reservation_error_network =>
      'Network error. Please try again.';

  @override
  String get edit_reservation_title => 'Edit Reservation';

  @override
  String get edit_reservation_save => 'Save Changes';

  @override
  String get edit_reservation_saving => 'Saving...';

  @override
  String get edit_reservation_delete => 'Delete Reservation';

  @override
  String get edit_reservation_delete_confirm_title => 'Delete Reservation';

  @override
  String get edit_reservation_delete_confirm_message =>
      'Are you sure? This cannot be undone.';

  @override
  String get edit_reservation_delete_confirm_cancel => 'Cancel';

  @override
  String get edit_reservation_delete_confirm_delete => 'Delete';

  @override
  String get edit_reservation_deleting => 'Deleting...';

  @override
  String get edit_reservation_success => 'Reservation updated successfully';

  @override
  String get edit_reservation_deleted => 'Reservation deleted successfully';

  @override
  String get edit_reservation_not_found => 'Reservation not found';

  @override
  String get edit_reservation_error_load => 'Error loading reservation';

  @override
  String get reservation_detail_title => 'Reservation Details';

  @override
  String get reservation_detail_dates => 'Dates & Duration';

  @override
  String get reservation_detail_check_in => 'Check-in';

  @override
  String get reservation_detail_check_out => 'Check-out';

  @override
  String get reservation_detail_nights => 'Total nights';

  @override
  String get reservation_detail_financial => 'Financial';

  @override
  String get reservation_detail_price_per_night => 'Price per night';

  @override
  String get reservation_detail_total_price => 'Total price';

  @override
  String get reservation_detail_deposit => 'Deposit';

  @override
  String get reservation_detail_amount_paid => 'Amount paid';

  @override
  String get reservation_detail_amount_remaining => 'Amount remaining';

  @override
  String get reservation_detail_notes => 'Notes';

  @override
  String get reservation_detail_no_notes => 'No notes';

  @override
  String get reservation_detail_activity => 'Activity Log';

  @override
  String get reservation_detail_edit => 'Edit Reservation';

  @override
  String get reservation_detail_mark_paid => 'Mark as Paid';

  @override
  String get reservation_detail_delete => 'Delete Reservation';

  @override
  String get reservation_detail_not_found => 'Reservation not found';

  @override
  String get reservation_detail_error_load => 'Error loading reservation';

  @override
  String get reservation_detail_marked_paid => 'Reservation marked as paid';

  @override
  String get guest_list_title => 'Guests';

  @override
  String get guest_list_search_hint => 'Search by name, phone, email...';

  @override
  String get guest_list_filter_all => 'All';

  @override
  String get guest_list_filter_upcoming => 'Upcoming';

  @override
  String get guest_list_filter_past => 'Past';

  @override
  String get guest_list_filter_cancelled => 'Cancelled';

  @override
  String get guest_list_sort_name => 'Name A–Z';

  @override
  String get guest_list_sort_recent => 'Most Recent';

  @override
  String get guest_list_sort_nights => 'Most Nights Stayed';

  @override
  String guest_list_stays(int count) {
    return '$count stays';
  }

  @override
  String get guest_list_no_stays => 'No stays';

  @override
  String guest_list_last_stay(String date) {
    return 'Last: $date';
  }

  @override
  String guest_list_upcoming_stay(String date) {
    return 'Upcoming: $date';
  }

  @override
  String get guest_list_empty => 'No guests yet. Add your first reservation.';

  @override
  String get guest_list_empty_search => 'No guests found';

  @override
  String get guest_list_add_guest => 'Add Guest';

  @override
  String get guest_list_error_load => 'Error loading guests';

  @override
  String get guest_detail_phone => 'Phone';

  @override
  String get guest_detail_email => 'Email';

  @override
  String get guest_detail_nationality => 'Nationality';

  @override
  String get guest_detail_total_stays => 'Total stays';

  @override
  String get guest_detail_total_nights => 'Total nights';

  @override
  String get guest_detail_total_revenue => 'Total revenue';

  @override
  String get guest_detail_notes => 'Notes';

  @override
  String get guest_detail_no_notes => 'No notes';

  @override
  String get guest_detail_reservations => 'Reservation History';

  @override
  String get guest_detail_no_reservations => 'No reservations for this guest.';

  @override
  String get guest_detail_edit => 'Edit';

  @override
  String get guest_detail_delete => 'Delete Guest';

  @override
  String get guest_detail_delete_confirm_title => 'Delete Guest';

  @override
  String get guest_detail_delete_confirm_message =>
      'Are you sure? This will also remove all associated reservations.';

  @override
  String get guest_detail_delete_confirm_cancel => 'Cancel';

  @override
  String get guest_detail_delete_confirm_delete => 'Delete';

  @override
  String get guest_detail_deleted => 'Guest deleted successfully';

  @override
  String get guest_detail_not_found => 'Guest not found';

  @override
  String get guest_detail_error_load => 'Error loading guest';

  @override
  String get guest_detail_has_upcoming =>
      'Guest has upcoming reservations. Cancel or delete them first.';

  @override
  String get guest_detail_not_provided => 'Not provided';

  @override
  String get add_guest_title => 'New Guest';

  @override
  String get edit_guest_title => 'Edit Guest';

  @override
  String get guest_form_first_name => 'First Name';

  @override
  String get guest_form_first_name_hint => 'Enter first name';

  @override
  String get guest_form_last_name => 'Last Name (optional)';

  @override
  String get guest_form_last_name_hint => 'Enter last name';

  @override
  String get guest_form_phone => 'Phone Number';

  @override
  String get guest_form_phone_hint => '+359...';

  @override
  String get guest_form_email => 'Email Address';

  @override
  String get guest_form_email_hint => 'guest@email.com';

  @override
  String get guest_form_nationality => 'Nationality';

  @override
  String get guest_form_nationality_hint => 'Select country';

  @override
  String get guest_form_id_number => 'ID / Passport Number';

  @override
  String get guest_form_id_number_hint => 'Enter ID number';

  @override
  String get guest_form_notes => 'Guest notes';

  @override
  String get guest_form_notes_hint => 'e.g. Quiet guest, Has a dog';

  @override
  String get guest_form_save => 'Save Guest';

  @override
  String get guest_form_cancel => 'Cancel';

  @override
  String get guest_form_saving => 'Saving...';

  @override
  String get guest_form_error_first_name_required => 'First name is required';

  @override
  String get guest_form_error_first_name_min =>
      'First name must be at least 2 characters';

  @override
  String get guest_form_error_last_name_required => 'Last name is required';

  @override
  String get guest_form_error_last_name_min =>
      'Last name must be at least 2 characters';

  @override
  String get guest_form_error_email_invalid => 'Invalid email address';

  @override
  String get guest_form_error_phone_invalid => 'Invalid phone number';

  @override
  String get guest_form_created => 'Guest created successfully';

  @override
  String get guest_form_updated => 'Guest updated successfully';

  @override
  String get guest_form_error_network => 'Network error. Please try again.';

  @override
  String get expenses_title => 'Expenses';

  @override
  String get expenses_total => 'Total Expenses';

  @override
  String get expenses_largest => 'Largest Expense';

  @override
  String expenses_count(int count) {
    return '$count entries';
  }

  @override
  String get expenses_filter_all => 'All';

  @override
  String get expenses_filter_maintenance => 'Maintenance';

  @override
  String get expenses_filter_furniture => 'Furniture';

  @override
  String get expenses_filter_appliances => 'Appliances';

  @override
  String get expenses_filter_utilities => 'Utilities';

  @override
  String get expenses_filter_cleaning => 'Cleaning';

  @override
  String get expenses_filter_supplies => 'Supplies';

  @override
  String get expenses_filter_taxes => 'Taxes / Fees';

  @override
  String get expenses_filter_other => 'Other';

  @override
  String get expenses_revenue => 'Revenue';

  @override
  String get expenses_net_profit => 'Net Profit';

  @override
  String get expenses_view_monthly => 'Monthly';

  @override
  String get expenses_view_annual => 'Annual';

  @override
  String get expenses_monthly_breakdown => 'Monthly Breakdown';

  @override
  String get expenses_category_breakdown => 'Category Breakdown';

  @override
  String get expenses_add => '+ Add Expense';

  @override
  String get expenses_empty => 'No expenses recorded for this period.';

  @override
  String get expenses_error_load => 'Error loading expenses';

  @override
  String expenses_bottom_total(String amount) {
    return 'Total: $amount';
  }

  @override
  String get add_expense_title => 'New Expense';

  @override
  String get edit_expense_title => 'Edit Expense';

  @override
  String get expense_form_title_label => 'Title / Description';

  @override
  String get expense_form_title_hint => 'e.g. Plumber repair';

  @override
  String get expense_form_amount_label => 'Amount';

  @override
  String get expense_form_amount_hint => '0.00';

  @override
  String get expense_form_date_label => 'Date';

  @override
  String get expense_form_category_label => 'Category';

  @override
  String get expense_form_category_hint => 'Select category';

  @override
  String get expense_form_notes_label => 'Notes';

  @override
  String get expense_form_notes_hint => 'Additional details...';

  @override
  String get expense_form_recurring => 'Recurring expense?';

  @override
  String get expense_form_frequency => 'Frequency';

  @override
  String get expense_form_monthly => 'Monthly';

  @override
  String get expense_form_yearly => 'Yearly';

  @override
  String get expense_form_save => 'Save Expense';

  @override
  String get expense_form_cancel => 'Cancel';

  @override
  String get expense_form_saving => 'Saving...';

  @override
  String get expense_form_delete => 'Delete Expense';

  @override
  String get expense_form_delete_confirm =>
      'Are you sure you want to delete this expense?';

  @override
  String get expense_form_error_title_required => 'Title is required';

  @override
  String get expense_form_error_title_min =>
      'Title must be at least 2 characters';

  @override
  String get expense_form_error_amount_required => 'Amount is required';

  @override
  String get expense_form_error_amount_positive => 'Amount must be positive';

  @override
  String get expense_form_error_date_required => 'Date is required';

  @override
  String get expense_form_error_category_required => 'Category is required';

  @override
  String get expense_form_created => 'Expense created successfully';

  @override
  String get expense_form_updated => 'Expense updated successfully';

  @override
  String get expense_form_deleted => 'Expense deleted successfully';

  @override
  String get expense_form_error_network => 'Network error. Please try again.';

  @override
  String get analytics_title => 'Analytics';

  @override
  String get analytics_period_this_month => 'This Month';

  @override
  String get analytics_period_last_month => 'Last Month';

  @override
  String get analytics_period_last_3 => 'Last 3 Months';

  @override
  String get analytics_period_last_6 => 'Last 6 Months';

  @override
  String get analytics_period_this_year => 'This Year';

  @override
  String get analytics_period_custom => 'Custom Range';

  @override
  String get analytics_total_revenue => 'Total Revenue';

  @override
  String get analytics_total_expenses => 'Total Expenses';

  @override
  String get analytics_net_profit => 'Net Profit';

  @override
  String get analytics_occupancy => 'Occupancy';

  @override
  String analytics_booked_nights(int booked, int total) {
    return '$booked of $total nights';
  }

  @override
  String get analytics_revenue_chart => 'Revenue Breakdown';

  @override
  String get analytics_confirmed => 'Confirmed';

  @override
  String get analytics_pending => 'Pending';

  @override
  String get analytics_expenses_chart => 'Expenses by Category';

  @override
  String get analytics_avg_stay => 'Avg. Length of Stay';

  @override
  String get analytics_avg_revenue => 'Avg. Revenue per Reservation';

  @override
  String get analytics_longest_stay => 'Longest Stay';

  @override
  String get analytics_most_frequent => 'Most Frequent Guest';

  @override
  String get analytics_monthly_table => 'Monthly Comparison';

  @override
  String get analytics_month_col => 'Month';

  @override
  String get analytics_nights_col => 'Nights';

  @override
  String get analytics_revenue_col => 'Revenue';

  @override
  String get analytics_expenses_col => 'Expenses';

  @override
  String get analytics_profit_col => 'Profit';

  @override
  String get analytics_seasonal => 'Seasonal Trends';

  @override
  String get analytics_nights_unit => 'nights';

  @override
  String get analytics_stays_unit => 'stays';

  @override
  String get analytics_empty =>
      'Not enough data for analytics. Add reservations to see insights.';

  @override
  String get analytics_error_load => 'Error loading analytics';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_profile => 'Profile';

  @override
  String get settings_display_name => 'Display Name';

  @override
  String get settings_email => 'Email';

  @override
  String get settings_change_password => 'Change Password';

  @override
  String get settings_current_password => 'Current Password';

  @override
  String get settings_new_password => 'New Password';

  @override
  String get settings_confirm_new_password => 'Confirm New Password';

  @override
  String get settings_update_password => 'Update Password';

  @override
  String get settings_studio => 'Studio Settings';

  @override
  String get settings_studio_name => 'Studio Name';

  @override
  String get settings_studio_address => 'Studio Address';

  @override
  String get settings_default_price => 'Default Price per Night';

  @override
  String get settings_currency => 'Currency';

  @override
  String get settings_check_in_time => 'Default Check-in Time';

  @override
  String get settings_check_out_time => 'Default Check-out Time';

  @override
  String get settings_calendar => 'Calendar Settings';

  @override
  String get settings_week_starts => 'Week starts on';

  @override
  String get settings_sunday => 'Sunday';

  @override
  String get settings_monday => 'Monday';

  @override
  String get settings_color_theme => 'Color theme for reserved days';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_push_enabled => 'Enable push notifications';

  @override
  String get settings_notify_checkin => 'Notify 1 day before check-in';

  @override
  String get settings_notify_checkout => 'Notify on check-out day';

  @override
  String get settings_notify_unpaid => 'Notify for unpaid reservations';

  @override
  String get settings_data => 'Data';

  @override
  String get settings_export => 'Export Data';

  @override
  String get settings_export_csv => 'Export as CSV';

  @override
  String get settings_export_pdf => 'Export as PDF';

  @override
  String get settings_clear_data => 'Clear All Data';

  @override
  String get settings_clear_data_confirm => 'Type DELETE to confirm';

  @override
  String get settings_clear_data_warning =>
      'This action is irreversible. All reservations, guests, and expenses will be deleted.';

  @override
  String get settings_about => 'About';

  @override
  String get settings_version => 'Version';

  @override
  String get settings_rate_app => 'Rate the App';

  @override
  String get settings_privacy => 'Privacy Policy';

  @override
  String get settings_terms => 'Terms of Use';

  @override
  String get settings_logout => 'Log Out';

  @override
  String get settings_logout_confirm => 'Are you sure you want to log out?';

  @override
  String get settings_logout_cancel => 'Cancel';

  @override
  String get settings_logout_yes => 'Log Out';

  @override
  String get settings_saved => 'Settings saved';

  @override
  String get settings_password_changed => 'Password changed successfully';

  @override
  String get settings_password_error_current => 'Current password is incorrect';

  @override
  String get settings_password_error_match => 'Passwords do not match';

  @override
  String get settings_export_success => 'Data exported successfully';

  @override
  String get settings_data_cleared => 'All data cleared successfully';

  @override
  String get settings_error_save => 'Error saving settings';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_mark_all_read => 'Mark all as read';

  @override
  String get notifications_empty => 'You\'re all caught up!';

  @override
  String get notifications_error_load => 'Error loading notifications';

  @override
  String notifications_check_in_tomorrow(String guest) {
    return '$guest checks in tomorrow';
  }

  @override
  String notifications_check_out_today(String guest) {
    return '$guest checks out today';
  }

  @override
  String notifications_unpaid(String guest) {
    return 'Reservation with $guest is unpaid';
  }

  @override
  String get notifications_status_changed => 'Reservation status changed';

  @override
  String get notifications_just_now => 'Just now';

  @override
  String notifications_minutes_ago(int count) {
    return '$count min ago';
  }

  @override
  String notifications_hours_ago(int count) {
    return '$count hours ago';
  }

  @override
  String get notifications_yesterday => 'Yesterday';

  @override
  String notifications_days_ago(int count) {
    return '$count days ago';
  }

  @override
  String get notifications_marked_read => 'All notifications marked as read';

  @override
  String get app_name => 'My Studio';

  @override
  String get error_generic => 'Something went wrong. Please try again.';

  @override
  String get action_cancel => 'Cancel';

  @override
  String get action_delete => 'Delete';

  @override
  String get action_save => 'Save';

  @override
  String get action_retry => 'Retry';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_calendar => 'Calendar';

  @override
  String get nav_guests => 'Guests';

  @override
  String get nav_analytics => 'Analytics';

  @override
  String get nav_settings => 'Settings';

  @override
  String get nav_expenses => 'Expenses';

  @override
  String get error_network => 'Network error. Please try again.';

  @override
  String get error_required => 'This field is required';

  @override
  String get error_password_min_length =>
      'Password must be at least 8 characters';

  @override
  String get error_passwords_dont_match => 'Passwords do not match';

  @override
  String get button_retry => 'Retry';

  @override
  String get button_cancel => 'Cancel';

  @override
  String get settings_clear_data_type_delete => 'Type DELETE to confirm';

  @override
  String get settings_export_data => 'Export Data';

  @override
  String get settings_profile_saved => 'Profile saved';

  @override
  String get settings_full_name => 'Full Name';

  @override
  String get settings_save_profile => 'Save Profile';

  @override
  String get settings_week_starts_monday => 'Week starts on Monday';

  @override
  String get settings_notify_push => 'Enable push notifications';

  @override
  String get settings_privacy_policy => 'Privacy Policy';

  @override
  String get analytics_revenue => 'Revenue';

  @override
  String get analytics_expenses => 'Expenses';

  @override
  String get analytics_expenses_breakdown => 'Expenses by Category';

  @override
  String get analytics_reservation_stats => 'Reservation Statistics';

  @override
  String get analytics_nights => 'nights';

  @override
  String get analytics_most_frequent_guest => 'Most Frequent Guest';

  @override
  String analytics_stays_count(int count) {
    return '$count stays';
  }

  @override
  String get analytics_monthly_comparison => 'Monthly Comparison';

  @override
  String get analytics_month => 'Month';

  @override
  String get analytics_nights_short => 'Nights';

  @override
  String get analytics_revenue_short => 'Revenue';

  @override
  String get analytics_expenses_short => 'Expenses';

  @override
  String get analytics_profit_short => 'Profit';

  @override
  String get analytics_this_month => 'This Month';

  @override
  String get analytics_last_month => 'Last Month';

  @override
  String get analytics_last_3_months => 'Last 3 Months';

  @override
  String get analytics_last_6_months => 'Last 6 Months';

  @override
  String get analytics_this_year => 'This Year';

  @override
  String get analytics_custom => 'Custom Range';

  @override
  String get settings_confirm_password => 'Confirm New Password';
}
