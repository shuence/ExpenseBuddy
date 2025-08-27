import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'services/theme_service.dart';

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
    
    // Theme already initialized above
    
    runApp(const ExpenseBuddyApp());
  } catch (e) {
    debugPrint('Error during app initialization: $e');
    // Fallback: run app without Firebase if initialization fails
    runApp(const ExpenseBuddyApp());
  }
}
