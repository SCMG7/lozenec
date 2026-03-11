import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_routes.dart';
import 'package:studio_rental/core/constants/app_strings.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/core/widgets/loading_indicator.dart';
import 'package:studio_rental/core/widgets/error_state_widget.dart';
import '../bloc/calendar_bloc.dart';
import '../widgets/calendar_day_cell.dart';
import '../widgets/calendar_legend.dart';
import '../widgets/reservation_bottom_sheet.dart';
import '../../domain/entities/calendar_reservation.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    context
        .read<CalendarBloc>()
        .add(LoadMonth(month: DateTime(now.year, now.month)));
  }

  Future<void> _onRefresh() async {
    final state = context.read<CalendarBloc>().state;
    DateTime month = DateTime.now();
    if (state is CalendarLoaded) {
      month = state.currentMonth;
    } else if (state is CalendarLoading && state.currentMonth != null) {
      month = state.currentMonth!;
    } else if (state is CalendarError && state.currentMonth != null) {
      month = state.currentMonth!;
    }
    context.read<CalendarBloc>().add(LoadMonth(month: month));
    await context.read<CalendarBloc>().stream.firstWhere(
          (s) => s is CalendarLoaded || s is CalendarError,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        title: Text(l10n.calendar_title, style: AppTextStyles.headlineMedium),
        actions: [
          TextButton(
            onPressed: () {
              context.read<CalendarBloc>().add(const GoToToday());
            },
            child: Text(
              l10n.calendar_today,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<CalendarBloc, CalendarState>(
        builder: (context, state) {
          if (state is CalendarLoading && state.currentMonth == null) {
            return const LoadingIndicator();
          }

          if (state is CalendarError && state.currentMonth == null) {
            return ErrorStateWidget(
              message: l10n.calendar_error_load,
              buttonText: l10n.action_retry,
              onRetry: () {
                final now = DateTime.now();
                context.read<CalendarBloc>().add(
                      LoadMonth(month: DateTime(now.year, now.month)),
                    );
              },
            );
          }

          DateTime currentMonth = DateTime.now();
          List<CalendarReservation> reservations = [];
          int nightsBooked = 0;
          int totalNights = 0;
          int revenue = 0;
          bool isLoading = false;

          if (state is CalendarLoaded) {
            currentMonth = state.currentMonth;
            reservations = state.reservations;
            nightsBooked = state.summary.nightsBooked;
            totalNights = state.summary.totalNights;
            revenue = state.summary.revenue;
          } else if (state is CalendarLoading) {
            currentMonth = state.currentMonth!;
            isLoading = true;
          } else if (state is CalendarError) {
            currentMonth = state.currentMonth!;
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildMonthNavigation(context, currentMonth),
                    const SizedBox(height: 16),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: LoadingIndicator(),
                      )
                    else if (state is CalendarError)
                      ErrorStateWidget(
                        message: l10n.calendar_error_load,
                        buttonText: l10n.action_retry,
                        onRetry: () {
                          context.read<CalendarBloc>().add(
                                LoadMonth(month: currentMonth),
                              );
                        },
                      )
                    else ...[
                      _buildWeekdayHeaders(context),
                      const SizedBox(height: 4),
                      _buildCalendarGrid(
                          context, currentMonth, reservations),
                      const SizedBox(height: 16),
                      const CalendarLegend(),
                      const SizedBox(height: 16),
                      _buildSummaryStrip(
                        context,
                        nightsBooked,
                        totalNights,
                        revenue,
                      ),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'calendar_fab',
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.addReservation);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.calendar_add_reservation,
          style: AppTextStyles.button,
        ),
      ),
    );
  }

  Widget _buildMonthNavigation(BuildContext context, DateTime currentMonth) {
    final locale = Localizations.localeOf(context).languageCode;
    final monthFormat = DateFormat('MMMM yyyy', locale);
    final monthName = monthFormat.format(currentMonth);
    final capitalizedMonth =
        monthName[0].toUpperCase() + monthName.substring(1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            context.read<CalendarBloc>().add(const PreviousMonth());
          },
          icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
        ),
        Text(capitalizedMonth, style: AppTextStyles.headlineSmall),
        IconButton(
          onPressed: () {
            context.read<CalendarBloc>().add(const NextMonth());
          },
          icon:
              const Icon(Icons.chevron_right, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final weekdays = <String>[];
    // Start from Monday
    for (int i = 1; i <= 7; i++) {
      final date = DateTime(2024, 1, i); // Jan 1 2024 is Monday
      weekdays.add(DateFormat('E', locale).format(date).substring(0, 2));
    }

    return Row(
      children: weekdays
          .map(
            (day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    DateTime currentMonth,
    List<CalendarReservation> reservations,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // Monday = 1, so offset is (weekday - 1)
    final startOffset = (firstDayOfMonth.weekday - 1) % 7;
    final totalCells = startOffset + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rowCount, (row) {
        return SizedBox(
          height: 52,
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNumber = cellIndex - startOffset + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return Expanded(
                  child: CalendarDayCell(
                    day: 0,
                    type: CalendarDayType.outsideMonth,
                  ),
                );
              }

              final cellDate = DateTime(
                  currentMonth.year, currentMonth.month, dayNumber);
              final isToday = cellDate.isAtSameMomentAs(today);
              final dayType =
                  _getDayType(cellDate, today, reservations);
              final guestName =
                  _getGuestNameForDay(cellDate, reservations);
              final dayReservations =
                  _getReservationsForDay(cellDate, reservations);

              return Expanded(
                child: CalendarDayCell(
                  day: dayNumber,
                  type: dayType,
                  guestName: guestName,
                  isToday: isToday,
                  onTap: () {
                    if (dayReservations.isNotEmpty) {
                      ReservationBottomSheet.show(
                        context: context,
                        reservation: dayReservations.first,
                      );
                    } else if (!cellDate.isBefore(today)) {
                      _showAddReservationPrompt(context, cellDate);
                    }
                  },
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  CalendarDayType _getDayType(
    DateTime cellDate,
    DateTime today,
    List<CalendarReservation> reservations,
  ) {
    final normalizedCell =
        DateTime(cellDate.year, cellDate.month, cellDate.day);

    for (final r in reservations) {
      if (r.status.toLowerCase() == 'cancelled') continue;

      final checkIn = DateTime(r.checkInDate.toLocal().year,
          r.checkInDate.toLocal().month, r.checkInDate.toLocal().day);
      final checkOut = DateTime(r.checkOutDate.toLocal().year,
          r.checkOutDate.toLocal().month, r.checkOutDate.toLocal().day);

      if (normalizedCell.isAtSameMomentAs(checkIn)) {
        return CalendarDayType.checkIn;
      }
      if (normalizedCell.isAtSameMomentAs(checkOut)) {
        return CalendarDayType.checkOut;
      }
      if (normalizedCell.isAfter(checkIn) &&
          normalizedCell.isBefore(checkOut)) {
        return CalendarDayType.reserved;
      }
    }

    if (normalizedCell.isBefore(today)) {
      return CalendarDayType.past;
    }

    return CalendarDayType.available;
  }

  String? _getGuestNameForDay(
    DateTime cellDate,
    List<CalendarReservation> reservations,
  ) {
    final normalizedCell =
        DateTime(cellDate.year, cellDate.month, cellDate.day);

    for (final r in reservations) {
      if (r.status.toLowerCase() == 'cancelled') continue;

      final checkIn = DateTime(r.checkInDate.toLocal().year,
          r.checkInDate.toLocal().month, r.checkInDate.toLocal().day);
      final checkOut = DateTime(r.checkOutDate.toLocal().year,
          r.checkOutDate.toLocal().month, r.checkOutDate.toLocal().day);

      if ((normalizedCell.isAtSameMomentAs(checkIn) ||
              normalizedCell.isAfter(checkIn)) &&
          normalizedCell.isBefore(checkOut)) {
        return r.guestFirstName;
      }
      if (normalizedCell.isAtSameMomentAs(checkOut)) {
        return r.guestFirstName;
      }
    }
    return null;
  }

  List<CalendarReservation> _getReservationsForDay(
    DateTime cellDate,
    List<CalendarReservation> reservations,
  ) {
    final normalizedCell =
        DateTime(cellDate.year, cellDate.month, cellDate.day);

    return reservations.where((r) {
      if (r.status.toLowerCase() == 'cancelled') return false;

      final checkIn = DateTime(r.checkInDate.toLocal().year,
          r.checkInDate.toLocal().month, r.checkInDate.toLocal().day);
      final checkOut = DateTime(r.checkOutDate.toLocal().year,
          r.checkOutDate.toLocal().month, r.checkOutDate.toLocal().day);

      return (normalizedCell.isAtSameMomentAs(checkIn) ||
              normalizedCell.isAfter(checkIn)) &&
          (normalizedCell.isAtSameMomentAs(checkOut) ||
              normalizedCell.isBefore(checkOut));
    }).toList();
  }

  void _showAddReservationPrompt(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n.calendar_add_reservation_prompt,
          style: AppTextStyles.headlineSmall,
        ),
        content: Text(
          DateFormat('dd MMM yyyy', Localizations.localeOf(context).languageCode)
              .format(date),
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.action_cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamed(
                AppRoutes.addReservation,
                arguments: date,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.calendar_add_reservation),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStrip(
    BuildContext context,
    int nightsBooked,
    int totalNights,
    int revenue,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final revenueFormatted = NumberFormat.currency(
      locale: 'de_DE',
      symbol: AppStrings.currencySymbol,
      decimalDigits: 2,
    ).format(revenue / 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                l10n.calendar_nights_booked(nightsBooked, totalNights),
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
          Container(
            width: 1,
            height: 30,
            color: AppColors.divider,
          ),
          Column(
            children: [
              Text(
                l10n.calendar_revenue(revenueFormatted),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
