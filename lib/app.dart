import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'router/app_router.dart';
import 'services/theme_service.dart';
import 'providers/transaction_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/onboarding_provider.dart';
import 'data/remote/auth_service.dart';


class ExpenseBuddyApp extends StatefulWidget {
  const ExpenseBuddyApp({super.key});

  @override
  State<ExpenseBuddyApp> createState() => _ExpenseBuddyAppState();
}

class _ExpenseBuddyAppState extends State<ExpenseBuddyApp> {
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
