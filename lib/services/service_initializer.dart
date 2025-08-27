import 'package:firebase_core/firebase_core.dart';
import 'sync_service.dart';
import 'connectivity_service.dart';

class ServiceInitializer {
  static final ServiceInitializer _instance = ServiceInitializer._internal();
  factory ServiceInitializer() => _instance;
  ServiceInitializer._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase first
      await Firebase.initializeApp();

      // Initialize connectivity service
      await ConnectivityService().initialize();

      // Initialize sync services
      final syncService = SyncService();
      await syncService.initialize();

      // Note: TimerBackgroundSyncService is initialized in main() for proper setup

      _isInitialized = true;
      print('All services initialized successfully');
    } catch (e) {
      print('Failed to initialize services: $e');
      // Continue app startup even if some services fail
    }
  }

  bool get isInitialized => _isInitialized;
}
