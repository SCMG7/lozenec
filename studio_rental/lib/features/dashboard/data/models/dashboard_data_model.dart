import '../../domain/entities/dashboard_data.dart';
import 'reservation_summary_model.dart';

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    super.userName,
    super.tonightGuest,
    required super.monthNightsBooked,
    required super.monthTotalNights,
    required super.monthRevenue,
    required super.occupancyRate,
    required super.monthExpenses,
    required super.monthNetProfit,
    required super.upcomingReservations,
    required super.unreadNotificationCount,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    final reservationsJson =
        json['upcoming_reservations'] as List<dynamic>? ?? [];
    final reservations = reservationsJson
        .map((e) =>
            ReservationSummaryModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return DashboardDataModel(
      userName: json['user_name'] as String? ?? '',
      tonightGuest: json['tonight_guest'] as String?,
      monthNightsBooked: json['month_nights_booked'] as int? ?? 0,
      monthTotalNights: json['month_total_nights'] as int? ?? 0,
      monthRevenue: json['month_revenue'] as int? ?? 0,
      occupancyRate: (json['occupancy_rate'] as num?)?.toDouble() ?? 0.0,
      monthExpenses: json['month_expenses'] as int? ?? 0,
      monthNetProfit: json['month_net_profit'] as int? ?? 0,
      upcomingReservations: reservations,
      unreadNotificationCount:
          json['unread_notification_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'tonight_guest': tonightGuest,
      'month_nights_booked': monthNightsBooked,
      'month_total_nights': monthTotalNights,
      'month_revenue': monthRevenue,
      'occupancy_rate': occupancyRate,
      'month_expenses': monthExpenses,
      'month_net_profit': monthNetProfit,
      'upcoming_reservations': upcomingReservations
          .map((e) => (e as ReservationSummaryModel).toJson())
          .toList(),
      'unread_notification_count': unreadNotificationCount,
    };
  }
}
