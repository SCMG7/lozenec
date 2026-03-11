import 'package:studio_rental/core/network/api_client.dart';
import 'package:studio_rental/core/network/api_endpoints.dart';
import '../models/calendar_reservation_model.dart';
import '../../domain/entities/month_summary.dart';
import '../../domain/repositories/calendar_repository.dart';

class CalendarRemoteDatasource {
  final ApiClient apiClient;

  CalendarRemoteDatasource({required this.apiClient});

  Future<CalendarMonthData> getCalendarMonth(String yearMonth) async {
    final response = await apiClient.dio.get(
      ApiEndpoints.reservationCalendar,
      queryParameters: {'month': yearMonth},
    );
    final data = response.data['data'] as Map<String, dynamic>;

    final reservationsJson = data['reservations'] as List<dynamic>? ?? [];
    final reservations = reservationsJson
        .map((e) =>
            CalendarReservationModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final summaryJson = data['summary'] as Map<String, dynamic>? ?? {};
    final summary = MonthSummary(
      nightsBooked: summaryJson['nights_booked'] as int? ??
          summaryJson['total_reservations'] as int? ?? 0,
      totalNights: summaryJson['total_nights'] as int? ?? 0,
      revenue: summaryJson['revenue'] as int? ??
          summaryJson['total_revenue'] as int? ?? 0,
    );

    return CalendarMonthData(
      reservations: reservations,
      summary: summary,
    );
  }
}
