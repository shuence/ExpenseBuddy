
import 'package:expensebuddy/ui/screens/error/no_route_found_screen.dart';
import 'package:expensebuddy/ui/screens/onboarding/user_preferences_screen.dart';
import 'package:expensebuddy/ui/screens/profile/profile_screen.dart';
import 'package:go_router/go_router.dart';
import '../ui/screens/splash_screen.dart';
import '../ui/screens/onboarding/onboarding_screen.dart';
import '../ui/screens/onboarding/onboarding_page_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/email_auth_screen.dart';
import '../ui/screens/auth/forgot_password_screen.dart';
import '../ui/screens/transactions/add_transaction_screen.dart';
import '../ui/screens/transactions/transactions_list_screen.dart';
import '../ui/screens/transactions/transaction_details_screen.dart';
import '../ui/screens/budget/budget_screen.dart';
import '../models/transaction_model.dart';
import 'routes.dart';
import '../ui/screens/main/main_navigation_screen.dart';
import '../models/onboarding_model.dart';
import '../ui/screens/profile/pages/account_settings_screen.dart';
import '../ui/screens/profile/pages/currency_settings_screen.dart';
import '../ui/screens/profile/pages/notifications_settings_screen.dart';
// Removed backup sync screen import
import '../ui/screens/profile/pages/privacy_security_screen.dart';
import '../ui/screens/profile/pages/app_preferences_screen.dart';
import '../ui/screens/profile/pages/help_support_screen.dart';
import '../ui/screens/profile/pages/about_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const MainNavigationScreen(),
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
        path: AppRoutes.onboardingPage1,
        builder: (context, state) => OnboardingPageScreen(
          pageIndex: 0,
          page: OnboardingData.pages[0],
          isFirstPage: true,
          isLastPage: false,
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingPage2,
        builder: (context, state) => OnboardingPageScreen(
          pageIndex: 1,
          page: OnboardingData.pages[1],
          isFirstPage: false,
          isLastPage: false,
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingPage3,
        builder: (context, state) => OnboardingPageScreen(
          pageIndex: 2,
          page: OnboardingData.pages[2],
          isFirstPage: false,
          isLastPage: true,
        ),
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
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.addTransaction,
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: AppRoutes.transactions,
        builder: (context, state) => const TransactionsListScreen(),
      ),
      GoRoute(
        path: AppRoutes.transactionDetails,
        builder: (context, state) {
          final transaction = state.extra as TransactionModel;
          return TransactionDetailsScreen(transaction: transaction);
        },
      ),
      GoRoute(
        path: AppRoutes.budget,
        builder: (context, state) => const BudgetScreen(),
      ),
      // Settings Routes
      GoRoute(
        path: AppRoutes.accountSettings,
        builder: (context, state) => const AccountSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.currencySettings,
        builder: (context, state) => const CurrencySettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationsSettings,
        builder: (context, state) => const NotificationsSettingsScreen(),
      ),
              // Removed backup sync route
      GoRoute(
        path: AppRoutes.privacySecuritySettings,
        builder: (context, state) => const PrivacySecurityScreen(),
      ),
      GoRoute(
        path: AppRoutes.appPreferencesSettings,
        builder: (context, state) => const AppPreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpSupportSettings,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.aboutSettings,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
    errorBuilder: (context, state) => const NoRouteFoundScreen(),
  );
}
