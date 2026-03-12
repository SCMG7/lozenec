import 'package:studio_rental/core/network/api_client.dart';
import 'package:studio_rental/core/network/api_endpoints.dart';

class ExpenseRemoteDatasource {
  final ApiClient apiClient;

  ExpenseRemoteDatasource({required this.apiClient});

  Future<Map<String, dynamic>> getExpenses({
    required String month,
    String? category,
  }) async {
    final queryParams = <String, dynamic>{
      'month': month,
    };
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    final response = await apiClient.dio.get(
      ApiEndpoints.expenses,
      queryParameters: queryParams,
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getExpense(String id) async {
    final response = await apiClient.dio.get(ApiEndpoints.expenseById(id));
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createExpense(
      Map<String, dynamic> data) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.expenses,
      data: data,
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateExpense(
      String id, Map<String, dynamic> data) async {
    final response = await apiClient.dio.put(
      ApiEndpoints.expenseById(id),
      data: data,
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteExpense(String id) async {
    await apiClient.dio.delete(ApiEndpoints.expenseById(id));
  }

  Future<Map<String, dynamic>> getFinancialSummary(String month) async {
    final response = await apiClient.dio.get(
      ApiEndpoints.expensesSummary,
      queryParameters: {'month': month},
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAnnualSummary(int year) async {
    final response = await apiClient.dio.get(
      ApiEndpoints.expensesAnnualSummary,
      queryParameters: {'year': year.toString()},
    );
    return response.data['data'] as Map<String, dynamic>;
  }
}
