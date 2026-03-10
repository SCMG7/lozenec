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
import 'package:studio_rental/core/widgets/empty_state_widget.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/summary_card.dart';
import '../widgets/reservation_list_item.dart';
import '../../domain/entities/dashboard_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboard());
  }

  Future<void> _onRefresh() async {
    context.read<DashboardBloc>().add(const RefreshDashboard());
    await context.read<DashboardBloc>().stream.firstWhere(
          (state) => state is DashboardLoaded || state is DashboardError,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const LoadingIndicator();
          }

          if (state is DashboardError) {
            return ErrorStateWidget(
              message: l10n.dashboard_error_load,
              buttonText: l10n.dashboard_retry,
              onRetry: () {
                context.read<DashboardBloc>().add(const LoadDashboard());
              },
            );
          }

          if (state is DashboardLoaded) {
            return _buildContent(context, state.data);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardData data) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildAppBar(context, data),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(context, data),
                  const SizedBox(height: 24),
                  _buildUpcomingReservations(context, data),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildMonthlyStats(context, data),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, DashboardData data) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.surface,
      elevation: 1,
      title: Text(
        AppStrings.appName,
        style: AppTextStyles.headlineMedium,
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.notifications);
              },
            ),
            if (data.unreadNotificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    data.unreadNotificationCount > 99
                        ? '99+'
                        : data.unreadNotificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(right: 8),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, DashboardData data) {
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = AppStrings.currencySymbols['BGN'] ?? 'BGN';
    final revenueFormatted = NumberFormat.currency(
      locale: 'bg',
      symbol: currencySymbol,
      decimalDigits: 2,
    ).format(data.monthRevenue / 100);
    final occupancyFormatted =
        '${(data.occupancyRate * 100).toStringAsFixed(0)}%';

    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          SummaryCard(
            title: l10n.dashboard_tonight,
            value: data.tonightGuest ?? l10n.dashboard_tonight_free,
            icon: data.tonightGuest != null
                ? Icons.hotel
                : Icons.check_circle_outline,
            iconColor: data.tonightGuest != null
                ? AppColors.reserved
                : AppColors.available,
          ),
          const SizedBox(width: 12),
          SummaryCard(
            title: l10n.dashboard_this_month,
            value: l10n.dashboard_nights_booked(
                data.monthNightsBooked, data.monthTotalNights),
            icon: Icons.calendar_month,
            iconColor: AppColors.primary,
          ),
          const SizedBox(width: 12),
          SummaryCard(
            title: l10n.dashboard_month_revenue,
            value: revenueFormatted,
            icon: Icons.payments_outlined,
            iconColor: AppColors.success,
          ),
          const SizedBox(width: 12),
          SummaryCard(
            title: l10n.dashboard_occupancy_rate,
            value: occupancyFormatted,
            icon: Icons.pie_chart_outline,
            iconColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingReservations(BuildContext context, DashboardData data) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.dashboard_upcoming, style: AppTextStyles.headlineSmall),
            if (data.upcomingReservations.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.calendar);
                },
                child: Text(
                  l10n.dashboard_see_all,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (data.upcomingReservations.isEmpty)
          EmptyStateWidget(
            icon: Icons.event_available,
            message: l10n.dashboard_no_upcoming,
            actionText: l10n.dashboard_add_first,
            onAction: () {
              Navigator.of(context).pushNamed(AppRoutes.addReservation);
            },
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.upcomingReservations.length > 5
                ? 5
                : data.upcomingReservations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final reservation = data.upcomingReservations[index];
              return ReservationListItem(
                reservation: reservation,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.reservationDetail,
                    arguments: reservation.id,
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_circle_outline,
            label: l10n.dashboard_new_reservation,
            color: AppColors.primary,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.addReservation);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.calendar_month,
            label: l10n.dashboard_open_calendar,
            color: AppColors.reserved,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.calendar);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.bar_chart,
            label: l10n.dashboard_analytics,
            color: AppColors.primaryDark,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.analytics);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyStats(BuildContext context, DashboardData data) {
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = AppStrings.currencySymbols['BGN'] ?? 'BGN';
    final revenueFormatted = NumberFormat.currency(
      locale: 'bg',
      symbol: currencySymbol,
      decimalDigits: 2,
    ).format(data.monthRevenue / 100);
    final expensesFormatted = NumberFormat.currency(
      locale: 'bg',
      symbol: currencySymbol,
      decimalDigits: 2,
    ).format(data.monthExpenses / 100);
    final profitFormatted = NumberFormat.currency(
      locale: 'bg',
      symbol: currencySymbol,
      decimalDigits: 2,
    ).format(data.monthNetProfit / 100);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.dashboard_this_month, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),
          _MonthlyStatRow(
            label: l10n.dashboard_total_revenue,
            value: revenueFormatted,
            valueColor: AppColors.success,
          ),
          const Divider(height: 24, color: AppColors.divider),
          _MonthlyStatRow(
            label: l10n.dashboard_total_expenses,
            value: expensesFormatted,
            valueColor: AppColors.error,
          ),
          const Divider(height: 24, color: AppColors.divider),
          _MonthlyStatRow(
            label: l10n.dashboard_net_profit,
            value: profitFormatted,
            valueColor: data.monthNetProfit >= 0
                ? AppColors.profitPositive
                : AppColors.profitNegative,
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyStatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _MonthlyStatRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(color: valueColor),
        ),
      ],
    );
  }
}
