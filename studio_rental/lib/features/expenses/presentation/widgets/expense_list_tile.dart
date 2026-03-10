import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import '../../domain/entities/expense.dart';
import 'expense_category_icon.dart';

class ExpenseListTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseListTile({
    super.key,
    required this.expense,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final amountFormatted = NumberFormat.currency(
      locale: 'bg_BG',
      symbol: '',
      decimalDigits: 2,
    ).format(expense.amount / 100);

    String dateFormatted;
    try {
      final parsedDate = DateTime.parse(expense.date);
      dateFormatted = DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (_) {
      dateFormatted = expense.date;
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ExpenseCategoryIcon(category: expense.category),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        dateFormatted,
                        style: AppTextStyles.caption,
                      ),
                      if (expense.isRecurring) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.repeat,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '-$amountFormatted',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
