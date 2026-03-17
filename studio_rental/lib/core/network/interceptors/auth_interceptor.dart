import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import '../../constants/app_routes.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage secureStorage;
  final GlobalKey<NavigatorState> navigatorKey;

  /// Guard against re-entrant 401 handling (e.g. if the clearAll call
  /// itself somehow triggers another 401).
  bool _isHandling401 = false;

  AuthInterceptor({
    required this.secureStorage,
    required this.navigatorKey,
  });

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await secureStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isHandling401) {
      _isHandling401 = true;
      try {
        // Clear all stored auth data
        await secureStorage.clearAll();

        // Navigate to login and clear the entire navigation stack
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.login,
          (_) => false,
        );
      } finally {
        _isHandling401 = false;
      }
    }
    handler.next(err);
  }
}
