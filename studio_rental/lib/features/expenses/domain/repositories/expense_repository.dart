import '../entities/expense.dart';
import '../entities/financial_summary.dart';
import '../entities/annual_summary.dart';

abstract class ExpenseRepository {
  Future<Map<String, dynamic>> getExpenses({
    required String month,
    String? category,
  });

  Future<Expense> getExpense(String id);

  Future<Expense> createExpense(Map<String, dynamic> data);

  Future<Expense> updateExpense(String id, Map<String, dynamic> data);

  Future<void> deleteExpense(String id);

  Future<FinancialSummary> getFinancialSummary(String month);

  Future<AnnualSummary> getAnnualSummary(int year);
}
