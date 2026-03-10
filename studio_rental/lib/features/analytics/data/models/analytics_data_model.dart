import '../../domain/entities/analytics_data.dart';

class AnalyticsDataModel extends AnalyticsData {
  const AnalyticsDataModel({
    required super.totalRevenue,
    required super.totalExpenses,
    required super.netProfit,
    required super.occupancy,
    required super.revenueChart,
    required super.expensesBreakdown,
    required super.reservationStats,
    required super.monthlyComparison,
  });

  factory AnalyticsDataModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsDataModel(
      totalRevenue: (json['totalRevenue'] as num?)?.toInt() ?? 0,
      totalExpenses: (json['totalExpenses'] as num?)?.toInt() ?? 0,
      netProfit: (json['netProfit'] as num?)?.toInt() ?? 0,
      occupancy: OccupancyDataModel.fromJson(
        json['occupancy'] as Map<String, dynamic>? ?? {},
      ),
      revenueChart: (json['revenueChart'] as List<dynamic>?)
              ?.map((e) =>
                  RevenueChartPointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      expensesBreakdown: (json['expensesBreakdown'] as List<dynamic>?)
              ?.map((e) => ExpenseCategoryBreakdownModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      reservationStats: ReservationStatsModel.fromJson(
        json['reservationStats'] as Map<String, dynamic>? ?? {},
      ),
      monthlyComparison: (json['monthlyComparison'] as List<dynamic>?)
              ?.map((e) => MonthlyComparisonRowModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class OccupancyDataModel extends OccupancyData {
  const OccupancyDataModel({
    required super.rate,
    required super.bookedNights,
    required super.totalNights,
  });

  factory OccupancyDataModel.fromJson(Map<String, dynamic> json) {
    return OccupancyDataModel(
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      bookedNights: (json['bookedNights'] as num?)?.toInt() ?? 0,
      totalNights: (json['totalNights'] as num?)?.toInt() ?? 0,
    );
  }
}

class RevenueChartPointModel extends RevenueChartPoint {
  const RevenueChartPointModel({
    required super.month,
    required super.confirmedRevenue,
    required super.pendingRevenue,
  });

  factory RevenueChartPointModel.fromJson(Map<String, dynamic> json) {
    return RevenueChartPointModel(
      month: json['month'] as String? ?? '',
      confirmedRevenue: (json['confirmedRevenue'] as num?)?.toInt() ?? 0,
      pendingRevenue: (json['pendingRevenue'] as num?)?.toInt() ?? 0,
    );
  }
}

class ExpenseCategoryBreakdownModel extends ExpenseCategoryBreakdown {
  const ExpenseCategoryBreakdownModel({
    required super.category,
    required super.total,
    required super.percentage,
  });

  factory ExpenseCategoryBreakdownModel.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryBreakdownModel(
      category: json['category'] as String? ?? '',
      total: (json['total'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ReservationStatsModel extends ReservationStats {
  const ReservationStatsModel({
    required super.avgLengthOfStay,
    required super.avgRevenuePerReservation,
    required super.longestStay,
    super.longestStayGuest,
    super.mostFrequentGuest,
    required super.mostFrequentGuestStays,
  });

  factory ReservationStatsModel.fromJson(Map<String, dynamic> json) {
    return ReservationStatsModel(
      avgLengthOfStay: (json['avgLengthOfStay'] as num?)?.toDouble() ?? 0.0,
      avgRevenuePerReservation:
          (json['avgRevenuePerReservation'] as num?)?.toInt() ?? 0,
      longestStay: (json['longestStay'] as num?)?.toInt() ?? 0,
      longestStayGuest: json['longestStayGuest'] as String?,
      mostFrequentGuest: json['mostFrequentGuest'] as String?,
      mostFrequentGuestStays:
          (json['mostFrequentGuestStays'] as num?)?.toInt() ?? 0,
    );
  }
}

class MonthlyComparisonRowModel extends MonthlyComparisonRow {
  const MonthlyComparisonRowModel({
    required super.month,
    required super.nightsBooked,
    required super.revenue,
    required super.expenses,
    required super.netProfit,
  });

  factory MonthlyComparisonRowModel.fromJson(Map<String, dynamic> json) {
    return MonthlyComparisonRowModel(
      month: json['month'] as String? ?? '',
      nightsBooked: (json['nightsBooked'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toInt() ?? 0,
      expenses: (json['expenses'] as num?)?.toInt() ?? 0,
      netProfit: (json['netProfit'] as num?)?.toInt() ?? 0,
    );
  }
}
