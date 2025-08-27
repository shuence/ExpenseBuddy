import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'sync_service.dart';
import 'connectivity_service.dart';

class TimerBackgroundSyncService {
  static const String _lastSyncTimeKey = 'last_timer_background_sync_time';
  static const String _syncChannelId = 'expensebuddy_sync_channel';
  static const String _syncChannelName = 'ExpenseBuddy Sync';
  static const String _syncChannelDescription = 'Background sync notifications';
  
  static final TimerBackgroundSyncService _instance = TimerBackgroundSyncService._internal();
  factory TimerBackgroundSyncService() => _instance;
  TimerBackgroundSyncService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final ConnectivityService _connectivityService = ConnectivityService();
  Timer? _syncTimer;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize notifications
      await _initializeNotifications();
      
      // Start periodic sync timer
      _startPeriodicSync();
      
      // Listen to connectivity changes
      _connectivityService.connectionStatusStream.listen((status) {
        if (status == ConnectionStatus.connected) {
          _scheduleSync();
        }
      });

      _isInitialized = true;
      print('Timer background sync service initialized successfully');
    } catch (e) {
      print('Failed to initialize timer background sync: $e');
    }
  }

  Future<void> _initializeNotifications() async {
    // Initialize timezone
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      _syncChannelId,
      _syncChannelName,
      description: _syncChannelDescription,
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  void _startPeriodicSync() {
    // Cancel existing timer
    _syncTimer?.cancel();
    
    // Start new timer - sync every 30 minutes when app is active
    _syncTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      if (_connectivityService.isConnected) {
        _scheduleSync();
      }
    });
  }

  Future<void> _scheduleSync() async {
    try {
      final syncService = SyncService();
      await syncService.syncNow();
      
      // Update last sync time
      await setLastSyncTime(DateTime.now());
      
      print('Timer-based background sync completed successfully');
    } catch (e) {
      print('Timer-based background sync failed: $e');
    }
  }

  Future<void> scheduleSyncReminder() async {
    try {
      // Schedule a notification to remind user to sync
      await _notifications.zonedSchedule(
        1001, // Unique ID
        'ExpenseBuddy Sync',
        'Your expenses are ready to sync. Open the app to sync your data.',
        tz.TZDateTime.now(tz.local).add(const Duration(hours: 1)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _syncChannelId,
            _syncChannelName,
            channelDescription: _syncChannelDescription,
            importance: Importance.low,
            priority: Priority.low,
            showWhen: false,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
            presentSound: false,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Failed to schedule sync reminder: $e');
    }
  }

  Future<void> cancelSyncReminders() async {
    await _notifications.cancel(1001);
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncTimeKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  Future<void> setLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncTimeKey, time.millisecondsSinceEpoch);
  }

  Future<void> manualSync() async {
    await _scheduleSync();
  }

  void dispose() {
    _syncTimer?.cancel();
    _notifications.cancelAll();
  }
}
