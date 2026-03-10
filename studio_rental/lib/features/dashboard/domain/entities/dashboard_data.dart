import 'package:equatable/equatable.dart';
import 'reservation_summary.dart';

class DashboardData extends Equatable {
  final String? tonightGuest;
  final int monthNightsBooked;
  final int monthTotalNights;
  final int monthRevenue;
  final double occupancyRate;
  final int monthExpenses;
  final int monthNetProfit;
  final List<ReservationSummary> upcomingReservations;
  final int unreadNotificationCount;

  const DashboardData({
    this.tonightGuest,
    required this.monthNightsBooked,
    required this.monthTotalNights,
    required this.monthRevenue,
    required this.occupancyRate,
    required this.monthExpenses,
    required this.monthNetProfit,
    required this.upcomingReservations,
    required this.unreadNotificationCount,
  });

  @override
  List<Object?> get props => [
        tonightGuest,
        monthNightsBooked,
        monthTotalNights,
        monthRevenue,
        occupancyRate,
        monthExpenses,
        monthNetProfit,
        upcomingReservations,
        unreadNotificationCount,
      ];
}
