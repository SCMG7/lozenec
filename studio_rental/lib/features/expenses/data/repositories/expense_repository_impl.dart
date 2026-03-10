import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDatasource remoteDatasource;

  ExpenseRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Map<String, dynamic>> getExpenses({
    required String month,
    String? category,
  }) async {
    final data = await remoteDatasource.getExpenses(
      month: month,
      category: category,
    );
    final expensesList = (data['expenses'] as List?)
            ?.map((e) => Expense.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final summary = data['summary'] != null
        ? ExpenseSummary.fromJson(data['summary'] as Map<String, dynamic>)
        : ExpenseSummary(
            totalAmount: 0,
            entryCount: 0,
          );
    return {
      'expenses': expensesList,
      'summary': summary,
    };
  }

  @override
  Future<Expense> getExpense(String id) async {
    final data = await remoteDatasource.getExpense(id);
    return Expense.fromJson(data);
  }

  @override
  Future<Expense> createExpense(Map<String, dynamic> data) async {
    final responseData = await remoteDatasource.createExpense(data);
    return Expense.fromJson(responseData);
  }

  @override
  Future<Expense> updateExpense(String id, Map<String, dynamic> data) async {
    final responseData = await remoteDatasource.updateExpense(id, data);
    return Expense.fromJson(responseData);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await remoteDatasource.deleteExpense(id);
  }
}
