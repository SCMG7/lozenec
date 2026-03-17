import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  /// The active user's currency. Set this on login/auth.
  static String activeCurrency = 'EUR';

  static const _currencyConfig = {
    'EUR': (symbol: '\u20AC', locale: 'de_DE', symbolAfter: false),
    'USD': (symbol: '\$', locale: 'en_US', symbolAfter: false),
    'GBP': (symbol: '\u00A3', locale: 'en_GB', symbolAfter: false),
  };

  /// Format an integer amount (in cents) as a currency string.
  static String format(int cents, {String currency = 'EUR'}) {
    final config = _currencyConfig[currency] ?? _currencyConfig['EUR']!;
    final amount = cents / 100;
    final formatter = NumberFormat.currency(
      locale: config.locale,
      symbol: '',
      decimalDigits: 2,
    );
    final formatted = formatter.format(amount);

    if (config.symbolAfter) {
      return '$formatted ${config.symbol}';
    }
    return '${config.symbol}$formatted';
  }

  /// Format compact (e.g. 1.2K) for large amounts.
  static String formatCompact(int cents, {String currency = 'EUR'}) {
    final config = _currencyConfig[currency] ?? _currencyConfig['EUR']!;
    final value = cents / 100;
    if (value >= 1000) {
      final compact = NumberFormat.compact(locale: config.locale).format(value);
      if (config.symbolAfter) {
        return '$compact ${config.symbol}';
      }
      return '${config.symbol}$compact';
    }
    return format(cents, currency: currency);
  }

  /// Get just the currency symbol for a currency code.
  static String symbol(String currency) {
    return _currencyConfig[currency]?.symbol ?? currency;
  }

  /// Parse a user-entered string to cents.
  static int parseToCents(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    if (cleaned.isEmpty) return 0;
    return (double.parse(cleaned) * 100).round();
  }
}
