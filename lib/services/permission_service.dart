import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // Request location permission and get current location
  Future<Map<String, dynamic>> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'granted': false,
          'error': 'Location services are disabled',
          'latitude': null,
          'longitude': null,
          'city': null,
          'state': null,
        };
      }

      // Check location permission status
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {
            'granted': false,
            'error': 'Location permission denied',
            'latitude': null,
            'longitude': null,
            'city': null,
            'state': null,
          };
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {
          'granted': false,
          'error': 'Location permissions are permanently denied',
          'latitude': null,
          'longitude': null,
          'city': null,
          'state': null,
        };
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String city = '';
      String state = '';

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        city = place.locality ?? place.subAdministrativeArea ?? '';
        state = place.administrativeArea ?? '';
      }

      return {
        'granted': true,
        'error': null,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'city': city,
        'state': state,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting location: $e');
      }
      return {
        'granted': false,
        'error': 'Failed to get location: $e',
        'latitude': null,
        'longitude': null,
        'city': null,
        'state': null,
      };
    }
  }

  // Request camera permission
  Future<bool> requestCameraPermission() async {
    try {
      PermissionStatus status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting camera permission: $e');
      }
      return false;
    }
  }

  // Request storage permission
  Future<bool> requestStoragePermission() async {
    try {
      PermissionStatus status = await Permission.storage.request();
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting storage permission: $e');
      }
      return false;
    }
  }

  // Request SMS permission
  Future<bool> requestSmsPermission() async {
    try {
      PermissionStatus status = await Permission.sms.request();
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting SMS permission: $e');
      }
      return false;
    }
  }

  // Request notification permission
  Future<bool> requestNotificationPermission() async {
    try {
      PermissionStatus status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting notification permission: $e');
      }
      return false;
    }
  }

  // Check if biometric is available and request permission
  Future<bool> requestBiometricPermission() async {
    try {
      // For now, we'll return true as biometric availability check
      // requires platform-specific implementation
      // In a real app, you'd check biometric availability here
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking biometric availability: $e');
      }
      return false;
    }
  }

  // Request all permissions at once
  Future<Map<String, bool>> requestAllPermissions() async {
    Map<String, bool> results = {};

    // Request permissions in parallel
    results['location'] = await requestLocationPermission().then((result) => result['granted'] as bool);
    results['camera'] = await requestCameraPermission();
    results['storage'] = await requestStoragePermission();
    results['sms'] = await requestSmsPermission();
    results['notification'] = await requestNotificationPermission();
    results['biometric'] = await requestBiometricPermission();

    return results;
  }

  // Check current permission status
  Future<Map<String, bool>> checkPermissionStatus() async {
    Map<String, bool> status = {};

    try {
      status['location'] = await Geolocator.checkPermission() != LocationPermission.denied;
      status['camera'] = await Permission.camera.isGranted;
      status['storage'] = await Permission.storage.isGranted;
      status['sms'] = await Permission.sms.isGranted;
      status['notification'] = await Permission.notification.isGranted;
      // Biometric status would need platform-specific implementation
      status['biometric'] = true; // Placeholder
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking permission status: $e');
      }
      // Set all to false if there's an error
      status = {
        'location': false,
        'camera': false,
        'storage': false,
        'sms': false,
        'notification': false,
        'biometric': false,
      };
    }

    return status;
  }

  // Open app settings if permissions are permanently denied
  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error opening app settings: $e');
      }
    }
  }
}
