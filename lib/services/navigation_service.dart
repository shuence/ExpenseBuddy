import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../router/routes.dart';
import '../models/user_model.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static const String _userKey = 'user_data';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _preferencesKey = 'preferences_setup';

  // Save user data to shared preferences
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Get user data from shared preferences
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Clear user data from shared preferences
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_preferencesKey);
  }

  // Mark onboarding as completed
  Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  // Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  // Mark preferences as setup
  Future<void> markPreferencesSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_preferencesKey, true);
  }

  // Check if preferences are setup
  Future<bool> arePreferencesSetup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_preferencesKey) ?? false;
  }

  // Centralized navigation logic
  Future<void> navigateBasedOnUserState(BuildContext context) async {
    try {
      final user = await getUser();
      final onboardingCompleted = await isOnboardingCompleted();
      final preferencesSetup = await arePreferencesSetup();

      if (user != null) {
        // User is authenticated
        if (preferencesSetup) {
          // User has preferences, go to main app
          context.go(AppRoutes.expenses);
        } else {
          // User needs to set preferences
          context.go(AppRoutes.userPreferences);
        }
      } else if (onboardingCompleted) {
        // User has seen onboarding but not authenticated
        context.go(AppRoutes.login);
      } else {
        // First time user, show onboarding
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      // Fallback to onboarding if navigation fails
      context.go(AppRoutes.onboarding);
    }
  }

  // Handle successful authentication
  Future<void> handleSuccessfulAuth(BuildContext context, UserModel user, {bool hasPreferences = false}) async {
    await saveUser(user);
    
    if (hasPreferences) {
      await markPreferencesSetup();
      context.go(AppRoutes.expenses);
    } else {
      context.go(AppRoutes.userPreferences);
    }
  }

  // Handle preferences completion
  Future<void> handlePreferencesComplete(BuildContext context) async {
    await markPreferencesSetup();
    context.go(AppRoutes.expenses);
  }

  // Handle logout
  Future<void> handleLogout(BuildContext context) async {
    await clearUser();
    context.go(AppRoutes.onboarding);
  }

  // Navigate to email auth
  void navigateToEmailAuth(BuildContext context, {bool isSignUp = false}) {
    context.go(AppRoutes.emailAuth, extra: isSignUp);
  }

  // Navigate to forgot password
  void navigateToForgotPassword(BuildContext context) {
    context.go(AppRoutes.forgotPassword);
  }

  // Check if user is authenticated and handle accordingly
  Future<void> checkAuthenticationAndNavigate(BuildContext context) async {
    try {
      // First check local storage
      final user = await getUser();
      final onboardingCompleted = await isOnboardingCompleted();
      
      if (user != null) {
        // User exists in local storage, check if they have preferences
        final preferencesSetup = await arePreferencesSetup();
        if (preferencesSetup) {
          context.go(AppRoutes.expenses);
        } else {
          context.go(AppRoutes.userPreferences);
        }
      } else if (onboardingCompleted) {
        // User has seen onboarding but not authenticated
        context.go(AppRoutes.login);
      } else {
        // First time user
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      debugPrint('Authentication check error: $e');
      // Log the full error for debugging
      if (e is NoSuchMethodError) {
        debugPrint('NoSuchMethodError details: ${e.toString()}');
      }
      // Fallback to onboarding
      context.go(AppRoutes.onboarding);
    }
  }

  // Emergency fallback navigation when AuthBloc is not available
  void emergencyNavigate(BuildContext context) {
    try {
      // Try to navigate based on local storage only
      _navigateBasedOnLocalStorage(context);
    } catch (e) {
      debugPrint('Emergency navigation failed: $e');
      // Last resort: go to onboarding
      context.go(AppRoutes.onboarding);
    }
  }

  // Navigate based only on local storage (no AuthBloc dependency)
  void _navigateBasedOnLocalStorage(BuildContext context) async {
    try {
      final user = await getUser();
      final onboardingCompleted = await isOnboardingCompleted();
      final preferencesSetup = await arePreferencesSetup();
      
      if (user != null && preferencesSetup) {
        context.go(AppRoutes.expenses);
      } else if (user != null && !preferencesSetup) {
        context.go(AppRoutes.userPreferences);
      } else if (onboardingCompleted) {
        context.go(AppRoutes.login);
      } else {
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      debugPrint('Local storage navigation failed: $e');
      context.go(AppRoutes.onboarding);
    }
  }
}
