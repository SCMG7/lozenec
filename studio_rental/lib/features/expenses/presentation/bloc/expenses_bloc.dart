import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/financial_summary.dart';
import '../../domain/entities/annual_summary.dart';
import '../../domain/repositories/expense_repository.dart';

// View Mode
enum ExpenseViewMode { monthly, annual }

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

class ToggleViewMode extends ExpensesEvent {
  final ExpenseViewMode viewMode;

  const ToggleViewMode({required this.viewMode});

  @override
  List<Object?> get props => [viewMode];
}

class ChangeYear extends ExpensesEvent {
  final int year;

  const ChangeYear({required this.year});

  @override
  List<Object?> get props => [year];
}

// States
class ExpensesState extends Equatable {
  final List<Expense> expenses;
  final ExpenseSummary? summary;
  final FinancialSummary? financialSummary;
  final AnnualSummary? annualSummary;
  final DateTime selectedMonth;
  final int selectedYear;
  final String? selectedCategory;
  final ExpenseViewMode viewMode;
  final bool isLoading;
  final String? error;

  ExpensesState({
    this.expenses = const [],
    this.summary,
    this.financialSummary,
    this.annualSummary,
    DateTime? selectedMonth,
    int? selectedYear,
    this.selectedCategory,
    this.viewMode = ExpenseViewMode.monthly,
    this.isLoading = false,
    this.error,
  })  : selectedMonth = selectedMonth ?? DateTime.now(),
        selectedYear = selectedYear ?? DateTime.now().year;

  ExpensesState copyWith({
    List<Expense>? expenses,
    ExpenseSummary? summary,
    FinancialSummary? financialSummary,
    AnnualSummary? annualSummary,
    DateTime? selectedMonth,
    int? selectedYear,
    String? selectedCategory,
    ExpenseViewMode? viewMode,
    bool? isLoading,
    String? error,
    bool clearCategory = false,
    bool clearError = false,
    bool clearFinancialSummary = false,
    bool clearAnnualSummary = false,
  }) {
    return ExpensesState(
      expenses: expenses ?? this.expenses,
      summary: summary ?? this.summary,
      financialSummary: clearFinancialSummary
          ? null
          : (financialSummary ?? this.financialSummary),
      annualSummary:
          clearAnnualSummary ? null : (annualSummary ?? this.annualSummary),
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      viewMode: viewMode ?? this.viewMode,
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
        financialSummary,
        annualSummary,
        selectedMonth,
        selectedYear,
        selectedCategory,
        viewMode,
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
    on<ToggleViewMode>(_onToggleViewMode);
    on<ChangeYear>(_onChangeYear);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpensesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final results = await Future.wait([
        expenseRepository.getExpenses(
          month: state.monthParam,
          category: state.selectedCategory,
        ),
        expenseRepository.getFinancialSummary(state.monthParam),
      ]);
      final expenseResult = results[0] as Map<String, dynamic>;
      final financialSummary = results[1] as FinancialSummary;
      emit(state.copyWith(
        expenses: expenseResult['expenses'] as List<Expense>,
        summary: expenseResult['summary'] as ExpenseSummary,
        financialSummary: financialSummary,
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
      final results = await Future.wait([
        expenseRepository.getExpenses(
          month: monthParam,
          category: state.selectedCategory,
        ),
        expenseRepository.getFinancialSummary(monthParam),
      ]);
      final expenseResult = results[0] as Map<String, dynamic>;
      final financialSummary = results[1] as FinancialSummary;
      emit(state.copyWith(
        expenses: expenseResult['expenses'] as List<Expense>,
        summary: expenseResult['summary'] as ExpenseSummary,
        financialSummary: financialSummary,
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
      if (state.viewMode == ExpenseViewMode.annual) {
        final annualSummary =
            await expenseRepository.getAnnualSummary(state.selectedYear);
        emit(state.copyWith(
          annualSummary: annualSummary,
          clearError: true,
        ));
      } else {
        final results = await Future.wait([
          expenseRepository.getExpenses(
            month: state.monthParam,
            category: state.selectedCategory,
          ),
          expenseRepository.getFinancialSummary(state.monthParam),
        ]);
        final expenseResult = results[0] as Map<String, dynamic>;
        final financialSummary = results[1] as FinancialSummary;
        emit(state.copyWith(
          expenses: expenseResult['expenses'] as List<Expense>,
          summary: expenseResult['summary'] as ExpenseSummary,
          financialSummary: financialSummary,
          clearError: true,
        ));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onToggleViewMode(
    ToggleViewMode event,
    Emitter<ExpensesState> emit,
  ) async {
    emit(state.copyWith(
      viewMode: event.viewMode,
      isLoading: true,
      clearError: true,
    ));
    try {
      if (event.viewMode == ExpenseViewMode.annual) {
        final annualSummary =
            await expenseRepository.getAnnualSummary(state.selectedYear);
        emit(state.copyWith(
          annualSummary: annualSummary,
          isLoading: false,
        ));
      } else {
        final results = await Future.wait([
          expenseRepository.getExpenses(
            month: state.monthParam,
            category: state.selectedCategory,
          ),
          expenseRepository.getFinancialSummary(state.monthParam),
        ]);
        final expenseResult = results[0] as Map<String, dynamic>;
        final financialSummary = results[1] as FinancialSummary;
        emit(state.copyWith(
          expenses: expenseResult['expenses'] as List<Expense>,
          summary: expenseResult['summary'] as ExpenseSummary,
          financialSummary: financialSummary,
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onChangeYear(
    ChangeYear event,
    Emitter<ExpensesState> emit,
  ) async {
    emit(state.copyWith(
      selectedYear: event.year,
      isLoading: true,
      clearError: true,
    ));
    try {
      final annualSummary =
          await expenseRepository.getAnnualSummary(event.year);
      emit(state.copyWith(
        annualSummary: annualSummary,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
