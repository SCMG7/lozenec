import 'package:equatable/equatable.dart';
import 'reservation_summary.dart';

class DashboardData extends Equatable {
  final String userName;
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
    this.userName = '',
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

  String get initials {
    if (userName.isEmpty) return '';
    final parts = userName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  List<Object?> get props => [
        userName,
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
