import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_constants.dart';
import 'router/app_router.dart';
import 'services/theme_service.dart';


class ExpenseBuddyApp extends StatefulWidget {
  const ExpenseBuddyApp({super.key});

  @override
  State<ExpenseBuddyApp> createState() => _ExpenseBuddyAppState();
}

class _ExpenseBuddyAppState extends State<ExpenseBuddyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.instance.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return CupertinoApp.router(
          title: AppConstants.appName,
          theme: ThemeService.instance.currentTheme,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  static final GoRouter _router = AppRouter.router;
}
