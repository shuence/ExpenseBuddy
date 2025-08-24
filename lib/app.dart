import 'package:expensebuddy/providers/currency_provider.dart';
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
import 'providers/auth_provider.dart';
import 'data/remote/auth_service.dart';
import 'di/injection.dart';
import 'services/app_lifecycle_service.dart';
import 'widgets/error_boundary.dart';
import 'blocs/user_preferences_bloc.dart';

class ExpenseBuddyApp extends StatefulWidget {
  const ExpenseBuddyApp({super.key});

  @override
  State<ExpenseBuddyApp> createState() => _ExpenseBuddyAppState();
}

class _ExpenseBuddyAppState extends State<ExpenseBuddyApp> with WidgetsBindingObserver {
  final AppLifecycleService _lifecycleService = AppLifecycleService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      await _lifecycleService.initialize();
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _lifecycleService.onAppResumed();
        break;
      case AppLifecycleState.paused:
        _lifecycleService.onAppPaused();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive helper
    try {
      ResponsiveHelper.init(context);
    } catch (e) {
      debugPrint('Error initializing ResponsiveHelper: $e');
    }
    
    return ErrorBoundary(
      child: DevicePreview(
        enabled: kDebugMode, // Only enable device preview in debug mode
        builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(
            create: (context) => getIt<ThemeBloc>()..add(const LoadTheme()),
          ),
          BlocProvider<AuthBloc>(
            create: (context) {
              try {
                return getIt<AuthBloc>();
              } catch (e) {
                debugPrint('Error getting AuthBloc: $e');
                // Create a fallback AuthBloc if dependency injection fails
                return AuthBloc(AuthService());
              }
            },
            lazy: false, // Initialize immediately to avoid delays
          ),
          BlocProvider<ExpenseBloc>(
            create: (context) => getIt<ExpenseBloc>(),
            lazy: false, // Initialize immediately to avoid delays
          ),
          BlocProvider<OnboardingBloc>(
            create: (context) => getIt<OnboardingBloc>(),
            lazy: false, // Initialize immediately to avoid delays
          ),
          BlocProvider<UserPreferencesBloc>(
            create: (context) => getIt<UserPreferencesBloc>(),
            lazy: false, // Initialize immediately to avoid delays
          ),
          BlocProvider<CurrencyBloc>(
            create: (context) => getIt<CurrencyBloc>(),
            lazy: false, // Initialize immediately to avoid delays
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
    ));
  }

  static final GoRouter _router = AppRouter.router;
}
