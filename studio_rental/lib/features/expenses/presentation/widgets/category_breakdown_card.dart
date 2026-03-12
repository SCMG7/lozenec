import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'expense_category_icon.dart';

class CategoryBreakdownCard extends StatelessWidget {
  final Map<String, int> categoryBreakdown;

  const CategoryBreakdownCard({super.key, required this.categoryBreakdown});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(
      locale: 'de_DE',
      symbol: '\u20AC',
      decimalDigits: 0,
    );

    final total =
        categoryBreakdown.values.fold<int>(0, (sum, v) => sum + v);
    final sortedEntries = categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedEntries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.expenses_category_breakdown,
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: sortedEntries.map((entry) {
                  final percentage =
                      total > 0 ? (entry.value / total * 100).round() : 0;
                  final categoryLabel =
                      _getCategoryLabel(l10n, entry.key);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        ExpenseCategoryIcon(
                          category: entry.key,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categoryLabel,
                                style: AppTextStyles.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: total > 0
                                      ? entry.value / total
                                      : 0,
                                  backgroundColor:
                                      AppColors.divider,
                                  color: AppColors.error
                                      .withValues(alpha: 0.7),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(entry.value / 100),
                              style: AppTextStyles.titleMedium
                                  .copyWith(color: AppColors.error),
                            ),
                            Text(
                              '$percentage%',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(AppLocalizations l10n, String category) {
    switch (category) {
      case 'maintenance':
        return l10n.expenses_filter_maintenance;
      case 'furniture':
        return l10n.expenses_filter_furniture;
      case 'appliances':
        return l10n.expenses_filter_appliances;
      case 'utilities':
        return l10n.expenses_filter_utilities;
      case 'cleaning':
        return l10n.expenses_filter_cleaning;
      case 'supplies':
        return l10n.expenses_filter_supplies;
      case 'taxes':
        return l10n.expenses_filter_taxes;
      case 'other':
      default:
        return l10n.expenses_filter_other;
    }
  }
}
