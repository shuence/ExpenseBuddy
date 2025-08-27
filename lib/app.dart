import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'router/app_router.dart';
import 'services/theme_service.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/onboarding_provider.dart';
import 'data/remote/auth_service.dart';
import 'services/sync_service.dart';


class ExpenseBuddyApp extends StatefulWidget {
  const ExpenseBuddyApp({super.key});

  @override
  State<ExpenseBuddyApp> createState() => _ExpenseBuddyAppState();
}

class _ExpenseBuddyAppState extends State<ExpenseBuddyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - trigger sync if online
      _triggerForegroundSync();
    }
  }

  Future<void> _triggerForegroundSync() async {
    try {
      final syncService = SyncService();
      if (syncService.isSyncing) return; // Don't trigger if already syncing
      
      // Trigger a quick sync when app comes to foreground
      await syncService.syncNow();
    } catch (e) {
      print('Failed to trigger foreground sync: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CupertinoApp(
            home: CupertinoPageScaffold(
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            ),
          );
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(AuthService()),
            ),
            BlocProvider<OnboardingBloc>(
              create: (context) => OnboardingBloc(snapshot.data!),
            ),
            ChangeNotifierProvider(create: (context) => TransactionProvider()),
            ChangeNotifierProvider(create: (context) => BudgetProvider()),
            ChangeNotifierProvider(create: (context) => NavigationProvider()),
          ],
          child: ValueListenableBuilder<bool>(
            valueListenable: ThemeService.instance.isDarkModeNotifier,
            builder: (context, isDark, _) {
              return CupertinoApp.router(
                title: AppConstants.appName,
                theme: ThemeService.instance.currentTheme,
                routerConfig: _router,
                debugShowCheckedModeBanner: false,
              );
            },
          ),
        );
      },
    );
  }

  static final GoRouter _router = AppRouter.router;
}
