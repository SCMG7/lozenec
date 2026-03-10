import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _fullDate = DateFormat('d MMM yyyy', 'bg_BG');
  static final _shortDate = DateFormat('d MMM', 'bg_BG');
  static final _monthYear = DateFormat('MMMM yyyy', 'bg_BG');
  static final _dayOfWeek = DateFormat('EEEE, d MMM yyyy', 'bg_BG');
  static final _isoDate = DateFormat('yyyy-MM-dd');
  static final _yearMonth = DateFormat('yyyy-MM');

  static String fullDate(DateTime date) => _fullDate.format(date);
  static String shortDate(DateTime date) => _shortDate.format(date);
  static String monthYear(DateTime date) => _monthYear.format(date);
  static String dayOfWeek(DateTime date) => _dayOfWeek.format(date);
  static String isoDate(DateTime date) => _isoDate.format(date);
  static String yearMonth(DateTime date) => _yearMonth.format(date);

  static DateTime parseIso(String iso) => DateTime.parse(iso);

  static int nightsBetween(DateTime checkIn, DateTime checkOut) {
    return checkOut.difference(checkIn).inDays;
  }
}
