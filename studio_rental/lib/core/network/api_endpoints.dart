class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String verifyToken = '/auth/verify-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String changePassword = '/auth/change-password';
  static const String updateProfile = '/auth/profile';
  static const String updateSettings = '/auth/settings';
  static const String logout = '/auth/logout';

  // Reservations
  static const String reservations = '/reservations';
  static const String reservationCalendar = '/reservations/calendar';
  static const String reservationCheckConflict = '/reservations/check-conflict';
  static const String reservationByDate = '/reservations/by-date';
  static String reservationById(String id) => '/reservations/$id';
  static String reservationSummary(String id) => '/reservations/$id/summary';
  static String reservationMarkPaid(String id) => '/reservations/$id/mark-paid';

  // Guests
  static const String guests = '/guests';
  static const String guestSearch = '/guests/search';
  static String guestById(String id) => '/guests/$id';

  // Expenses
  static const String expenses = '/expenses';
  static const String expensesSummary = '/expenses/summary';
  static const String expensesAnnualSummary = '/expenses/annual-summary';
  static String expenseById(String id) => '/expenses/$id';

  // Dashboard
  static const String dashboard = '/dashboard';

  // Analytics
  static const String analytics = '/analytics';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static String notificationMarkRead(String id) => '/notifications/$id/read';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';

  // Data
  static const String dataExport = '/data/export';
  static const String dataClear = '/data/clear';
}
