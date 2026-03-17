import 'package:studio_rental/core/services/subscription_service.dart';

/// Filters a list of dated items to the last 90 days for free users.
/// Pro users get the full unfiltered list.
class FreeTierFilter {
  FreeTierFilter._();

  static const int freeTierDays = 90;

  /// Apply free tier date filter. Returns the original list for Pro users,
  /// or only items within the last 90 days for free users.
  static List<T> apply<T>(
    List<T> items,
    DateTime Function(T) dateGetter,
  ) {
    if (SubscriptionService.instance.isPro) return items;

    final cutoff = DateTime.now().subtract(const Duration(days: freeTierDays));
    return items.where((item) => dateGetter(item).isAfter(cutoff)).toList();
  }

  /// Check if a given date is within the free tier window.
  static bool isWithinFreeWindow(DateTime date) {
    final cutoff = DateTime.now().subtract(const Duration(days: freeTierDays));
    return date.isAfter(cutoff);
  }

  /// Check if the user needs the Pro gate for accessing older data.
  static bool needsProForDate(DateTime date) {
    if (SubscriptionService.instance.isPro) return false;
    return !isWithinFreeWindow(date);
  }
}
