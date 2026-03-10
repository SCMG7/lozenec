import 'package:flutter/material.dart';
import 'package:studio_rental/core/constants/app_colors.dart';

class GuestAvatar extends StatelessWidget {
  final String initials;
  final double size;

  const GuestAvatar({
    super.key,
    required this.initials,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryLight,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
