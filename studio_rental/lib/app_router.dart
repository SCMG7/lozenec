import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_routes.dart';
import 'core/di/service_locator.dart';
import 'app_shell.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/reservations/presentation/screens/edit_reservation_screen.dart';
import 'features/reservations/presentation/screens/reservation_detail_screen.dart';
import 'features/reservations/presentation/bloc/reservation_form_bloc.dart';
import 'features/reservations/presentation/bloc/reservation_detail_bloc.dart';
import 'features/guests/presentation/screens/add_edit_guest_screen.dart';
import 'features/guests/presentation/screens/guest_detail_screen.dart';
import 'features/guests/presentation/bloc/guest_form_bloc.dart';
import 'features/guests/presentation/bloc/guest_detail_bloc.dart';
import 'features/expenses/presentation/screens/expenses_screen.dart';
import 'features/expenses/presentation/screens/add_edit_expense_screen.dart';
import 'features/expenses/presentation/bloc/expenses_bloc.dart';
import 'features/expenses/presentation/bloc/expense_form_bloc.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';
import 'features/settings/presentation/screens/change_password_screen.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const AppShell());

      case AppRoutes.editReservation:
        final reservationId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ReservationFormBloc>(
            create: (_) => sl<ReservationFormBloc>(),
            child: EditReservationScreen(reservationId: reservationId),
          ),
        );

      case AppRoutes.reservationDetail:
        final reservationId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ReservationDetailBloc>(
            create: (_) => sl<ReservationDetailBloc>(),
            child: ReservationDetailScreen(reservationId: reservationId),
          ),
        );

      case AppRoutes.addGuest:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<GuestFormBloc>(
            create: (_) => sl<GuestFormBloc>(),
            child: const AddEditGuestScreen(),
          ),
        );

      case AppRoutes.editGuest:
        final guestId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<GuestFormBloc>(
            create: (_) => sl<GuestFormBloc>(),
            child: AddEditGuestScreen(guestId: guestId),
          ),
        );

      case AppRoutes.guestDetail:
        final guestId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<GuestDetailBloc>(
            create: (_) => sl<GuestDetailBloc>(),
            child: GuestDetailScreen(guestId: guestId),
          ),
        );

      case AppRoutes.expenses:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ExpensesBloc>(
            create: (_) => sl<ExpensesBloc>(),
            child: const ExpensesScreen(),
          ),
        );

      case AppRoutes.addExpense:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ExpenseFormBloc>(
            create: (_) => sl<ExpenseFormBloc>(),
            child: const AddEditExpenseScreen(),
          ),
        );

      case AppRoutes.editExpense:
        final expenseId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ExpenseFormBloc>(
            create: (_) => sl<ExpenseFormBloc>(),
            child: AddEditExpenseScreen(expenseId: expenseId),
          ),
        );

      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<NotificationsBloc>(
            create: (_) => sl<NotificationsBloc>(),
            child: const NotificationsScreen(),
          ),
        );

      case AppRoutes.changePassword:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<SettingsBloc>(
            create: (_) => sl<SettingsBloc>(),
            child: const ChangePasswordScreen(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
