import 'package:flutter/material.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';

class YearSelector extends StatelessWidget {
  final int year;
  final ValueChanged<int> onYearChanged;

  const YearSelector({
    super.key,
    required this.year,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onYearChanged(year - 1),
          ),
          Text(
            year.toString(),
            style: AppTextStyles.headlineSmall,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => onYearChanged(year + 1),
          ),
        ],
      ),
    );
  }
}
