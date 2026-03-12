import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart';
import 'core/widgets/app_bottom_nav.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/calendar/presentation/screens/calendar_screen.dart';
import 'features/calendar/presentation/bloc/calendar_bloc.dart';
import 'features/guests/presentation/screens/guest_list_screen.dart';
import 'features/guests/presentation/bloc/guest_list_bloc.dart';
import 'features/analytics/presentation/screens/analytics_screen.dart';
import 'features/analytics/presentation/bloc/analytics_bloc.dart';
import 'features/expenses/presentation/screens/expenses_screen.dart';
import 'features/expenses/presentation/bloc/expenses_bloc.dart';

class AppShell extends StatefulWidget {
  final int initialTab;

  const AppShell({super.key, this.initialTab = 0});

  /// Switch tab from anywhere that has access to AppShell's context.
  static void switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_AppShellState>();
    state?._switchTo(index);
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex = widget.initialTab;

  void _switchTo(int index) {
    setState(() => _currentIndex = index);
  }

  late final List<Widget> _screens = [
    BlocProvider(
      create: (_) => sl<DashboardBloc>(),
      child: const DashboardScreen(),
    ),
    BlocProvider(
      create: (_) => sl<CalendarBloc>(),
      child: const CalendarScreen(),
    ),
    BlocProvider(
      create: (_) => sl<GuestListBloc>(),
      child: const GuestListScreen(),
    ),
    BlocProvider(
      create: (_) => sl<AnalyticsBloc>(),
      child: const AnalyticsScreen(),
    ),
    BlocProvider(
      create: (_) => sl<ExpensesBloc>(),
      child: const ExpensesScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
