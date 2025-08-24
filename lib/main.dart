import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'di/injection.dart';
import 'services/firebase_messaging_service.dart';
import 'services/dependency_validator.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Firebase Messaging
    await FirebaseMessagingService().initialize();
    
    await configureDependencies();
    debugPrint('Dependencies configured successfully');
    
    // Validate all dependencies using the validator
    try {
      final validator = DependencyValidator();
      final isValid = await validator.validateAllDependencies();
      
      if (isValid) {
        debugPrint('✅ All dependencies validated successfully');
        debugPrint('📊 Validation status: ${validator.validationStatus}');
      } else {
        debugPrint('❌ Some dependencies failed validation');
        debugPrint('Missing: ${validator.missingDependencies}');
        
        // Try to fix missing dependencies
        await _fixMissingDependencies(validator);
      }
    } catch (e) {
      debugPrint('❌ Dependency validation failed: $e');
      // Continue anyway, the app will handle this gracefully
    }
    
    runApp(const ExpenseBuddyApp());
  } catch (e) {
    debugPrint('Error during app initialization: $e');
    // Fallback: run app without Firebase if initialization fails
    try {
      await configureDependencies();
      runApp(const ExpenseBuddyApp());
    } catch (e2) {
      debugPrint('Error during fallback initialization: $e2');
      // Last resort: run app with minimal setup
      runApp(const ExpenseBuddyApp());
    }
  }
}

// Helper function to fix missing dependencies
Future<void> _fixMissingDependencies(DependencyValidator validator) async {
  try {
    debugPrint('🔧 Attempting to fix missing dependencies...');
    
    // Reconfigure dependencies
    await configureDependencies();
    
    // Revalidate
    final fixed = await validator.revalidate();
    if (fixed) {
      debugPrint('✅ Dependencies fixed successfully');
    } else {
      debugPrint('❌ Failed to fix dependencies');
    }
  } catch (e) {
    debugPrint('❌ Error fixing dependencies: $e');
  }
}
