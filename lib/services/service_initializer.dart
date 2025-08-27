import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'sync_service.dart';

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
      debugPrint('✅ Firebase initialized successfully');

      // Initialize and start sync service
      debugPrint('🔄 Starting sync service initialization...');
      final syncService = SyncService();
      await syncService.initialize();
      debugPrint('✅ Sync service initialized successfully');

      _isInitialized = true;
      debugPrint('🎉 All services initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize services: $e');
      // Continue app startup even if some services fail
    }
  }

  bool get isInitialized => _isInitialized;
}
