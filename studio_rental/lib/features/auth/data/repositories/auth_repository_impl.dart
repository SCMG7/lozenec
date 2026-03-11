import 'package:studio_rental/core/storage/secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final SecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.secureStorage,
  });

  @override
  Future<User> verifyToken() async {
    final response = await remoteDatasource.verifyToken();
    final data = response['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await secureStorage.saveUser(UserModel.fromEntity(user).toJson());
    return user;
  }

  @override
  Future<User> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await remoteDatasource.register(
      fullName: fullName,
      email: email,
      password: password,
    );
    final data = response['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    await secureStorage.saveToken(token);
    await secureStorage.saveUser(UserModel.fromEntity(user).toJson());

    return user;
  }

  @override
  Future<User> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final response = await remoteDatasource.login(
      email: email,
      password: password,
    );
    final data = response['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    await secureStorage.saveToken(token);
    await secureStorage.saveUser(UserModel.fromEntity(user).toJson());
    await secureStorage.setRememberMe(rememberMe);

    return user;
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await remoteDatasource.forgotPassword(email: email);
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
