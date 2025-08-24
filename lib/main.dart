import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'di/injection.dart';
import 'services/firebase_messaging_service.dart';

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
    runApp(const ExpenseBuddyApp());
  } catch (e) {
    print('Error during app initialization: $e');
    // Fallback: run app without Firebase if initialization fails
    try {
      await configureDependencies();
      runApp(const ExpenseBuddyApp());
    } catch (e2) {
      print('Error during fallback initialization: $e2');
      // Last resort: run app with minimal setup
      runApp(const ExpenseBuddyApp());
    }
  }
}
