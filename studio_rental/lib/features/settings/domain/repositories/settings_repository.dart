import 'package:studio_rental/features/auth/domain/entities/user.dart';

abstract class SettingsRepository {
  Future<User> updateProfile({
    required String fullName,
    required String email,
  });

  Future<User> updateSettings({
    required Map<String, dynamic> fields,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<String> exportData({required String format});

  Future<void> clearData({required String confirmation});

  Future<void> logout();
}
