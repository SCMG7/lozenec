import 'package:flutter/material.dart';
import 'core/constants/app_routes.dart';
import 'app_shell.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/reservations/presentation/screens/add_reservation_screen.dart';
import 'features/reservations/presentation/screens/edit_reservation_screen.dart';
import 'features/reservations/presentation/screens/reservation_detail_screen.dart';
import 'features/guests/presentation/screens/add_edit_guest_screen.dart';
import 'features/guests/presentation/screens/guest_detail_screen.dart';
import 'features/expenses/presentation/screens/expenses_screen.dart';
import 'features/expenses/presentation/screens/add_edit_expense_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/settings/presentation/screens/change_password_screen.dart';

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

      case AppRoutes.addReservation:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AddReservationScreen(
            preselectedDate: args?['date'] as String?,
            preselectedGuestId: args?['guestId'] as String?,
          ),
        );

      case AppRoutes.editReservation:
        final reservationId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) =>
              EditReservationScreen(reservationId: reservationId),
        );

      case AppRoutes.reservationDetail:
        final reservationId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) =>
              ReservationDetailScreen(reservationId: reservationId),
        );

      case AppRoutes.addGuest:
        return MaterialPageRoute(
          builder: (_) => const AddEditGuestScreen(),
        );

      case AppRoutes.editGuest:
        final guestId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => AddEditGuestScreen(guestId: guestId),
        );

      case AppRoutes.guestDetail:
        final guestId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => GuestDetailScreen(guestId: guestId),
        );

      case AppRoutes.expenses:
        return MaterialPageRoute(builder: (_) => const ExpensesScreen());

      case AppRoutes.addExpense:
        return MaterialPageRoute(
          builder: (_) => const AddEditExpenseScreen(),
        );

      case AppRoutes.editExpense:
        final expenseId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => AddEditExpenseScreen(expenseId: expenseId),
        );

      case AppRoutes.notifications:
        return MaterialPageRoute(
            builder: (_) => const NotificationsScreen());

      case AppRoutes.changePassword:
        return MaterialPageRoute(
            builder: (_) => const ChangePasswordScreen());

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
