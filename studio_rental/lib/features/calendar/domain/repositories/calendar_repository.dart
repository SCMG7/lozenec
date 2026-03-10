import '../entities/calendar_reservation.dart';
import '../entities/month_summary.dart';

class CalendarMonthData {
  final List<CalendarReservation> reservations;
  final MonthSummary summary;

  const CalendarMonthData({
    required this.reservations,
    required this.summary,
  });
}

abstract class CalendarRepository {
  Future<CalendarMonthData> getCalendarMonth(String yearMonth);
}
