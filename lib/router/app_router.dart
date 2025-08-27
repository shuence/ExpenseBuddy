
import 'package:expensebuddy/ui/screens/error/no_route_found_screen.dart';
import 'package:expensebuddy/ui/screens/onboarding/user_preferences_screen.dart';
import 'package:go_router/go_router.dart';
import '../ui/screens/splash_screen.dart';
import '../ui/screens/onboarding/onboarding_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/email_auth_screen.dart';
import '../ui/screens/auth/forgot_password_screen.dart';
import '../ui/screens/expenses/expense_list_screen.dart';
import '../ui/screens/summary/summary_screen.dart';
import 'routes.dart';
import '../ui/screens/main/home_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.userPreferences,
        builder: (context, state) => const UserPreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailAuth,
        builder: (context, state) {
          final isSignUp = state.extra as bool? ?? false;
          return EmailAuthScreen(initialSignUpMode: isSignUp);
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.expenses,
        builder: (context, state) => const ExpenseListScreen(),
      ),
      GoRoute(
        path: AppRoutes.summary,
        builder: (context, state) => const SummaryScreen(),
      ),
    ],
    errorBuilder: (context, state) => const NoRouteFoundScreen(),
  );
}
