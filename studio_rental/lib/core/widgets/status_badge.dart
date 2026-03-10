import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.textColor = Colors.white,
  });

  factory StatusBadge.confirmed(String label) => StatusBadge(
        label: label,
        backgroundColor: AppColors.confirmed,
      );

  factory StatusBadge.pending(String label) => StatusBadge(
        label: label,
        backgroundColor: AppColors.pending,
      );

  factory StatusBadge.cancelled(String label) => StatusBadge(
        label: label,
        backgroundColor: AppColors.cancelled,
      );

  factory StatusBadge.paid(String label) => StatusBadge(
        label: label,
        backgroundColor: AppColors.paid,
      );

  factory StatusBadge.partiallyPaid(String label) => StatusBadge(
        label: label,
        backgroundColor: AppColors.partiallyPaid,
      );

  factory StatusBadge.unpaid(String label) => StatusBadge(
        label: label,
        backgroundColor: AppColors.unpaid,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
