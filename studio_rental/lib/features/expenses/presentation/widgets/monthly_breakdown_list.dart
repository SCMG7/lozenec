import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import '../../domain/entities/annual_summary.dart';

class MonthlyBreakdownList extends StatelessWidget {
  final List<MonthBreakdown> months;

  const MonthlyBreakdownList({super.key, required this.months});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(
      locale: 'de_DE',
      symbol: '\u20AC',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.expenses_monthly_breakdown,
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text('', style: TextStyle(fontSize: 12)),
                      ),
                      Expanded(
                        child: Text(
                          l10n.expenses_revenue,
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          l10n.expenses_total,
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          l10n.expenses_net_profit,
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...months.map((m) => _MonthRow(
                      month: m,
                      currencyFormat: currencyFormat,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthRow extends StatelessWidget {
  final MonthBreakdown month;
  final NumberFormat currencyFormat;

  const _MonthRow({
    required this.month,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    String monthLabel;
    try {
      final date = DateTime.parse('${month.month}-01');
      monthLabel = DateFormat('MMM').format(date);
    } catch (_) {
      monthLabel = month.month;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              monthLabel,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              currencyFormat.format(month.revenue / 100),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              currencyFormat.format(month.expenses / 100),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              currencyFormat.format(month.profit / 100),
              style: AppTextStyles.bodySmall.copyWith(
                color:
                    month.profit >= 0 ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
