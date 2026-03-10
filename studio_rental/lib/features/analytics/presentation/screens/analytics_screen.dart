import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:studio_rental/core/constants/app_colors.dart';
import 'package:studio_rental/core/constants/app_text_styles.dart';
import 'package:studio_rental/core/widgets/empty_state_widget.dart';
import 'package:studio_rental/core/widgets/error_state_widget.dart';
import 'package:studio_rental/core/widgets/loading_indicator.dart';
import '../../domain/entities/analytics_data.dart';
import '../bloc/analytics_bloc.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'this_month';

  static const List<String> _periodKeys = [
    'this_month',
    'last_month',
    'last_3_months',
    'last_6_months',
    'this_year',
    'custom',
  ];

  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(const LoadAnalytics());
  }

  String _periodLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'this_month':
        return l10n.analytics_this_month;
      case 'last_month':
        return l10n.analytics_last_month;
      case 'last_3_months':
        return l10n.analytics_last_3_months;
      case 'last_6_months':
        return l10n.analytics_last_6_months;
      case 'this_year':
        return l10n.analytics_this_year;
      case 'custom':
        return l10n.analytics_custom;
      default:
        return key;
    }
  }

  Future<void> _onPeriodSelected(String period) async {
    if (period == 'custom') {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
        locale: Localizations.localeOf(context),
      );
      if (range != null && mounted) {
        setState(() => _selectedPeriod = 'custom');
        context.read<AnalyticsBloc>().add(ChangePeriod(
              period: 'custom',
              startDate: range.start,
              endDate: range.end,
            ));
      }
    } else {
      setState(() => _selectedPeriod = period);
      context.read<AnalyticsBloc>().add(ChangePeriod(period: period));
    }
  }

  String _formatCurrency(int cents) {
    final amount = cents / 100;
    return NumberFormat.currency(
      locale: 'bg_BG',
      symbol: '',
      decimalDigits: 2,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analytics_title),
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const LoadingIndicator();
          }

          if (state is AnalyticsError) {
            return ErrorStateWidget(
              message: state.message == 'network_error'
                  ? l10n.error_network
                  : l10n.error_generic,
              buttonText: l10n.button_retry,
              onRetry: () => context
                  .read<AnalyticsBloc>()
                  .add(ChangePeriod(period: _selectedPeriod)),
            );
          }

          if (state is AnalyticsLoaded) {
            return _buildContent(context, state.data, l10n);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AnalyticsData data,
    AppLocalizations l10n,
  ) {
    final hasData = data.totalRevenue > 0 ||
        data.totalExpenses > 0 ||
        data.occupancy.bookedNights > 0;

    if (!hasData) {
      return Column(
        children: [
          _buildPeriodSelector(context, l10n),
          Expanded(
            child: EmptyStateWidget(
              icon: Icons.bar_chart_outlined,
              message: l10n.analytics_empty,
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<AnalyticsBloc>()
            .add(ChangePeriod(period: _selectedPeriod));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(context, l10n),
            const SizedBox(height: 16),
            _buildOverviewCards(data, l10n),
            const SizedBox(height: 24),
            _buildOccupancySection(data.occupancy, l10n),
            const SizedBox(height: 24),
            _buildRevenueChart(data.revenueChart, l10n),
            const SizedBox(height: 24),
            _buildExpensesPieChart(data.expensesBreakdown, l10n),
            const SizedBox(height: 24),
            _buildReservationStatsGrid(data.reservationStats, l10n),
            const SizedBox(height: 24),
            _buildMonthlyComparisonTable(data.monthlyComparison, l10n),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemCount: _periodKeys.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final key = _periodKeys[index];
          final isSelected = key == _selectedPeriod;
          return ChoiceChip(
            label: Text(_periodLabel(context, key)),
            selected: isSelected,
            onSelected: (_) => _onPeriodSelected(key),
            selectedColor: AppColors.primary,
            labelStyle: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards(AnalyticsData data, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _OverviewCard(
            label: l10n.analytics_revenue,
            value: _formatCurrency(data.totalRevenue),
            color: AppColors.success,
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _OverviewCard(
            label: l10n.analytics_expenses,
            value: _formatCurrency(data.totalExpenses),
            color: AppColors.error,
            icon: Icons.trending_down,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _OverviewCard(
            label: l10n.analytics_net_profit,
            value: _formatCurrency(data.netProfit),
            color: data.netProfit >= 0
                ? AppColors.profitPositive
                : AppColors.profitNegative,
            icon: data.netProfit >= 0
                ? Icons.arrow_upward
                : Icons.arrow_downward,
          ),
        ),
      ],
    );
  }

  Widget _buildOccupancySection(OccupancyData occupancy, AppLocalizations l10n) {
    final percentage = (occupancy.rate * 100).toStringAsFixed(1);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.analytics_occupancy, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: occupancy.rate,
                        strokeWidth: 8,
                        backgroundColor: AppColors.divider,
                        color: AppColors.primary,
                      ),
                      Text(
                        '$percentage%',
                        style: AppTextStyles.titleMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.analytics_booked_nights(
                          occupancy.bookedNights,
                          occupancy.totalNights,
                        ),
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: occupancy.rate,
                          backgroundColor: AppColors.divider,
                          color: AppColors.primary,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(
    List<RevenueChartPoint> chartData,
    AppLocalizations l10n,
  ) {
    if (chartData.isEmpty) return const SizedBox.shrink();

    final maxY = chartData.fold<double>(0, (prev, e) {
      final total = (e.confirmedRevenue + e.pendingRevenue) / 100;
      return total > prev ? total : prev;
    });

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.analytics_revenue_chart, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                _LegendDot(
                    color: AppColors.confirmed, label: l10n.analytics_confirmed),
                const SizedBox(width: 16),
                _LegendDot(
                    color: AppColors.pending, label: l10n.analytics_pending),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          _formatCurrency((rod.toY * 100).toInt()),
                          AppTextStyles.bodySmall.copyWith(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < chartData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                chartData[index].month,
                                style: AppTextStyles.caption,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: AppTextStyles.caption,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  barGroups: List.generate(chartData.length, (index) {
                    final point = chartData[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: point.confirmedRevenue / 100,
                          color: AppColors.confirmed,
                          width: 12,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: point.pendingRevenue / 100,
                          color: AppColors.pending,
                          width: 12,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesPieChart(
    List<ExpenseCategoryBreakdown> breakdown,
    AppLocalizations l10n,
  ) {
    if (breakdown.isEmpty) return const SizedBox.shrink();

    final colors = [
      AppColors.primary,
      AppColors.confirmed,
      AppColors.pending,
      AppColors.error,
      AppColors.primaryLight,
      AppColors.checkIn,
      AppColors.reserved,
      AppColors.pastDay,
    ];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.analytics_expenses_breakdown,
                style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: List.generate(breakdown.length, (index) {
                    final item = breakdown[index];
                    final color = colors[index % colors.length];
                    return PieChartSectionData(
                      value: item.percentage,
                      title: '${item.percentage.toStringAsFixed(0)}%',
                      color: color,
                      radius: 60,
                      titleStyle: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: List.generate(breakdown.length, (index) {
                final item = breakdown[index];
                final color = colors[index % colors.length];
                return _LegendDot(
                  color: color,
                  label:
                      '${item.category} (${_formatCurrency(item.total)})',
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationStatsGrid(
    ReservationStats stats,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.analytics_reservation_stats,
                style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _StatTile(
                  label: l10n.analytics_avg_stay,
                  value: '${stats.avgLengthOfStay.toStringAsFixed(1)} ${l10n.analytics_nights}',
                ),
                _StatTile(
                  label: l10n.analytics_avg_revenue,
                  value: _formatCurrency(stats.avgRevenuePerReservation),
                ),
                _StatTile(
                  label: l10n.analytics_longest_stay,
                  value: '${stats.longestStay} ${l10n.analytics_nights}',
                  subtitle: stats.longestStayGuest,
                ),
                _StatTile(
                  label: l10n.analytics_most_frequent_guest,
                  value: stats.mostFrequentGuest ?? '-',
                  subtitle: stats.mostFrequentGuestStays > 0
                      ? l10n.analytics_stays_count(stats.mostFrequentGuestStays)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyComparisonTable(
    List<MonthlyComparisonRow> rows,
    AppLocalizations l10n,
  ) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.analytics_monthly_comparison,
                style: AppTextStyles.headlineSmall),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                headingTextStyle: AppTextStyles.titleMedium,
                dataTextStyle: AppTextStyles.bodySmall,
                columns: [
                  DataColumn(label: Text(l10n.analytics_month)),
                  DataColumn(
                      label: Text(l10n.analytics_nights_short), numeric: true),
                  DataColumn(
                      label: Text(l10n.analytics_revenue_short), numeric: true),
                  DataColumn(
                      label: Text(l10n.analytics_expenses_short),
                      numeric: true),
                  DataColumn(
                      label: Text(l10n.analytics_profit_short), numeric: true),
                ],
                rows: rows.map((row) {
                  return DataRow(cells: [
                    DataCell(Text(row.month)),
                    DataCell(Text('${row.nightsBooked}')),
                    DataCell(Text(_formatCurrency(row.revenue))),
                    DataCell(Text(_formatCurrency(row.expenses))),
                    DataCell(Text(
                      _formatCurrency(row.netProfit),
                      style: TextStyle(
                        color: row.netProfit >= 0
                            ? AppColors.profitPositive
                            : AppColors.profitNegative,
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _OverviewCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.caption),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: AppTextStyles.titleLarge.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(label, style: AppTextStyles.caption),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;

  const _StatTile({
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (subtitle != null)
            Text(subtitle!, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
