import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'de_DE',
    symbol: AppStrings.currencySymbol,
    decimalDigits: 2,
  );

  static String format(int cents, {String? currency}) {
    return _formatter.format(cents / 100);
  }

  static String formatCompact(int cents, {String? currency}) {
    final value = cents / 100;
    if (value >= 1000) {
      return '${AppStrings.currencySymbol}${NumberFormat.compact(locale: 'de_DE').format(value)}';
    }
    return format(cents);
  }

  static int parseToCents(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    if (cleaned.isEmpty) return 0;
    return (double.parse(cleaned) * 100).round();
  }
}
