import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryLight = Color(0xFF4DA3FF);
  static const Color primaryDark = Color(0xFF0D47A1);

  // Calendar day colors
  static const Color available = Color(0xFF4CAF50);
  static const Color reserved = Color(0xFF00897B);
  static const Color checkIn = Color(0xFFFFA726);
  static const Color checkOut = Color(0xFFEF5350);
  static const Color pastDay = Color(0xFFBDBDBD);

  // Status
  static const Color confirmed = Color(0xFF4CAF50);
  static const Color pending = Color(0xFFFFA726);
  static const Color cancelled = Color(0xFFEF5350);

  // Payment
  static const Color paid = Color(0xFF4CAF50);
  static const Color partiallyPaid = Color(0xFFFFA726);
  static const Color unpaid = Color(0xFFEF5350);

  // General
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color cardShadow = Color(0x1A000000);

  // Profit
  static const Color profitPositive = Color(0xFF388E3C);
  static const Color profitNegative = Color(0xFFD32F2F);
}
