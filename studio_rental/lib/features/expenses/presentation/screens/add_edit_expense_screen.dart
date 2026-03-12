import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/core/widgets/loading_indicator.dart';
import '../bloc/expense_form_bloc.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final String? expenseId;

  const AddEditExpenseScreen({super.key, this.expenseId});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  bool get isEditMode => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    _notesController = TextEditingController();

    if (isEditMode) {
      context
          .read<ExpenseFormBloc>()
          .add(LoadExpense(id: widget.expenseId!));
    } else {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      context
          .read<ExpenseFormBloc>()
          .add(UpdateField(field: 'date', value: today));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ExpenseFormBloc, ExpenseFormState>(
      listener: (context, state) {
        if (state.isEditMode && !state.isSaving && !state.isDeleting) {
          _syncControllers(state);
        }

        if (state.isSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.isEditMode
                    ? l10n.expense_form_updated
                    : l10n.expense_form_created,
              ),
            ),
          );
          Navigator.pop(context, true);
        }

        if (state.isDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.expense_form_deleted)),
          );
          Navigator.pop(context, true);
        }

        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.expense_form_error_network),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                isEditMode ? l10n.edit_expense_title : l10n.add_expense_title,
              ),
            ),
            body: const LoadingIndicator(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              isEditMode ? l10n.edit_expense_title : l10n.add_expense_title,
            ),
            actions: [
              if (isEditMode)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: state.isDeleting
                      ? null
                      : () => _showDeleteConfirmation(context, l10n),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitleField(context, state, l10n),
                const SizedBox(height: 16),
                _buildAmountField(context, state, l10n),
                const SizedBox(height: 16),
                _buildDateField(context, state, l10n),
                const SizedBox(height: 16),
                _buildCategoryField(context, state, l10n),
                const SizedBox(height: 16),
                _buildNotesField(context, state, l10n),
                const SizedBox(height: 16),
                _buildRecurringToggle(context, state, l10n),
                if (state.isRecurring) ...[
                  const SizedBox(height: 16),
                  _buildFrequencySelector(context, state, l10n),
                ],
                const SizedBox(height: 32),
                _buildSaveButton(context, state, l10n),
                const SizedBox(height: 12),
                _buildCancelButton(context, l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  void _syncControllers(ExpenseFormState state) {
    if (_titleController.text != state.title) {
      _titleController.text = state.title;
      _titleController.selection = TextSelection.fromPosition(
        TextPosition(offset: state.title.length),
      );
    }
    if (_amountController.text != state.amount) {
      _amountController.text = state.amount;
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: state.amount.length),
      );
    }
    if (_notesController.text != state.notes) {
      _notesController.text = state.notes;
      _notesController.selection = TextSelection.fromPosition(
        TextPosition(offset: state.notes.length),
      );
    }
  }

  Widget _buildTitleField(
    BuildContext context,
    ExpenseFormState state,
    AppLocalizations l10n,
  ) {
    String? errorText;
    if (state.fieldErrors.containsKey('title')) {
      final errorKey = state.fieldErrors['title'];
      if (errorKey == 'required') {
        errorText = l10n.expense_form_error_title_required;
      } else if (errorKey == 'min_length') {
        errorText = l10n.expense_form_error_title_min;
      }
    }

    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: l10n.expense_form_title_label,
        hintText: l10n.expense_form_title_hint,
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        context
            .read<ExpenseFormBloc>()
            .add(UpdateField(field: 'title', value: value));
      },
    );
  }

  Widget _buildAmountField(
    BuildContext context,
    ExpenseFormState state,
    AppLocalizations l10n,
  ) {
    String? errorText;
    if (state.fieldErrors.containsKey('amount')) {
      final errorKey = state.fieldErrors['amount'];
      if (errorKey == 'required') {
        errorText = l10n.expense_form_error_amount_required;
      } else if (errorKey == 'positive') {
        errorText = l10n.expense_form_error_amount_positive;
      }
    }

    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: l10n.expense_form_amount_label,
        hintText: l10n.expense_form_amount_hint,
        errorText: errorText,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.attach_money),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        context
            .read<ExpenseFormBloc>()
            .add(UpdateField(field: 'amount', value: value));
      },
    );
  }

  Widget _buildDateField(
    BuildContext context,
    ExpenseFormState state,
    AppLocalizations l10n,
  ) {
    String? errorText;
    if (state.fieldErrors.containsKey('date')) {
      errorText = l10n.expense_form_error_date_required;
    }

    String displayDate;
    try {
      if (state.date.isNotEmpty) {
        final parsed = DateTime.parse(state.date);
        displayDate = DateFormat('dd MMM yyyy').format(parsed);
      } else {
        displayDate = '';
      }
    } catch (_) {
      displayDate = state.date;
    }

    return InkWell(
      onTap: () => _selectDate(context, state),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.expense_form_date_label,
          errorText: errorText,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          displayDate.isNotEmpty ? displayDate : l10n.expense_form_date_label,
          style: displayDate.isNotEmpty
              ? AppTextStyles.bodyLarge
              : AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
        ),
      ),
    );
  }

  Widget _buildCategoryField(
    BuildContext context,
    ExpenseFormState state,
    AppLocalizations l10n,
  ) {
    String? errorText;
    if (state.fieldErrors.containsKey('category')) {
      errorText = l10n.expense_form_error_category_required;
    }

    final categories = <String, String>{
      'maintenance': l10n.expenses_filter_maintenance,
      'furniture': l10n.expenses_filter_furniture,
      'appliances': l10n.expenses_filter_appliances,
      'utilities': l10n.expenses_filter_utilities,
      'cleaning': l10n.expenses_filter_cleaning,
      'supplies': l10n.expenses_filter_supplies,
      'taxes': l10n.expenses_filter_taxes,
      'other': l10n.expenses_filter_other,
    };

    return DropdownButtonFormField<String>(
      initialValue: state.category.isNotEmpty ? state.category : null,
      decoration: InputDecoration(
        labelText: l10n.expense_form_category_label,
        hintText: l10n.expense_form_category_hint,
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
      items: categories.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          context
              .read<ExpenseFormBloc>()
              .add(UpdateField(field: 'category', value: value));
        }
      },
    );
  }

  Widget _buildNotesField(
    BuildContext context,
    ExpenseFormState state,
    AppLocalizations l10n,
  ) {
    return TextFormField(
      controller: _notesController,
      decoration: InputDecoration(
        labelText: l10n.expense_form_notes_label,
        hintText: l10n.expense_form_notes_hint,
        border: const OutlineInputBorder(),
      ),
      maxLines: 3,
      textInputAction: TextInputAction.done,
      onChanged: (value) {
        context
            .read<ExpenseFormBloc>()
            .add(UpdateField(field: 'notes', value: value));
      },
    );
  }

  Widget _buildRecurringToggle(
    BuildContext context,
    ExpenseFormState state,
    AppLocalizations l10n,
  ) {
    return SwitchListTile(
      title: Text(
        l10n.expense_form_recurring,
        style: AppTextStyles.bodyLarge,
      ),
      value: state.isRecurring,
      activeTrackColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      onChanged: (value) {
        context
            .read<ExpenseFormBloc>()
            .add(UpdateField(field: 'isRecurring', value: value));
      },
    );
  }

  Widget _buildFrequencySelector(
    BuildContext context,
    ExpenseFormState state,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Text(
          l10n.expense_form_frequency,
          style: AppTextStyles.bodyLarge,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment<String>(
                value: 'monthly',
                label: Text(l10n.expense_form_monthly),
              ),
              ButtonSegment<String>(
                value: 'yearly',
                label: Text(l10n.expense_form_yearly),
              ),
            ],
            selected: {state.recurrenceFreq ?? 'monthly'},
            onSelectionChanged: (selection) {
              context.read<ExpenseFormBloc>().add(
                    UpdateField(
                      field: 'recurrenceFreq',
                      value: selection.first,
                    ),
                  );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    ExpenseFormState state,
    AppLocalizations l10n,
  ) {
    return ElevatedButton(
      onPressed: state.isSaving
          ? null
          : () {
              context.read<ExpenseFormBloc>().add(const SaveExpense());
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        state.isSaving ? l10n.expense_form_saving : l10n.expense_form_save,
        style: AppTextStyles.button,
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, AppLocalizations l10n) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        l10n.expense_form_cancel,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    ExpenseFormState state,
  ) async {
    DateTime initialDate;
    try {
      initialDate =
          state.date.isNotEmpty ? DateTime.parse(state.date) : DateTime.now();
    } catch (_) {
      initialDate = DateTime.now();
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      context
          .read<ExpenseFormBloc>()
          .add(UpdateField(field: 'date', value: formatted));
    }
  }

  void _showDeleteConfirmation(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.expense_form_delete),
          content: Text(l10n.expense_form_delete_confirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.action_cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<ExpenseFormBloc>().add(const DeleteExpense());
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(l10n.action_delete),
            ),
          ],
        );
      },
    );
  }
}
