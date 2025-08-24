import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/injection.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/currency_provider.dart';
import '../blocs/user_preferences_bloc.dart';
import '../data/remote/auth_service.dart';
import '../data/repositories/expense_repository.dart';

class DependencyValidator {
  static final DependencyValidator _instance = DependencyValidator._internal();
  factory DependencyValidator() => _instance;
  DependencyValidator._internal();

  bool _isValidated = false;
  final Map<String, bool> _dependencyStatus = {};

  // Validate all critical dependencies
  Future<bool> validateAllDependencies() async {
    if (_isValidated) return true;

    try {
      debugPrint('🔍 Starting dependency validation...');
      
      // Validate core services
      await _validateCoreServices();
      
      // Validate BLoCs
      await _validateBLoCs();
      
      // Validate repositories
      await _validateRepositories();
      
      _isValidated = true;
      debugPrint('✅ All dependencies validated successfully');
      return true;
      
    } catch (e) {
      debugPrint('❌ Dependency validation failed: $e');
      return false;
    }
  }

  // Validate core services
  Future<void> _validateCoreServices() async {
    try {
      // AuthService
      final authService = getIt<AuthService>();
      _dependencyStatus['AuthService'] = authService != null;
      debugPrint('✅ AuthService: ${authService.hashCode}');
      
      // SharedPreferences
      final prefs = getIt<SharedPreferences>();
      _dependencyStatus['SharedPreferences'] = prefs != null;
      debugPrint('✅ SharedPreferences: ${prefs.hashCode}');
      
    } catch (e) {
      debugPrint('❌ Core services validation failed: $e');
      throw Exception('Core services validation failed: $e');
    }
  }

  // Validate BLoCs
  Future<void> _validateBLoCs() async {
    try {
      // AuthBloc
      final authBloc = getIt<AuthBloc>();
      _dependencyStatus['AuthBloc'] = authBloc != null;
      debugPrint('✅ AuthBloc: ${authBloc.hashCode}');
      
      // ExpenseBloc
      final expenseBloc = getIt<ExpenseBloc>();
      _dependencyStatus['ExpenseBloc'] = expenseBloc != null;
      debugPrint('✅ ExpenseBloc: ${expenseBloc.hashCode}');
      
      // ThemeBloc
      final themeBloc = getIt<ThemeBloc>();
      _dependencyStatus['ThemeBloc'] = themeBloc != null;
      debugPrint('✅ ThemeBloc: ${themeBloc.hashCode}');
      
      // OnboardingBloc
      final onboardingBloc = getIt<OnboardingBloc>();
      _dependencyStatus['OnboardingBloc'] = onboardingBloc != null;
      debugPrint('✅ OnboardingBloc: ${onboardingBloc.hashCode}');
      
      // CurrencyBloc
      final currencyBloc = getIt<CurrencyBloc>();
      _dependencyStatus['CurrencyBloc'] = currencyBloc != null;
      debugPrint('✅ CurrencyBloc: ${currencyBloc.hashCode}');
      
      // UserPreferencesBloc
      final userPrefsBloc = getIt<UserPreferencesBloc>();
      _dependencyStatus['UserPreferencesBloc'] = userPrefsBloc != null;
      debugPrint('✅ UserPreferencesBloc: ${userPrefsBloc.hashCode}');
      
    } catch (e) {
      debugPrint('❌ BLoCs validation failed: $e');
      throw Exception('BLoCs validation failed: $e');
    }
  }

  // Validate repositories
  Future<void> _validateRepositories() async {
    try {
      // ExpenseRepository
      final expenseRepo = getIt<ExpenseRepository>();
      _dependencyStatus['ExpenseRepository'] = expenseRepo != null;
      debugPrint('✅ ExpenseRepository: ${expenseRepo.hashCode}');
      
    } catch (e) {
      debugPrint('❌ Repositories validation failed: $e');
      throw Exception('Repositories validation failed: $e');
    }
  }

  // Check if a specific dependency is available
  bool isDependencyAvailable(String dependencyName) {
    return _dependencyStatus[dependencyName] ?? false;
  }

  // Get validation status
  Map<String, bool> get validationStatus => Map.unmodifiable(_dependencyStatus);

  // Force revalidation
  Future<bool> revalidate() async {
    _isValidated = false;
    _dependencyStatus.clear();
    return await validateAllDependencies();
  }

  // Check if all critical dependencies are available
  bool get areAllCriticalDependenciesAvailable {
    final criticalDeps = ['AuthBloc', 'SharedPreferences', 'AuthService'];
    return criticalDeps.every((dep) => _dependencyStatus[dep] ?? false);
  }

  // Get missing dependencies
  List<String> get missingDependencies {
    return _dependencyStatus.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }
}
