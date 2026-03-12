class MonthBreakdown {
  final String month;
  final int revenue;
  final int expenses;
  final int profit;

  const MonthBreakdown({
    required this.month,
    required this.revenue,
    required this.expenses,
    required this.profit,
  });

  factory MonthBreakdown.fromJson(Map<String, dynamic> json) {
    return MonthBreakdown(
      month: json['month'] as String? ?? '',
      revenue: json['revenue'] as int? ?? 0,
      expenses: json['expenses'] as int? ?? 0,
      profit: json['profit'] as int? ?? 0,
    );
  }
}

class AnnualSummary {
  final int revenue;
  final int expenses;
  final int netProfit;
  final List<MonthBreakdown> monthlyBreakdown;
  final Map<String, int> categoryBreakdown;
  final double? revenueChange;
  final double? expenseChange;
  final double? profitChange;

  const AnnualSummary({
    required this.revenue,
    required this.expenses,
    required this.netProfit,
    required this.monthlyBreakdown,
    required this.categoryBreakdown,
    this.revenueChange,
    this.expenseChange,
    this.profitChange,
  });

  factory AnnualSummary.fromJson(Map<String, dynamic> json) {
    final totals = json['year_totals'] as Map<String, dynamic>? ?? {};
    final changes =
        json['year_over_year_changes'] as Map<String, dynamic>? ?? {};
    final breakdownList = json['monthly_breakdown'] as List<dynamic>? ?? [];
    final categoryMap =
        json['category_breakdown'] as Map<String, dynamic>? ?? {};

    return AnnualSummary(
      revenue: totals['revenue'] as int? ?? 0,
      expenses: totals['expenses'] as int? ?? 0,
      netProfit: totals['net_profit'] as int? ?? 0,
      monthlyBreakdown: breakdownList
          .map((e) => MonthBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryBreakdown:
          categoryMap.map((k, v) => MapEntry(k, (v as num).toInt())),
      revenueChange: (changes['revenue_change'] as num?)?.toDouble(),
      expenseChange: (changes['expense_change'] as num?)?.toDouble(),
      profitChange: (changes['profit_change'] as num?)?.toDouble(),
    );
  }
}
