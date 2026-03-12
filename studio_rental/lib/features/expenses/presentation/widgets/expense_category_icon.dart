import 'package:flutter/material.dart';
import 'package:studio_rental/core/constants/app_colors.dart';

class ExpenseCategoryIcon extends StatelessWidget {
  final String category;
  final double size;

  const ExpenseCategoryIcon({
    super.key,
    required this.category,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(
        _icon,
        color: _iconColor,
        size: size * 0.55,
      ),
    );
  }

  IconData get _icon {
    switch (category) {
      case 'maintenance':
        return Icons.build_outlined;
      case 'furniture':
        return Icons.chair_outlined;
      case 'appliances':
        return Icons.kitchen_outlined;
      case 'utilities':
        return Icons.bolt_outlined;
      case 'cleaning':
        return Icons.cleaning_services_outlined;
      case 'supplies':
        return Icons.shopping_bag_outlined;
      case 'taxes':
        return Icons.receipt_long_outlined;
      case 'other':
      default:
        return Icons.more_horiz;
    }
  }

  Color get _iconColor {
    switch (category) {
      case 'maintenance':
        return const Color(0xFFE65100);
      case 'furniture':
        return const Color(0xFF5D4037);
      case 'appliances':
        return const Color(0xFF455A64);
      case 'utilities':
        return const Color(0xFFF9A825);
      case 'cleaning':
        return const Color(0xFF00838F);
      case 'supplies':
        return const Color(0xFF2E7D32);
      case 'taxes':
        return const Color(0xFF1565C0);
      case 'other':
      default:
        return AppColors.textSecondary;
    }
  }

  Color get _backgroundColor {
    switch (category) {
      case 'maintenance':
        return const Color(0xFFFFF3E0);
      case 'furniture':
        return const Color(0xFFEFEBE9);
      case 'appliances':
        return const Color(0xFFECEFF1);
      case 'utilities':
        return const Color(0xFFFFFDE7);
      case 'cleaning':
        return const Color(0xFFE0F7FA);
      case 'supplies':
        return const Color(0xFFE8F5E9);
      case 'taxes':
        return const Color(0xFFE3F2FD);
      case 'other':
      default:
        return const Color(0xFFF5F5F5);
    }
  }
}
