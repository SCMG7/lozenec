import 'package:studio_rental/core/network/api_client.dart';
import 'package:studio_rental/core/network/api_endpoints.dart';
import '../models/analytics_data_model.dart';

class AnalyticsRemoteDatasource {
  final ApiClient apiClient;

  AnalyticsRemoteDatasource({required this.apiClient});

  Future<AnalyticsDataModel> getAnalytics({
    required String period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'period': period,
    };
    if (startDate != null) {
      queryParams['startDate'] = startDate.toUtc().toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toUtc().toIso8601String();
    }

    final response = await apiClient.dio.get(
      ApiEndpoints.analytics,
      queryParameters: queryParams,
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return AnalyticsDataModel.fromJson(data);
  }
}
