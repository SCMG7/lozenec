import 'package:studio_rental/core/network/api_client.dart';
import 'package:studio_rental/core/network/api_endpoints.dart';

class AuthRemoteDatasource {
  final ApiClient apiClient;

  AuthRemoteDatasource({required this.apiClient});

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String studioName,
    String? studioAddress,
  }) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.register,
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'studioName': studioName,
        if (studioAddress != null && studioAddress.isNotEmpty)
          'studioAddress': studioAddress,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyToken() async {
    final response = await apiClient.dio.post(ApiEndpoints.verifyToken);
    return response.data as Map<String, dynamic>;
  }

  Future<void> forgotPassword({required String email}) async {
    await apiClient.dio.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  Future<void> logout() async {
    await apiClient.dio.post(ApiEndpoints.logout);
  }
}
