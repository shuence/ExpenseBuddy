import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:convert';
import '../data/remote/auth_service.dart';
import 'sync_service.dart';
/// UserService provides user data management with intelligent caching strategy.
/// 
/// Caching Strategy:
/// 1. Check SharedPreferences first (fastest, local storage)
/// 2. If cache is invalid or empty, fetch from Firebase
/// 3. Save Firebase data to SharedPreferences for future use
/// 4. Cache expires after 1 hour to ensure data freshness
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final AuthService _authService = AuthService();
  
  // Cache validity duration (1 hour)
  static const Duration _cacheValidityDuration = Duration(hours: 1);
  static const String _lastFetchKey = 'user_last_fetch_time';

  // Check if cached user data is still valid
  Future<bool> _isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetchTime = prefs.getString(_lastFetchKey);
      
      if (lastFetchTime == null) return false;
      
      final lastFetch = DateTime.parse(lastFetchTime);
      final now = DateTime.now();
      
      return now.difference(lastFetch) < _cacheValidityDuration;
    } catch (e) {
      debugPrint('Error checking cache validity: $e');
      return false;
    }
  }

  // Update cache timestamp
  Future<void> _updateCacheTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastFetchKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error updating cache timestamp: $e');
    }
  }

  // Get current user with smart caching strategy
  Future<UserModel?> getCurrentUser({bool forceRefresh = false}) async {
    try {
      // If force refresh requested, skip cache and fetch from Firebase
      if (forceRefresh) {
        return await refreshUserFromFirebase();
      }

      // First check shared preferences (local storage) - fastest
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      
      // Try to parse user data, if it fails due to old format, clear cache
      UserModel? user;
      try {
        user = userJson != null ? UserModel.fromJson(jsonDecode(userJson)) : null;
      } catch (e) {
        // If parsing fails, clear the cached data and fetch fresh
        debugPrint('Error parsing cached user data, clearing cache: $e');
        await prefs.remove('user_data');
        user = null;
      }

      // If user exists in cache and cache is valid, return cached user
      if (user != null && await _isCacheValid()) {
        return user;
      }
      
      // If cache is invalid or user doesn't exist, fetch from Firebase
      user = await _authService.getUserModel();
      
      if (user != null) {
        // Save to shared preferences and update timestamp
        await prefs.setString('user_data', jsonEncode(user.toJson()));
        await _updateCacheTimestamp();
        return user;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  // Get user display name (first name or full name)
  String getUserDisplayName(UserModel? user) {
    if (user == null || user.displayName.isEmpty) {
      return 'User';
    }
    
    // Try to get first name from display name
    final nameParts = user.displayName.trim().split(' ');
    return nameParts.isNotEmpty ? nameParts.first : 'User';
  }

  // Get user initials for avatar
  String getUserInitials(UserModel? user) {
    if (user == null || user.displayName.isEmpty) {
      return 'U';
    }

    final nameParts = user.displayName.trim().split(' ');
    if (nameParts.isEmpty) {
      return 'U';
    }

    if (nameParts.length == 1) {
      // If only one name, take first two characters
      return nameParts[0].length >= 2 
          ? nameParts[0].substring(0, 2).toUpperCase()
          : nameParts[0].substring(0, 1).toUpperCase();
    }

    // If multiple names, take first character of first and last name
    return '${nameParts.first.substring(0, 1)}${nameParts.last.substring(0, 1)}'.toUpperCase();
  }

  // Get greeting based on time of day
  String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  // Get user profile image URL (if available)
  String? getUserProfileImageUrl(UserModel? user) {
    if (user == null) return null;
    
    // Check if user has a profile image URL
    // This would depend on your user model structure
    // For now, returning null as the current model doesn't seem to have photoURL
    return user.photoURL;
  }

  // Refresh user data from Firebase and update local cache
  Future<UserModel?> refreshUserFromFirebase() async {
    try {
      // Force fetch from Firebase
      final user = await _authService.getUserModel();
      
      if (user != null) {
        // Update shared preferences with fresh data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(user.toJson()));
        // Update cache timestamp
        await _updateCacheTimestamp();
        return user;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error refreshing user from Firebase: $e');
      return null;
    }
  }

  // Clear user cache (useful for logout or switching users)
  Future<void> clearUserCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      await prefs.remove(_lastFetchKey);
    } catch (e) {
      debugPrint('Error clearing user cache: $e');
    }
  }

  // Update user profile information
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) return false;

      // Update the user profile in Firebase Auth
      if (displayName != null) {
        await currentUser.updateDisplayName(displayName);
      }
      
      if (photoURL != null) {
        await currentUser.updatePhotoURL(photoURL);
      }

      // Reload the user to get updated information
      await currentUser.reload();
      
      // Refresh local cache with updated data
      await refreshUserFromFirebase();
      
      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  // Check if user has completed their profile setup
  bool isProfileComplete(UserModel? user) {
    if (user == null) return false;
    
    return user.displayName.isNotEmpty && user.email.isNotEmpty;
  }

  // Trigger sync when user logs in
  Future<void> triggerUserLoginSync(String userId) async {
    try {
      print('User logged in - triggering sync for user: $userId');
      final syncService = SyncService();
      
      // Fetch all Firebase data for this user to local DB
      await syncService.fetchFirebaseData();
      
      print('User login sync completed for user: $userId');
    } catch (e) {
      print('Failed to trigger user login sync: $e');
    }
  }
}
