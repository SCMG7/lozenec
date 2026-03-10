import 'package:flutter/material.dart';
import 'package:studio_rental/core/constants/app_colors.dart';

enum CalendarDayType {
  available,
  reserved,
  checkIn,
  checkOut,
  past,
  outsideMonth,
}

class CalendarDayCell extends StatelessWidget {
  final int day;
  final CalendarDayType type;
  final String? guestName;
  final bool isToday;
  final VoidCallback? onTap;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.type,
    this.guestName,
    this.isToday = false,
    this.onTap,
  });

  Color get _backgroundColor {
    switch (type) {
      case CalendarDayType.available:
        return AppColors.surface;
      case CalendarDayType.reserved:
        return AppColors.reserved;
      case CalendarDayType.checkIn:
        return AppColors.checkIn;
      case CalendarDayType.checkOut:
        return AppColors.checkOut;
      case CalendarDayType.past:
        return AppColors.pastDay.withValues(alpha: 0.3);
      case CalendarDayType.outsideMonth:
        return Colors.transparent;
    }
  }

  Color get _textColor {
    switch (type) {
      case CalendarDayType.available:
        return AppColors.textPrimary;
      case CalendarDayType.reserved:
      case CalendarDayType.checkIn:
      case CalendarDayType.checkOut:
        return Colors.white;
      case CalendarDayType.past:
        return AppColors.textSecondary;
      case CalendarDayType.outsideMonth:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (type == CalendarDayType.outsideMonth) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: isToday
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isToday ? FontWeight.bold : FontWeight.w500,
                color: _textColor,
              ),
            ),
            if (guestName != null && guestName!.isNotEmpty) ...[
              const SizedBox(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  guestName!,
                  style: TextStyle(
                    fontSize: 8,
                    color: _textColor.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
