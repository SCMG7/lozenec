import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(int cents, {String currency = 'BGN'}) {
    final symbol = AppStrings.currencySymbols[currency] ?? currency;
    final formatter = NumberFormat.currency(
      locale: 'bg_BG',
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(cents / 100);
  }

  static String formatCompact(int cents, {String currency = 'BGN'}) {
    final symbol = AppStrings.currencySymbols[currency] ?? currency;
    final value = cents / 100;
    if (value >= 1000) {
      return '$symbol${NumberFormat.compact(locale: 'bg_BG').format(value)}';
    }
    return format(cents, currency: currency);
  }

  static int parseToCents(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    if (cleaned.isEmpty) return 0;
    return (double.parse(cleaned) * 100).round();
  }
}
