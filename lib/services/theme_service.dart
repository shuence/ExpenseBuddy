import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';

  static final ThemeService instance = ThemeService._internal();

  final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);

  ThemeService._internal();

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    isDarkModeNotifier.value = isDark;
  }

  CupertinoThemeData get currentTheme => isDarkModeNotifier.value
      ? AppTheme.darkTheme
      : AppTheme.lightTheme;

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !isDarkModeNotifier.value;
    isDarkModeNotifier.value = newValue;
    await prefs.setBool(_themeKey, newValue);
  }
}


