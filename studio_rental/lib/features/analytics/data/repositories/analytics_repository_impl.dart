import '../../domain/entities/analytics_data.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDatasource remoteDatasource;

  AnalyticsRepositoryImpl({required this.remoteDatasource});

  @override
  Future<AnalyticsData> getAnalytics({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await remoteDatasource.getAnalytics(
      period: period,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
