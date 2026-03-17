import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import 'interceptors/auth_interceptor.dart';

class ApiClient {
  late final Dio dio;
  final SecureStorage _secureStorage;

  ApiClient({
    required SecureStorage secureStorage,
    required GlobalKey<NavigatorState> navigatorKey,
  }) : _secureStorage = secureStorage {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.add(AuthInterceptor(
      secureStorage: _secureStorage,
      navigatorKey: navigatorKey,
    ));
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }
}
