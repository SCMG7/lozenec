import '../../domain/entities/expense.dart';

class ExpenseSummaryModel extends ExpenseSummary {
  const ExpenseSummaryModel({
    required super.totalAmount,
    super.largestExpense,
    required super.entryCount,
  });

  factory ExpenseSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = ExpenseSummary.fromJson(json);
    return ExpenseSummaryModel(
      totalAmount: summary.totalAmount,
      largestExpense: summary.largestExpense,
      entryCount: summary.entryCount,
    );
  }
}
