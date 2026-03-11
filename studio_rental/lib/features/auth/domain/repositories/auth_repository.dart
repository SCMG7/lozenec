import '../entities/user.dart';

abstract class AuthRepository {
  Future<bool> isRemembered();
  Future<User?> getCachedUser();
  Future<User> verifyToken();
  Future<User> register({
    required String fullName,
    required String email,
    required String password,
  });
  Future<User> login({
    required String email,
    required String password,
    required bool rememberMe,
  });
  Future<void> forgotPassword({required String email});
  Future<void> logout();
}
