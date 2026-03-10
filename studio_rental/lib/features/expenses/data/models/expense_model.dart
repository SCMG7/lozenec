import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.amount,
    required super.date,
    required super.category,
    super.notes,
    super.isRecurring,
    super.recurrenceFreq,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final expense = Expense.fromJson(json);
    return ExpenseModel(
      id: expense.id,
      userId: expense.userId,
      title: expense.title,
      amount: expense.amount,
      date: expense.date,
      category: expense.category,
      notes: expense.notes,
      isRecurring: expense.isRecurring,
      recurrenceFreq: expense.recurrenceFreq,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );
  }

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      userId: expense.userId,
      title: expense.title,
      amount: expense.amount,
      date: expense.date,
      category: expense.category,
      notes: expense.notes,
      isRecurring: expense.isRecurring,
      recurrenceFreq: expense.recurrenceFreq,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );
  }
}
