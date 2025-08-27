import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class SharedPrefsService {
  static const String _userKey = 'user_data';
  static const String _authTokenKey = 'auth_token';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _themeKey = 'theme_mode';
  static const String _currencyKey = 'currency';
  static const String _biometricEnabledKey = 'biometric_enabled';
  
  static SharedPrefsService? _instance;
  static SharedPreferences? _prefs;
  
  SharedPrefsService._();
  
  static Future<SharedPrefsService> getInstance() async {
    if (_instance == null) {
      _prefs = await SharedPreferences.getInstance();
      _instance = SharedPrefsService._();
    }
    return _instance!;
  }
  
  // User data
  Future<void> saveUser(UserModel user) async {
    await _prefs!.setString(_userKey, jsonEncode(user.toJson()));
  }
  
  UserModel? getUser() {
    final userString = _prefs!.getString(_userKey);
    if (userString != null) {
      try {
        return UserModel.fromJson(jsonDecode(userString));
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  Future<void> removeUser() async {
    await _prefs!.remove(_userKey);
  }
  
  // Auth token
  Future<void> saveAuthToken(String token) async {
    await _prefs!.setString(_authTokenKey, token);
  }
  
  String? getAuthToken() {
    return _prefs!.getString(_authTokenKey);
  }
  
  Future<void> removeAuthToken() async {
    await _prefs!.remove(_authTokenKey);
  }
  
  // First launch
  Future<void> setFirstLaunch(bool isFirst) async {
    await _prefs!.setBool(_isFirstLaunchKey, isFirst);
  }
  
  bool isFirstLaunch() {
    return _prefs!.getBool(_isFirstLaunchKey) ?? true;
  }
  
  // Theme
  Future<void> saveTheme(String theme) async {
    await _prefs!.setString(_themeKey, theme);
  }
  
  String getTheme() {
    return _prefs!.getString(_themeKey) ?? 'system';
  }
  
  // Currency
  Future<void> saveCurrency(String currency) async {
    await _prefs!.setString(_currencyKey, currency);
  }
  
  String getCurrency() {
    return _prefs!.getString(_currencyKey) ?? 'USD';
  }
  
  // Biometric
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs!.setBool(_biometricEnabledKey, enabled);
  }
  
  bool isBiometricEnabled() {
    return _prefs!.getBool(_biometricEnabledKey) ?? false;
  }
  
  // Clear all data
  Future<void> clearAll() async {
    await _prefs!.clear();
  }
  
  // Clear user data specifically
  Future<void> clearUserData() async {
    await _prefs!.remove(_userKey);
    await _prefs!.remove(_authTokenKey);
  }
  
  // Check if user is logged in
  bool isLoggedIn() {
    return getUser() != null && getAuthToken() != null;
  }
}
