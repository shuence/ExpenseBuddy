import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_preview/device_preview.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/responsive_constants.dart';
import 'router/app_router.dart';
import 'providers/theme_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/onboarding_provider.dart';
import 'di/injection.dart';

class ExpenseBuddyApp extends StatelessWidget {
  const ExpenseBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize responsive helper
    ResponsiveHelper.init(context);
    
    return DevicePreview(
      enabled: kDebugMode, // Only enable device preview in debug mode
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(
            create: (context) => getIt<ThemeBloc>()..add(const LoadTheme()),
          ),
          BlocProvider<ExpenseBloc>(
            create: (context) => getIt<ExpenseBloc>(),
          ),
          BlocProvider<OnboardingBloc>(
            create: (context) => getIt<OnboardingBloc>(),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            final currentTheme = themeState is ThemeLoaded 
                ? themeState.theme 
                : AppTheme.lightTheme; // Default to light theme (white mode)
            
            return CupertinoApp.router(
              title: AppConstants.appName,
              theme: currentTheme,
              routerConfig: _router,
              debugShowCheckedModeBanner: false, // Remove debug banner
            );
          },
        ),
      ),
    );
  }

  static final GoRouter _router = AppRouter.router;
}
