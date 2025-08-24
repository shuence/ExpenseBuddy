import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local/database.dart';
import '../data/local/expense_dao.dart';
import '../data/remote/auth_service.dart';
import '../data/remote/firestore_service.dart';
import '../data/repositories/expense_repository.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/onboarding_provider.dart';
import '../services/currency_service.dart';
import '../services/sync_service.dart';
import '../services/notification_service.dart';
import '../services/firebase_service.dart';
import '../services/firebase_messaging_service.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  
  // Services
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<FirestoreService>(() => FirestoreService());
  getIt.registerLazySingleton<CurrencyService>(() => CurrencyService());
  getIt.registerLazySingleton<SyncService>(() => SyncService(getIt<ExpenseRepository>()));
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
  getIt.registerLazySingleton<FirebaseMessagingService>(() => FirebaseMessagingService());
  
  // Database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  getIt.registerLazySingleton<ExpenseDao>(() => ExpenseDao());
  
  // Repositories
  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepository(getIt<ExpenseDao>(), getIt<FirestoreService>()),
  );
  
  // BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthService>()));
  getIt.registerFactory<ExpenseBloc>(() => ExpenseBloc(getIt<ExpenseRepository>()));
  getIt.registerFactory<CurrencyBloc>(() => CurrencyBloc(getIt<CurrencyService>()));
  getIt.registerFactory<ThemeBloc>(() => ThemeBloc(getIt<SharedPreferences>()));
  getIt.registerFactory<OnboardingBloc>(() => OnboardingBloc(getIt<SharedPreferences>()));
  
  // Initialize notification service
  await NotificationService.initialize();
}
