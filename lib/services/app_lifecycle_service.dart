import 'package:flutter/foundation.dart';
import '../di/injection.dart';
import '../providers/auth_provider.dart';
import 'dependency_validator.dart';

class AppLifecycleService {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  bool _isInitialized = false;
  bool _isResumed = false;

  // Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Ensure dependencies are configured
      await _ensureDependencies();
      _isInitialized = true;
      debugPrint('AppLifecycleService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing AppLifecycleService: $e');
      // Continue anyway
    }
  }

  // Ensure all dependencies are properly configured
  Future<void> _ensureDependencies() async {
    try {
      // Use dependency validator for comprehensive checking
      final validator = DependencyValidator();
      final isValid = await validator.validateAllDependencies();
      
      if (!isValid) {
        debugPrint('❌ Dependencies validation failed');
        debugPrint('Missing dependencies: ${validator.missingDependencies}');
        
        // Try to reconfigure dependencies
        await configureDependencies();
        
        // Revalidate after reconfiguration
        final revalidationResult = await validator.revalidate();
        if (!revalidationResult) {
          throw Exception('Failed to revalidate dependencies after reconfiguration');
        }
      }
      
      debugPrint('✅ All dependencies are properly configured');
      
    } catch (e) {
      debugPrint('❌ Dependency check failed: $e');
      // Try to reconfigure dependencies as last resort
      try {
        await configureDependencies();
        debugPrint('🔄 Dependencies reconfigured');
      } catch (reconfigError) {
        debugPrint('❌ Failed to reconfigure dependencies: $reconfigError');
        throw Exception('Critical: Cannot configure dependencies: $reconfigError');
      }
    }
  }

  // Handle app resume
  Future<void> onAppResumed() async {
    if (!_isResumed) {
      _isResumed = true;
      debugPrint('App resumed');
      
      try {
        // Ensure dependencies are still available
        await _ensureDependencies();
        
        // Check if user session is still valid
        await _validateUserSession();
        
      } catch (e) {
        debugPrint('Error handling app resume: $e');
      }
    }
  }

  // Handle app pause
  void onAppPaused() {
    _isResumed = false;
    debugPrint('App paused');
  }

  // Validate user session
  Future<void> _validateUserSession() async {
    try {
      final authBloc = getIt<AuthBloc>();
      // Trigger auth check to ensure user is still authenticated
      authBloc.add(AuthCheckRequested());
    } catch (e) {
      debugPrint('Error validating user session: $e');
    }
  }

  // Check if service is ready
  bool get isReady => _isInitialized;

  // Force reinitialization
  Future<void> reinitialize() async {
    _isInitialized = false;
    await initialize();
  }
}
