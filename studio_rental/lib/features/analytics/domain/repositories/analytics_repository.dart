import '../entities/analytics_data.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsData> getAnalytics({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  });
}
