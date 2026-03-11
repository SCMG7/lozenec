import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/calendar/data/datasources/calendar_remote_datasource.dart';
import '../../features/calendar/data/repositories/calendar_repository_impl.dart';
import '../../features/calendar/domain/repositories/calendar_repository.dart';
import '../../features/calendar/presentation/bloc/calendar_bloc.dart';
import '../../features/reservations/data/datasources/reservation_remote_datasource.dart';
import '../../features/reservations/data/repositories/reservation_repository_impl.dart';
import '../../features/reservations/domain/repositories/reservation_repository.dart';
import '../../features/reservations/presentation/bloc/reservation_form_bloc.dart';
import '../../features/reservations/presentation/bloc/reservation_detail_bloc.dart';
import '../../features/guests/data/datasources/guest_remote_datasource.dart';
import '../../features/guests/data/repositories/guest_repository_impl.dart';
import '../../features/guests/domain/repositories/guest_repository.dart';
import '../../features/guests/presentation/bloc/guest_list_bloc.dart';
import '../../features/guests/presentation/bloc/guest_detail_bloc.dart';
import '../../features/guests/presentation/bloc/guest_form_bloc.dart';
import '../../features/expenses/data/datasources/expense_remote_datasource.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/expenses/presentation/bloc/expenses_bloc.dart';
import '../../features/expenses/presentation/bloc/expense_form_bloc.dart';
import '../../features/analytics/data/datasources/analytics_remote_datasource.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../../features/settings/data/datasources/settings_remote_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Core
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage());
  sl.registerLazySingleton<ApiClient>(
      () => ApiClient(secureStorage: sl<SecureStorage>()));

  // Auth
  sl.registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasource(apiClient: sl<ApiClient>()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        remoteDatasource: sl<AuthRemoteDatasource>(),
        secureStorage: sl<SecureStorage>(),
      ));
  sl.registerFactory<AuthBloc>(
      () => AuthBloc(authRepository: sl<AuthRepository>()));

  // Dashboard
  sl.registerLazySingleton<DashboardRemoteDatasource>(
      () => DashboardRemoteDatasource(apiClient: sl<ApiClient>()));
  sl.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(remoteDatasource: sl<DashboardRemoteDatasource>()));
  sl.registerFactory<DashboardBloc>(
      () => DashboardBloc(dashboardRepository: sl<DashboardRepository>()));

  // Calendar
  sl.registerLazySingleton<CalendarRemoteDatasource>(
      () => CalendarRemoteDatasource(apiClient: sl<ApiClient>()));
  sl.registerLazySingleton<CalendarRepository>(
      () => CalendarRepositoryImpl(remoteDatasource: sl<CalendarRemoteDatasource>()));
  sl.registerFactory<CalendarBloc>(
      () => CalendarBloc(calendarRepository: sl<CalendarRepository>()));

  // Reservations
  sl.registerLazySingleton<ReservationRemoteDatasource>(
      () => ReservationRemoteDatasource(apiClient: sl<ApiClient>()));
  sl.registerLazySingleton<ReservationRepository>(() => ReservationRepositoryImpl(
        remoteDatasource: sl<ReservationRemoteDatasource>(),
      ));
  sl.registerLazySingleton<ReservationFormBloc>(() => ReservationFormBloc(
        reservationRepository: sl<ReservationRepository>(),
        guestRepository: sl<GuestRepository>(),
      ));
  sl.registerFactory<ReservationDetailBloc>(() => ReservationDetailBloc(
        reservationRepository: sl<ReservationRepository>(),
      ));

  // Guests
  sl.registerLazySingleton<GuestRemoteDatasource>(
      () => GuestRemoteDatasource(apiClient: sl<ApiClient>()));
  sl.registerLazySingleton<GuestRepository>(
      () => GuestRepositoryImpl(remoteDatasource: sl<GuestRemoteDatasource>()));
  sl.registerFactory<GuestListBloc>(
      () => GuestListBloc(guestRepository: sl<GuestRepository>()));
  sl.registerFactory<GuestDetailBloc>(
      () => GuestDetailBloc(guestRepository: sl<GuestRepository>()));
  sl.registerFactory<GuestFormBloc>(
      () => GuestFormBloc(guestRepository: sl<GuestRepository>()));

  // Expenses
  sl.registerLazySingleton<ExpenseRemoteDatasource>(
      () => ExpenseRemoteDatasource(apiClient: sl<ApiClient>()));
  sl.registerLazySingleton<ExpenseRepository>(
      () => ExpenseRepositoryImpl(remoteDatasource: sl<ExpenseRemoteDatasource>()));
  sl.registerFactory<ExpensesBloc>(
      () => ExpensesBloc(expenseRepository: sl<ExpenseRepository>()));
  sl.registerFactory<ExpenseFormBloc>(
      () => ExpenseFormBloc(expenseRepository: sl<ExpenseRepository>()));

  // Analytics
  sl.registerLazySingleton<AnalyticsRemoteDatasource>(
      () => AnalyticsRemoteDatasource(apiClient: sl<ApiClient>()));
  sl.registerLazySingleton<AnalyticsRepository>(
      () => AnalyticsRepositoryImpl(remoteDatasource: sl<AnalyticsRemoteDatasource>()));
  sl.registerFactory<AnalyticsBloc>(
      () => AnalyticsBloc(analyticsRepository: sl<AnalyticsRepository>()));

  // Settings
  sl.registerLazySingleton<SettingsRemoteDatasource>(
      () => SettingsRemoteDatasource(apiClient: sl<ApiClient>()));
  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(
        remoteDatasource: sl<SettingsRemoteDatasource>(),
        secureStorage: sl<SecureStorage>(),
      ));
  sl.registerFactory<SettingsBloc>(
      () => SettingsBloc(settingsRepository: sl<SettingsRepository>()));

  // Notifications
  sl.registerLazySingleton<NotificationRemoteDatasource>(
      () => NotificationRemoteDatasource(apiClient: sl<ApiClient>()));
  sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(remoteDatasource: sl<NotificationRemoteDatasource>()));
  sl.registerFactory<NotificationsBloc>(
      () => NotificationsBloc(notificationRepository: sl<NotificationRepository>()));
}
