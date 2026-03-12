import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import '../../domain/entities/financial_summary.dart';

class FinancialSummaryCard extends StatelessWidget {
  final FinancialSummary summary;

  const FinancialSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(
      locale: 'de_DE',
      symbol: '\u20AC',
      decimalDigits: 2,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _MetricColumn(
                  label: l10n.expenses_revenue,
                  value: currencyFormat.format(summary.revenue / 100),
                  valueColor: AppColors.success,
                  change: summary.revenueChange,
                  positiveIsGood: true,
                ),
              ),
              Container(width: 1, height: 56, color: AppColors.divider),
              Expanded(
                child: _MetricColumn(
                  label: l10n.expenses_total,
                  value: currencyFormat.format(summary.expenses / 100),
                  valueColor: AppColors.error,
                  change: summary.expenseChange,
                  positiveIsGood: false,
                ),
              ),
              Container(width: 1, height: 56, color: AppColors.divider),
              Expanded(
                child: _MetricColumn(
                  label: l10n.expenses_net_profit,
                  value: currencyFormat.format(summary.netProfit / 100),
                  valueColor: summary.netProfit >= 0
                      ? AppColors.success
                      : AppColors.error,
                  change: summary.profitChange,
                  positiveIsGood: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final double? change;
  final bool positiveIsGood;

  const _MetricColumn({
    required this.label,
    required this.value,
    required this.valueColor,
    this.change,
    required this.positiveIsGood,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(color: valueColor),
            ),
          ),
          if (change != null) ...[
            const SizedBox(height: 2),
            _TrendIndicator(
              change: change!,
              positiveIsGood: positiveIsGood,
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendIndicator extends StatelessWidget {
  final double change;
  final bool positiveIsGood;

  const _TrendIndicator({
    required this.change,
    required this.positiveIsGood,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;
    final isGood = positiveIsGood ? isPositive : !isPositive;
    final color = isGood ? AppColors.success : AppColors.error;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        Text(
          '${change.abs().toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
