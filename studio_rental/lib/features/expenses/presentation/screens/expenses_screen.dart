import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_routes.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/core/widgets/empty_state_widget.dart';
import 'package:studio_rental/core/widgets/error_state_widget.dart';
import 'package:studio_rental/core/widgets/loading_indicator.dart';
import '../bloc/expenses_bloc.dart';
import '../widgets/expense_list_tile.dart';
import '../widgets/financial_summary_card.dart';
import '../widgets/year_selector.dart';
import '../widgets/monthly_breakdown_list.dart';
import '../widgets/category_breakdown_card.dart';
import '../../domain/entities/financial_summary.dart';
import '../../domain/entities/annual_summary.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExpensesBloc>().add(const LoadExpenses());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.expenses_title),
      ),
      body: BlocBuilder<ExpensesBloc, ExpensesState>(
        builder: (context, state) {
          if (state.isLoading &&
              state.expenses.isEmpty &&
              state.annualSummary == null) {
            return const LoadingIndicator();
          }

          if (state.error != null &&
              state.expenses.isEmpty &&
              state.annualSummary == null) {
            return ErrorStateWidget(
              message: l10n.expenses_error_load,
              buttonText: l10n.action_retry,
              onRetry: () {
                context.read<ExpensesBloc>().add(const LoadExpenses());
              },
            );
          }

          return Column(
            children: [
              _buildViewModeToggle(context, state, l10n),
              Expanded(
                child: state.viewMode == ExpenseViewMode.monthly
                    ? _buildMonthlyView(context, state, l10n)
                    : _buildAnnualView(context, state, l10n),
              ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<ExpensesBloc, ExpensesState>(
        builder: (context, state) {
          if (state.viewMode == ExpenseViewMode.annual) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton(
            heroTag: 'expense_fab',
            onPressed: () => _navigateToAddExpense(context),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildViewModeToggle(
    BuildContext context,
    ExpensesState state,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<ExpenseViewMode>(
        segments: [
          ButtonSegment<ExpenseViewMode>(
            value: ExpenseViewMode.monthly,
            label: Text(l10n.expenses_view_monthly),
            icon: const Icon(Icons.calendar_month, size: 18),
          ),
          ButtonSegment<ExpenseViewMode>(
            value: ExpenseViewMode.annual,
            label: Text(l10n.expenses_view_annual),
            icon: const Icon(Icons.calendar_today, size: 18),
          ),
        ],
        selected: {state.viewMode},
        onSelectionChanged: (selection) {
          context
              .read<ExpensesBloc>()
              .add(ToggleViewMode(viewMode: selection.first));
        },
      ),
    );
  }

  Widget _buildMonthlyView(
    BuildContext context,
    ExpensesState state,
    AppLocalizations l10n,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ExpensesBloc>().add(const RefreshExpenses());
      },
      child: Column(
        children: [
          _buildMonthSelector(context, state, l10n),
          if (state.financialSummary != null)
            FinancialSummaryCard(summary: state.financialSummary!),
          _buildCategoryFilters(context, state, l10n),
          Expanded(
            child: state.expenses.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: EmptyStateWidget(
                          icon: Icons.receipt_long_outlined,
                          message: l10n.expenses_empty,
                          actionText: l10n.expenses_add,
                          onAction: () => _navigateToAddExpense(context),
                        ),
                      ),
                    ],
                  )
                : _buildExpenseList(context, state, l10n),
          ),
          if (state.expenses.isNotEmpty)
            _buildBottomTotal(context, state, l10n),
        ],
      ),
    );
  }

  Widget _buildAnnualView(
    BuildContext context,
    ExpensesState state,
    AppLocalizations l10n,
  ) {
    if (state.isLoading && state.annualSummary == null) {
      return const LoadingIndicator();
    }

    final annual = state.annualSummary;
    if (annual == null) {
      return EmptyStateWidget(
        icon: Icons.bar_chart_outlined,
        message: l10n.expenses_empty,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ExpensesBloc>().add(const RefreshExpenses());
      },
      child: ListView(
        children: [
          YearSelector(
            year: state.selectedYear,
            onYearChanged: (year) {
              context.read<ExpensesBloc>().add(ChangeYear(year: year));
            },
          ),
          FinancialSummaryCard(
            summary: _annualToFinancialSummary(annual),
          ),
          const SizedBox(height: 16),
          MonthlyBreakdownList(months: annual.monthlyBreakdown),
          const SizedBox(height: 16),
          CategoryBreakdownCard(categoryBreakdown: annual.categoryBreakdown),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(
    BuildContext context,
    ExpensesState state,
    AppLocalizations l10n,
  ) {
    final monthFormatted =
        DateFormat('MMMM yyyy').format(state.selectedMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final prev = DateTime(
                state.selectedMonth.year,
                state.selectedMonth.month - 1,
              );
              context.read<ExpensesBloc>().add(ChangeMonth(month: prev));
            },
          ),
          Text(
            monthFormatted,
            style: AppTextStyles.headlineSmall,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final next = DateTime(
                state.selectedMonth.year,
                state.selectedMonth.month + 1,
              );
              context.read<ExpensesBloc>().add(ChangeMonth(month: next));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(
    BuildContext context,
    ExpensesState state,
    AppLocalizations l10n,
  ) {
    final categories = <String?, String>{
      null: l10n.expenses_filter_all,
      'maintenance': l10n.expenses_filter_maintenance,
      'furniture': l10n.expenses_filter_furniture,
      'appliances': l10n.expenses_filter_appliances,
      'utilities': l10n.expenses_filter_utilities,
      'cleaning': l10n.expenses_filter_cleaning,
      'supplies': l10n.expenses_filter_supplies,
      'taxes': l10n.expenses_filter_taxes,
      'other': l10n.expenses_filter_other,
    };

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = categories.entries.elementAt(index);
          final isSelected = state.selectedCategory == entry.key;

          return FilterChip(
            label: Text(entry.value),
            selected: isSelected,
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
            checkmarkColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
            onSelected: (_) {
              context
                  .read<ExpensesBloc>()
                  .add(ChangeCategory(category: entry.key));
            },
          );
        },
      ),
    );
  }

  Widget _buildExpenseList(
    BuildContext context,
    ExpensesState state,
    AppLocalizations l10n,
  ) {
    return ListView.separated(
      itemCount: state.expenses.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 68,
        color: AppColors.divider,
      ),
      itemBuilder: (context, index) {
        final expense = state.expenses[index];
        return ExpenseListTile(
          expense: expense,
          onTap: () => _navigateToEditExpense(context, expense.id),
        );
      },
    );
  }

  Widget _buildBottomTotal(
    BuildContext context,
    ExpensesState state,
    AppLocalizations l10n,
  ) {
    final total = state.expenses.fold<int>(0, (sum, e) => sum + e.amount);
    final totalFormatted = NumberFormat.currency(
      locale: 'de_DE',
      symbol: '\u20AC',
      decimalDigits: 2,
    ).format(total / 100);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.expenses_bottom_total(totalFormatted),
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddExpense(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.addExpense).then((result) {
      if (result == true && mounted) {
        context.read<ExpensesBloc>().add(const RefreshExpenses());
      }
    });
  }

  void _navigateToEditExpense(BuildContext context, String expenseId) {
    Navigator.pushNamed(
      context,
      AppRoutes.editExpense,
      arguments: expenseId,
    ).then((result) {
      if (result == true && mounted) {
        context.read<ExpensesBloc>().add(const RefreshExpenses());
      }
    });
  }
}

FinancialSummary _annualToFinancialSummary(AnnualSummary annual) {
  return FinancialSummary(
    revenue: annual.revenue,
    expenses: annual.expenses,
    netProfit: annual.netProfit,
    revenueChange: annual.revenueChange,
    expenseChange: annual.expenseChange,
    profitChange: annual.profitChange,
  );
}
