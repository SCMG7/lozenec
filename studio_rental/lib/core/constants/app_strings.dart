class AppStrings {
  AppStrings._();

  static const String appName = 'My Studio';
  static const String apiBaseUrl = 'http://localhost:3000/api/v1';
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String rememberMeKey = 'remember_me';

  static const List<String> currencies = ['BGN', 'EUR', 'USD', 'GBP'];

  static const Map<String, String> currencySymbols = {
    'BGN': 'лв',
    'EUR': '€',
    'USD': '\$',
    'GBP': '£',
  };
}
