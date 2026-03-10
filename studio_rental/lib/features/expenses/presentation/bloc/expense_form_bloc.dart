import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/expense_repository.dart';

// Events
abstract class ExpenseFormEvent extends Equatable {
  const ExpenseFormEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpense extends ExpenseFormEvent {
  final String id;

  const LoadExpense({required this.id});

  @override
  List<Object?> get props => [id];
}

class SaveExpense extends ExpenseFormEvent {
  const SaveExpense();
}

class DeleteExpense extends ExpenseFormEvent {
  const DeleteExpense();
}

class UpdateField extends ExpenseFormEvent {
  final String field;
  final dynamic value;

  const UpdateField({required this.field, required this.value});

  @override
  List<Object?> get props => [field, value];
}

// States
class ExpenseFormState extends Equatable {
  final String? expenseId;
  final String title;
  final String amount;
  final String date;
  final String category;
  final String notes;
  final bool isRecurring;
  final String? recurrenceFreq;
  final bool isEditMode;
  final bool isLoading;
  final bool isSaving;
  final bool isDeleting;
  final bool isSaved;
  final bool isDeleted;
  final String? error;
  final Map<String, String?> fieldErrors;

  const ExpenseFormState({
    this.expenseId,
    this.title = '',
    this.amount = '',
    this.date = '',
    this.category = '',
    this.notes = '',
    this.isRecurring = false,
    this.recurrenceFreq,
    this.isEditMode = false,
    this.isLoading = false,
    this.isSaving = false,
    this.isDeleting = false,
    this.isSaved = false,
    this.isDeleted = false,
    this.error,
    this.fieldErrors = const {},
  });

  ExpenseFormState copyWith({
    String? expenseId,
    String? title,
    String? amount,
    String? date,
    String? category,
    String? notes,
    bool? isRecurring,
    String? recurrenceFreq,
    bool? isEditMode,
    bool? isLoading,
    bool? isSaving,
    bool? isDeleting,
    bool? isSaved,
    bool? isDeleted,
    String? error,
    Map<String, String?>? fieldErrors,
    bool clearError = false,
    bool clearRecurrenceFreq = false,
  }) {
    return ExpenseFormState(
      expenseId: expenseId ?? this.expenseId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceFreq: clearRecurrenceFreq
          ? null
          : (recurrenceFreq ?? this.recurrenceFreq),
      isEditMode: isEditMode ?? this.isEditMode,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      isSaved: isSaved ?? this.isSaved,
      isDeleted: isDeleted ?? this.isDeleted,
      error: clearError ? null : (error ?? this.error),
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [
        expenseId,
        title,
        amount,
        date,
        category,
        notes,
        isRecurring,
        recurrenceFreq,
        isEditMode,
        isLoading,
        isSaving,
        isDeleting,
        isSaved,
        isDeleted,
        error,
        fieldErrors,
      ];
}

// Bloc
class ExpenseFormBloc extends Bloc<ExpenseFormEvent, ExpenseFormState> {
  final ExpenseRepository expenseRepository;

  ExpenseFormBloc({required this.expenseRepository})
      : super(const ExpenseFormState()) {
    on<LoadExpense>(_onLoadExpense);
    on<SaveExpense>(_onSaveExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<UpdateField>(_onUpdateField);
  }

  Future<void> _onLoadExpense(
    LoadExpense event,
    Emitter<ExpenseFormState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, isEditMode: true, clearError: true));
    try {
      final expense = await expenseRepository.getExpense(event.id);
      final amountDisplay = (expense.amount / 100).toStringAsFixed(2);
      emit(state.copyWith(
        expenseId: expense.id,
        title: expense.title,
        amount: amountDisplay,
        date: expense.date,
        category: expense.category,
        notes: expense.notes ?? '',
        isRecurring: expense.isRecurring,
        recurrenceFreq: expense.recurrenceFreq,
        isEditMode: true,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onSaveExpense(
    SaveExpense event,
    Emitter<ExpenseFormState> emit,
  ) async {
    final errors = _validate();
    if (errors.isNotEmpty) {
      emit(state.copyWith(fieldErrors: errors));
      return;
    }

    emit(state.copyWith(
      isSaving: true,
      clearError: true,
      fieldErrors: const {},
    ));

    try {
      final amountCents = (double.parse(state.amount) * 100).round();

      final data = <String, dynamic>{
        'title': state.title.trim(),
        'amount': amountCents,
        'date': state.date,
        'category': state.category,
        'notes': state.notes.trim().isEmpty ? null : state.notes.trim(),
        'is_recurring': state.isRecurring,
        'recurrence_freq': state.isRecurring ? state.recurrenceFreq : null,
      };

      if (state.isEditMode && state.expenseId != null) {
        await expenseRepository.updateExpense(state.expenseId!, data);
      } else {
        await expenseRepository.createExpense(data);
      }

      emit(state.copyWith(isSaving: false, isSaved: true));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseFormState> emit,
  ) async {
    if (state.expenseId == null) return;

    emit(state.copyWith(isDeleting: true, clearError: true));
    try {
      await expenseRepository.deleteExpense(state.expenseId!);
      emit(state.copyWith(isDeleting: false, isDeleted: true));
    } catch (e) {
      emit(state.copyWith(
        isDeleting: false,
        error: e.toString(),
      ));
    }
  }

  void _onUpdateField(
    UpdateField event,
    Emitter<ExpenseFormState> emit,
  ) {
    final updatedErrors = Map<String, String?>.from(state.fieldErrors);
    updatedErrors.remove(event.field);

    switch (event.field) {
      case 'title':
        emit(state.copyWith(
          title: event.value as String,
          fieldErrors: updatedErrors,
          clearError: true,
        ));
        break;
      case 'amount':
        emit(state.copyWith(
          amount: event.value as String,
          fieldErrors: updatedErrors,
          clearError: true,
        ));
        break;
      case 'date':
        emit(state.copyWith(
          date: event.value as String,
          fieldErrors: updatedErrors,
          clearError: true,
        ));
        break;
      case 'category':
        emit(state.copyWith(
          category: event.value as String,
          fieldErrors: updatedErrors,
          clearError: true,
        ));
        break;
      case 'notes':
        emit(state.copyWith(
          notes: event.value as String,
          fieldErrors: updatedErrors,
          clearError: true,
        ));
        break;
      case 'isRecurring':
        final isRecurring = event.value as bool;
        emit(state.copyWith(
          isRecurring: isRecurring,
          clearRecurrenceFreq: !isRecurring,
          fieldErrors: updatedErrors,
          clearError: true,
        ));
        break;
      case 'recurrenceFreq':
        emit(state.copyWith(
          recurrenceFreq: event.value as String?,
          fieldErrors: updatedErrors,
          clearError: true,
        ));
        break;
    }
  }

  Map<String, String?> _validate() {
    final errors = <String, String?>{};

    if (state.title.trim().isEmpty) {
      errors['title'] = 'required';
    } else if (state.title.trim().length < 2) {
      errors['title'] = 'min_length';
    }

    if (state.amount.isEmpty) {
      errors['amount'] = 'required';
    } else {
      final parsed = double.tryParse(state.amount);
      if (parsed == null || parsed <= 0) {
        errors['amount'] = 'positive';
      }
    }

    if (state.date.isEmpty) {
      errors['date'] = 'required';
    }

    if (state.category.isEmpty) {
      errors['category'] = 'required';
    }

    return errors;
  }
}
