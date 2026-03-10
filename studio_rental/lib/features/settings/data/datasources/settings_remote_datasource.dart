import 'package:studio_rental/core/network/api_client.dart';
import 'package:studio_rental/core/network/api_endpoints.dart';
import 'package:studio_rental/features/auth/data/models/user_model.dart';

class SettingsRemoteDatasource {
  final ApiClient apiClient;

  SettingsRemoteDatasource({required this.apiClient});

  Future<UserModel> updateProfile({
    required String fullName,
    required String email,
  }) async {
    final response = await apiClient.dio.put(
      ApiEndpoints.updateProfile,
      data: {
        'fullName': fullName,
        'email': email,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<UserModel> updateSettings({
    required Map<String, dynamic> fields,
  }) async {
    final response = await apiClient.dio.put(
      ApiEndpoints.updateSettings,
      data: fields,
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await apiClient.dio.post(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<String> exportData({required String format}) async {
    final response = await apiClient.dio.post(
      ApiEndpoints.dataExport,
      data: {'format': format},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return data['downloadUrl'] as String;
  }

  Future<void> clearData({required String confirmation}) async {
    await apiClient.dio.delete(
      ApiEndpoints.dataClear,
      data: {'confirmation': confirmation},
    );
  }

  Future<void> logout() async {
    await apiClient.dio.post(ApiEndpoints.logout);
  }
}
