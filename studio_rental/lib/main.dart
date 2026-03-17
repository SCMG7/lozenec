import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:studio_rental/l10n/app_localizations.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'core/services/subscription_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/properties/presentation/bloc/property_bloc.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServiceLocator();
  runApp(const StudioRentalApp());
}

class StudioRentalApp extends StatelessWidget {
  const StudioRentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => SubscriptionBloc()),
        BlocProvider(create: (_) => sl<PropertyBloc>()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'My Studio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('bg'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
