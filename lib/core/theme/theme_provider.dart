import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

/// Theme provider for managing app theme state
/// Uses Provider pattern for state management
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeProvider() {
    _loadThemeMode();
  }
  
  /// Current theme mode
  ThemeMode get themeMode => _themeMode;
  
  /// Whether the app is in dark mode
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  /// Current theme data based on theme mode
  CupertinoThemeData get currentTheme {
    if (_themeMode == ThemeMode.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    }
    return _themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
  }
  
  /// Light theme
  CupertinoThemeData get lightTheme => AppTheme.lightTheme;
  
  /// Dark theme
  CupertinoThemeData get darkTheme => AppTheme.darkTheme;
  
  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      await _saveThemeMode();
    }
  }
  
  /// Toggle between light and dark themes
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
  
  /// Set system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
  
  /// Load theme mode from shared preferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    } catch (e) {
      // If loading fails, use system theme as default
      _themeMode = ThemeMode.system;
    }
  }
  
  /// Save theme mode to shared preferences
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _themeMode.index);
    } catch (e) {
      // Log error but don't throw
      debugPrint('Failed to save theme mode: $e');
    }
  }
}

/// Theme mode enum
enum ThemeMode {
  system,
  light,
  dark,
}

/// Extension methods for easy theme access
extension ThemeProviderExtension on BuildContext {
  /// Get theme provider
  ThemeProvider get themeProvider => Provider.of<ThemeProvider>(this, listen: false);
  
  /// Get current theme
  CupertinoThemeData get theme => themeProvider.currentTheme;
  
  /// Check if dark mode is active
  bool get isDarkMode => themeProvider.isDarkMode;
  
  /// Get brightness
  Brightness get brightness => theme.isDarkMode ? Brightness.dark : Brightness.light;
  
  /// Get primary color
  Color get primaryColor => theme.primaryColor;
  
  /// Get background color
  Color get backgroundColor => theme.scaffoldBackgroundColor;
  
  /// Get surface color
  Color get surfaceColor => theme.barBackgroundColor;
  
  /// Get text color
  Color get textColor => theme.primaryContrastingColor;
}