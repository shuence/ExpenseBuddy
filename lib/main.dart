import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:workmanager/workmanager.dart';  // Temporarily disabled
import 'firebase_options.dart';
import 'app.dart';
import 'services/theme_service.dart';
import 'services/service_initializer.dart';
import 'services/timer_background_sync_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize shared preferences
    await SharedPreferences.getInstance();

    // Initialize theme service (loads persisted theme)
    await ThemeService.instance.initialize();
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Timer-based Background Sync Service
    try {
      await TimerBackgroundSyncService().initialize();
      debugPrint('Timer background sync service initialized successfully');
    } catch (e) {
      debugPrint('Timer background sync initialization failed: $e');
      // Continue without background sync for now
    }
    
    // Initialize other services (sync, etc.)
    await ServiceInitializer().initialize();
    
    runApp(const ExpenseBuddyApp());
  } catch (e) {
    debugPrint('Error during app initialization: $e');
    // Fallback: run app without Firebase if initialization fails
    runApp(const ExpenseBuddyApp());
  }
}
