class FinancialSummary {
  final int revenue;
  final int expenses;
  final int netProfit;
  final double? revenueChange;
  final double? expenseChange;
  final double? profitChange;

  const FinancialSummary({
    required this.revenue,
    required this.expenses,
    required this.netProfit,
    this.revenueChange,
    this.expenseChange,
    this.profitChange,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      revenue: json['revenue'] as int? ?? 0,
      expenses: json['expenses'] as int? ?? 0,
      netProfit: json['net_profit'] as int? ?? 0,
      revenueChange: (json['revenue_change'] as num?)?.toDouble(),
      expenseChange: (json['expense_change'] as num?)?.toDouble(),
      profitChange: (json['profit_change'] as num?)?.toDouble(),
    );
  }
}
