import 'package:studio_rental/core/storage/secure_storage.dart';
import 'package:studio_rental/features/auth/data/models/user_model.dart';
import 'package:studio_rental/features/auth/domain/entities/user.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDatasource remoteDatasource;
  final SecureStorage secureStorage;

  SettingsRepositoryImpl({
    required this.remoteDatasource,
    required this.secureStorage,
  });

  @override
  Future<User> updateProfile({
    required String fullName,
    required String email,
  }) async {
    final user = await remoteDatasource.updateProfile(
      fullName: fullName,
      email: email,
    );
    await secureStorage.saveUser(UserModel.fromEntity(user).toJson());
    return user;
  }

  @override
  Future<User> updateSettings({
    required Map<String, dynamic> fields,
  }) async {
    final user = await remoteDatasource.updateSettings(fields: fields);
    await secureStorage.saveUser(UserModel.fromEntity(user).toJson());
    return user;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await remoteDatasource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<String> exportData({required String format}) async {
    return await remoteDatasource.exportData(format: format);
  }

  @override
  Future<void> clearData({required String confirmation}) async {
    await remoteDatasource.clearData(confirmation: confirmation);
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDatasource.logout();
    } catch (_) {
      // Even if backend call fails, clear local storage
    }
    await secureStorage.clearAll();
  }
}
