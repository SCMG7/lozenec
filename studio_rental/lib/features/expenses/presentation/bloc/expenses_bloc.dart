import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

// Events
abstract class ExpensesEvent extends Equatable {
  const ExpensesEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpensesEvent {
  const LoadExpenses();
}

class ChangeMonth extends ExpensesEvent {
  final DateTime month;

  const ChangeMonth({required this.month});

  @override
  List<Object?> get props => [month];
}

class ChangeCategory extends ExpensesEvent {
  final String? category;

  const ChangeCategory({this.category});

  @override
  List<Object?> get props => [category];
}

class RefreshExpenses extends ExpensesEvent {
  const RefreshExpenses();
}

// States
class ExpensesState extends Equatable {
  final List<Expense> expenses;
  final ExpenseSummary? summary;
  final DateTime selectedMonth;
  final String? selectedCategory;
  final bool isLoading;
  final String? error;

  ExpensesState({
    this.expenses = const [],
    this.summary,
    DateTime? selectedMonth,
    this.selectedCategory,
    this.isLoading = false,
    this.error,
  }) : selectedMonth = selectedMonth ?? DateTime.now();

  ExpensesState copyWith({
    List<Expense>? expenses,
    ExpenseSummary? summary,
    DateTime? selectedMonth,
    String? selectedCategory,
    bool? isLoading,
    String? error,
    bool clearCategory = false,
    bool clearError = false,
  }) {
    return ExpensesState(
      expenses: expenses ?? this.expenses,
      summary: summary ?? this.summary,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  String get monthParam =>
      '${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [
        expenses,
        summary,
        selectedMonth,
        selectedCategory,
        isLoading,
        error,
      ];
}

// Bloc
class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final ExpenseRepository expenseRepository;

  ExpensesBloc({required this.expenseRepository}) : super(ExpensesState()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<ChangeMonth>(_onChangeMonth);
    on<ChangeCategory>(_onChangeCategory);
    on<RefreshExpenses>(_onRefreshExpenses);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpensesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final result = await expenseRepository.getExpenses(
        month: state.monthParam,
        category: state.selectedCategory,
      );
      final expenses = result['expenses'] as List<Expense>;
      final summary = result['summary'] as ExpenseSummary;
      emit(state.copyWith(
        expenses: expenses,
        summary: summary,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onChangeMonth(
    ChangeMonth event,
    Emitter<ExpensesState> emit,
  ) async {
    emit(state.copyWith(
      selectedMonth: event.month,
      isLoading: true,
      clearError: true,
    ));
    try {
      final monthParam =
          '${event.month.year}-${event.month.month.toString().padLeft(2, '0')}';
      final result = await expenseRepository.getExpenses(
        month: monthParam,
        category: state.selectedCategory,
      );
      final expenses = result['expenses'] as List<Expense>;
      final summary = result['summary'] as ExpenseSummary;
      emit(state.copyWith(
        expenses: expenses,
        summary: summary,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onChangeCategory(
    ChangeCategory event,
    Emitter<ExpensesState> emit,
  ) async {
    emit(state.copyWith(
      selectedCategory: event.category,
      clearCategory: event.category == null,
      isLoading: true,
      clearError: true,
    ));
    try {
      final result = await expenseRepository.getExpenses(
        month: state.monthParam,
        category: event.category,
      );
      final expenses = result['expenses'] as List<Expense>;
      final summary = result['summary'] as ExpenseSummary;
      emit(state.copyWith(
        expenses: expenses,
        summary: summary,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshExpenses(
    RefreshExpenses event,
    Emitter<ExpensesState> emit,
  ) async {
    try {
      final result = await expenseRepository.getExpenses(
        month: state.monthParam,
        category: state.selectedCategory,
      );
      final expenses = result['expenses'] as List<Expense>;
      final summary = result['summary'] as ExpenseSummary;
      emit(state.copyWith(
        expenses: expenses,
        summary: summary,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
