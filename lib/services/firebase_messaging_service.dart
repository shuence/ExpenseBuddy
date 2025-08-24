import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/firebase_service.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseInAppMessaging _inAppMessaging = FirebaseInAppMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseService _firebaseService = FirebaseService();

  String? _fcmToken;
  bool _isInitialized = false;

  // Get FCM token
  String? get fcmToken => _fcmToken;

  // Initialize the messaging service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission for iOS
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        
        // Listen for token refresh
        _messaging.onTokenRefresh.listen((token) {
          _fcmToken = token;
          _updateFcmTokenInFirestore(token);
        });

        // Initialize local notifications
        await _initializeLocalNotifications();

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle notification taps when app is in background
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // Check if app was opened from notification
        RemoteMessage? initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }

        // Enable in-app messaging
        // Note: setMessagesDisplaySuppressed is deprecated in newer versions
        // await _inAppMessaging.setMessagesDisplaySuppressed(false);

        _isInitialized = true;
        
        if (kDebugMode) {
          print('Firebase Messaging Service initialized successfully');
          print('FCM Token: $_fcmToken');
        }
      } else {
        if (kDebugMode) {
          print('Notification permission denied: ${settings.authorizationStatus}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firebase Messaging: $e');
      }
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message received: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    // Show local notification
    _showLocalNotification(message);
  }

  // Handle notification taps
  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification tapped: ${message.messageId}');
      print('Data: ${message.data}');
    }

    // Handle navigation based on message data
    _handleMessageNavigation(message);
  }

  // Handle local notification taps
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('Local notification tapped: ${response.payload}');
    }

    // Handle navigation based on payload
    if (response.payload != null) {
      // Parse payload and navigate accordingly
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'expense_buddy_channel',
      'Expense Buddy Notifications',
      channelDescription: 'Notifications for expense tracking app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  // Handle message navigation
  void _handleMessageNavigation(RemoteMessage message) {
    // Extract navigation data from message
    final data = message.data;
    
    if (data.containsKey('route')) {
      final route = data['route'];
      
      // Navigate based on route
      switch (route) {
        case 'expense':
          // Navigate to expense details
          break;
        case 'summary':
          // Navigate to summary screen
          break;
        case 'settings':
          // Navigate to settings
          break;
        default:
          // Default navigation
          break;
      }
    }
  }

  // Update FCM token in Firestore
  Future<void> _updateFcmTokenInFirestore(String token) async {
    try {
      final user = _firebaseService.currentUser;
      if (user != null) {
        await _firebaseService.updateDocument(
          'users',
          user.uid,
          {'fcmToken': token, 'lastTokenUpdate': DateTime.now().toIso8601String()},
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating FCM token in Firestore: $e');
      }
    }
  }

  // Subscribe to topics
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic $topic: $e');
      }
    }
  }

  // Unsubscribe from topics
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic $topic: $e');
      }
    }
  }

  // Send custom notification to specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // This would typically be done through a Cloud Function
      // For now, we'll just log it
      if (kDebugMode) {
        print('Sending notification to user $userId:');
        print('Title: $title');
        print('Body: $body');
        print('Data: $data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending notification: $e');
      }
    }
  }

  // Get current FCM token
  Future<String?> getCurrentToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      return _fcmToken;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  // Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      if (kDebugMode) {
        print('FCM token deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting FCM token: $e');
      }
    }
  }

  // Enable/disable in-app messaging
  Future<void> setInAppMessagingEnabled(bool enabled) async {
    try {
      // Note: setMessagesDisplaySuppressed is deprecated in newer versions
      // await _inAppMessaging.setMessagesDisplaySuppressed(!enabled);
      if (kDebugMode) {
        print('In-app messaging ${enabled ? 'enabled' : 'disabled'}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting in-app messaging: $e');
      }
    }
  }

  // Trigger in-app message
  Future<void> triggerInAppMessage(String eventName) async {
    try {
      await _inAppMessaging.triggerEvent(eventName);
      if (kDebugMode) {
        print('In-app message triggered: $eventName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error triggering in-app message: $e');
      }
    }
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background message received: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }
}
