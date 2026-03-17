class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://lozenec-production.up.railway.app/api/v1',
  );

  static const bool isProduction = bool.fromEnvironment(
    'IS_PRODUCTION',
    defaultValue: false,
  );

  static const String appStoreId = String.fromEnvironment(
    'APP_STORE_ID',
    defaultValue: '',
  );

  static const String playStorePackage = String.fromEnvironment(
    'PLAY_STORE_PACKAGE',
    defaultValue: 'com.studioapp.studio_rental',
  );
}
