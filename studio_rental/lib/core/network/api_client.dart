import 'package:dio/dio.dart';
import '../constants/app_strings.dart';
import '../storage/secure_storage.dart';
import 'interceptors/auth_interceptor.dart';

class ApiClient {
  late final Dio dio;
  final SecureStorage _secureStorage;

  ApiClient({required SecureStorage secureStorage})
      : _secureStorage = secureStorage {
    dio = Dio(
      BaseOptions(
        baseUrl: AppStrings.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.add(AuthInterceptor(secureStorage: _secureStorage));
  }
}
