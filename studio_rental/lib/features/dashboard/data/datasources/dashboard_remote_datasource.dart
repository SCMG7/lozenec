import 'package:studio_rental/core/network/api_client.dart';
import 'package:studio_rental/core/network/api_endpoints.dart';
import '../models/dashboard_data_model.dart';

class DashboardRemoteDatasource {
  final ApiClient apiClient;

  DashboardRemoteDatasource({required this.apiClient});

  Future<DashboardDataModel> getDashboard() async {
    final response = await apiClient.dio.get(ApiEndpoints.dashboard);
    final data = response.data['data'] as Map<String, dynamic>;
    return DashboardDataModel.fromJson(data);
  }
}
