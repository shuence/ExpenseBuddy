import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/user_preferences_model.dart';

class UserPreferencesService {
  static final UserPreferencesService _instance = UserPreferencesService._internal();
  factory UserPreferencesService() => _instance;
  UserPreferencesService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection name for user preferences
  static const String _collection = 'user_preferences';

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user preferences exist
  Future<bool> preferencesExist(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get user preferences
  Future<UserPreferencesModel?> getUserPreferences(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserPreferencesModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create or update user preferences
  Future<void> saveUserPreferences(UserPreferencesModel preferences) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(preferences.userId)
          .set(preferences.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user preferences: $e');
    }
  }

  // Create initial preferences for new user
  Future<UserPreferencesModel> createInitialPreferences({
    required String userId,
    required String country,
    required String countryCode,
    required String defaultCurrency,
    double? latitude,
    double? longitude,
    String? city,
    String? state,
  }) async {
    final now = DateTime.now();
    final preferences = UserPreferencesModel(
      userId: userId,
      country: country,
      countryCode: countryCode,
      defaultCurrency: defaultCurrency,
      latitude: latitude,
      longitude: longitude,
      city: city,
      state: state,
      createdAt: now,
      updatedAt: now,
    );

    await saveUserPreferences(preferences);
    return preferences;
  }

  // Update specific preference fields
  Future<void> updatePreferences(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore
          .collection(_collection)
          .doc(userId)
          .update(updates);
      
      // If default currency is updated, also update SharedPreferences
      if (updates.containsKey('defaultCurrency')) {
        try {
          await saveDefaultCurrencyToPrefs(updates['defaultCurrency']);
          debugPrint('💾 Updated default currency in SharedPreferences: ${updates['defaultCurrency']}');
        } catch (e) {
          debugPrint('❌ Failed to update default currency in SharedPreferences: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }

  // Update permission status
  Future<void> updatePermissionStatus({
    required String userId,
    required String permission,
    required bool status,
  }) async {
    try {
      await updatePreferences(userId, {permission: status});
    } catch (e) {
      throw Exception('Failed to update permission status: $e');
    }
  }

  // Mark first time setup as complete
  Future<void> markSetupComplete(String userId) async {
    try {
      await updatePreferences(userId, {
        'isFirstTimeSetup': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to mark setup complete: $e');
    }
  }

  // Get default preferences based on user's location
  Future<UserPreferencesModel?> getDefaultPreferences(String userId) async {
    try {
      // Try to get user's current location and set default country/currency
      // For now, we'll use US as default
      final defaultCountry = Countries.findByCode('US')!;
      
      return createInitialPreferences(
        userId: userId,
        country: defaultCountry.name,
        countryCode: defaultCountry.code,
        defaultCurrency: defaultCountry.currencyCode,
        latitude: null,
        longitude: null,
        city: null,
        state: null,
      );
    } catch (e) {
      return null;
    }
  }

  // Stream user preferences for real-time updates
  Stream<UserPreferencesModel?> streamUserPreferences(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserPreferencesModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  // Delete user preferences (useful for account deletion)
  Future<void> deleteUserPreferences(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user preferences: $e');
    }
  }

  // Get all countries
  List<Country> getAllCountries() {
    return Countries.all;
  }

  // Find country by code
  Country? findCountryByCode(String code) {
    return Countries.findByCode(code);
  }

  // Find country by currency code
  Country? findCountryByCurrencyCode(String currencyCode) {
    return Countries.findByCurrencyCode(currencyCode);
  }

  // Validate preferences
  bool validatePreferences(UserPreferencesModel preferences) {
    return preferences.userId.isNotEmpty &&
           preferences.country.isNotEmpty &&
           preferences.countryCode.isNotEmpty &&
           preferences.defaultCurrency.isNotEmpty;
  }

  // Get setup completion percentage
  double getSetupCompletionPercentage(UserPreferencesModel preferences) {
    int completedSteps = 0;
    int totalSteps = 6; // country, currency, location, camera, storage, notifications

    if (preferences.country.isNotEmpty) completedSteps++;
    if (preferences.defaultCurrency.isNotEmpty) completedSteps++;
    if (preferences.locationPermission) completedSteps++;
    if (preferences.cameraPermission) completedSteps++;
    if (preferences.storagePermission) completedSteps++;
    if (preferences.notificationPermission) completedSteps++;

    return completedSteps / totalSteps;
  }

  // Check if setup is complete
  bool isSetupComplete(UserPreferencesModel preferences) {
    return !preferences.isFirstTimeSetup &&
           preferences.country.isNotEmpty &&
           preferences.defaultCurrency.isNotEmpty;
  }

  // Get user default currency (simple query)
  Future<String> getUserDefaultCurrency({String? userId}) async {
    try {
      final String userIdToUse = userId ?? currentUserId ?? '';
      if (userIdToUse.isEmpty) {
        return 'USD'; // Default fallback
      }

      final preferences = await getUserPreferences(userIdToUse);
      return preferences?.defaultCurrency ?? 'USD';
    } catch (e) {
      // Return default currency if anything fails
      return 'USD';
    }
  }

  // Save profile image URL to SharedPreferences
  Future<void> saveProfileImageUrl(String imageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_url', imageUrl);
    } catch (e) {
      throw Exception('Failed to save profile image URL: $e');
    }
  }

  // Get profile image URL from SharedPreferences
  Future<String?> getProfileImageUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('profile_image_url');
    } catch (e) {
      return null;
    }
  }

  // Save default currency to SharedPreferences
  Future<void> saveDefaultCurrencyToPrefs(String currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('default_currency', currency);
    } catch (e) {
      throw Exception('Failed to save default currency: $e');
    }
  }

  // Get default currency from SharedPreferences
  Future<String> getDefaultCurrencyFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('default_currency') ?? 'USD';
    } catch (e) {
      return 'USD';
    }
  }

  // Save user ID to SharedPreferences
  Future<void> saveUserIdToPrefs(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
    } catch (e) {
      throw Exception('Failed to save user ID: $e');
    }
  }

  // Get user ID from SharedPreferences
  Future<String?> getUserIdFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id');
    } catch (e) {
      return null;
    }
  }

  // Clear all SharedPreferences data
  Future<void> clearAllPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to clear preferences: $e');
    }
  }
}
