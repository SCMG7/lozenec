import 'package:equatable/equatable.dart';

class AnalyticsData extends Equatable {
  final int totalRevenue;
  final int totalExpenses;
  final int netProfit;
  final OccupancyData occupancy;
  final List<RevenueChartPoint> revenueChart;
  final List<ExpenseCategoryBreakdown> expensesBreakdown;
  final ReservationStats reservationStats;
  final List<MonthlyComparisonRow> monthlyComparison;

  const AnalyticsData({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.occupancy,
    required this.revenueChart,
    required this.expensesBreakdown,
    required this.reservationStats,
    required this.monthlyComparison,
  });

  @override
  List<Object?> get props => [
        totalRevenue,
        totalExpenses,
        netProfit,
        occupancy,
        revenueChart,
        expensesBreakdown,
        reservationStats,
        monthlyComparison,
      ];
}

class OccupancyData extends Equatable {
  final double rate;
  final int bookedNights;
  final int totalNights;

  const OccupancyData({
    required this.rate,
    required this.bookedNights,
    required this.totalNights,
  });

  @override
  List<Object?> get props => [rate, bookedNights, totalNights];
}

class RevenueChartPoint extends Equatable {
  final String month;
  final int confirmedRevenue;
  final int pendingRevenue;

  const RevenueChartPoint({
    required this.month,
    required this.confirmedRevenue,
    required this.pendingRevenue,
  });

  @override
  List<Object?> get props => [month, confirmedRevenue, pendingRevenue];
}

class ExpenseCategoryBreakdown extends Equatable {
  final String category;
  final int total;
  final double percentage;

  const ExpenseCategoryBreakdown({
    required this.category,
    required this.total,
    required this.percentage,
  });

  @override
  List<Object?> get props => [category, total, percentage];
}

class ReservationStats extends Equatable {
  final double avgLengthOfStay;
  final int avgRevenuePerReservation;
  final int longestStay;
  final String? longestStayGuest;
  final String? mostFrequentGuest;
  final int mostFrequentGuestStays;

  const ReservationStats({
    required this.avgLengthOfStay,
    required this.avgRevenuePerReservation,
    required this.longestStay,
    this.longestStayGuest,
    this.mostFrequentGuest,
    required this.mostFrequentGuestStays,
  });

  @override
  List<Object?> get props => [
        avgLengthOfStay,
        avgRevenuePerReservation,
        longestStay,
        longestStayGuest,
        mostFrequentGuest,
        mostFrequentGuestStays,
      ];
}

class MonthlyComparisonRow extends Equatable {
  final String month;
  final int nightsBooked;
  final int revenue;
  final int expenses;
  final int netProfit;

  const MonthlyComparisonRow({
    required this.month,
    required this.nightsBooked,
    required this.revenue,
    required this.expenses,
    required this.netProfit,
  });

  @override
  List<Object?> get props => [month, nightsBooked, revenue, expenses, netProfit];
}
