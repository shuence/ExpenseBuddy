import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/constants/app_constants.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(initSettings);
    
    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      AppConstants.reminderChannelId,
      AppConstants.reminderChannelName,
      description: AppConstants.reminderChannelDescription,
      importance: Importance.high,
    );
    
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel); 
  }
  
  static Future<void> showExpenseReminder({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.reminderChannelId,
      AppConstants.reminderChannelName,
      channelDescription: AppConstants.reminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(id, title, body, details);
  }
  
  static Future<void> scheduleExpenseReminder({
    required String title,
    required String body,
    required DateTime scheduledDate,
    int id = 0,
  }) async {
    // Since we removed timezone support, just show the notification immediately
    await showExpenseReminder(title: title, body: body, id: id);
  }
}
