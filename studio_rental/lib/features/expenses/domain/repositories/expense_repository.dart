import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<Map<String, dynamic>> getExpenses({
    required String month,
    String? category,
  });

  Future<Expense> getExpense(String id);

  Future<Expense> createExpense(Map<String, dynamic> data);

  Future<Expense> updateExpense(String id, Map<String, dynamic> data);

  Future<void> deleteExpense(String id);
}
