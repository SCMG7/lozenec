import 'package:flutter/material.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _LegendItem(
          color: AppColors.available,
          label: l10n.calendar_legend_available,
        ),
        _LegendItem(
          color: AppColors.reserved,
          label: l10n.calendar_legend_reserved,
        ),
        _LegendItem(
          color: AppColors.checkIn,
          label: l10n.calendar_legend_check_in,
        ),
        _LegendItem(
          color: AppColors.checkOut,
          label: l10n.calendar_legend_check_out,
        ),
        _LegendItem(
          color: AppColors.pastDay,
          label: l10n.calendar_legend_past,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
