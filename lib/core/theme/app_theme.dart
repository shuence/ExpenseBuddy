import 'package:flutter/cupertino.dart';
import '../constants/colors.dart';

/// Enhanced app theme using color constants
/// Provides consistent theming across the app
class AppTheme {
  // Light Theme
  static CupertinoThemeData get lightTheme {
    return const CupertinoThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      barBackgroundColor: AppColors.lightSurface,
      primaryContrastingColor: AppColors.lightTextPrimary,
      brightness: Brightness.light,
      // Additional theme properties
      textTheme: CupertinoTextThemeData(
        primaryColor: AppColors.lightTextPrimary,
        textStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 16,
        ),
        actionTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        tabLabelTextStyle: TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 12,
        ),
        navTitleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        navLargeTitleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 34,
          fontWeight: FontWeight.w700,
        ),
        pickerTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 16,
        ),
        dateTimePickerTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 16,
        ),
      ),
    );
  }

  // Dark Theme
  static CupertinoThemeData get darkTheme {
    return const CupertinoThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      barBackgroundColor: AppColors.darkSurface,
      primaryContrastingColor: AppColors.darkTextPrimary,
      brightness: Brightness.dark,
      // Additional theme properties
      textTheme: CupertinoTextThemeData(
        primaryColor: AppColors.darkTextPrimary,
        textStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 16,
        ),
        actionTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        tabLabelTextStyle: TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 12,
        ),
        navTitleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        navLargeTitleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 34,
          fontWeight: FontWeight.w700,
        ),
        pickerTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 16,
        ),
        dateTimePickerTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 16,
        ),
      ),
    );
  }

  // Default theme (can be used for backward compatibility)
  static CupertinoThemeData get cupertinoTheme => lightTheme;

  // Helper methods to get colors based on brightness
  static Color getPrimaryColor(Brightness brightness) {
    return brightness == Brightness.dark ? AppColors.primary : AppColors.primary;
  }

  static Color getSecondaryColor(Brightness brightness) {
    return brightness == Brightness.dark ? AppColors.secondary : AppColors.secondary;
  }

  static Color getAccentColor(Brightness brightness) {
    return brightness == Brightness.dark ? AppColors.accent : AppColors.accent;
  }

  static Color getBackgroundColor(Brightness brightness) {
    return brightness == Brightness.dark ? AppColors.darkBackground : AppColors.lightBackground;
  }

  static Color getSurfaceColor(Brightness brightness) {
    return brightness == Brightness.dark ? AppColors.darkSurface : AppColors.lightSurface;
  }

  static Color getTextPrimaryColor(Brightness brightness) {
    return brightness == Brightness.dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  }

  static Color getTextSecondaryColor(Brightness brightness) {
    return brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  }

  static Color getBorderColor(Brightness brightness) {
    return brightness == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder;
  }

  static Color getDividerColor(Brightness brightness) {
    return brightness == Brightness.dark ? AppColors.darkDivider : AppColors.lightDivider;
  }

  // Semantic color getters
  static Color getSuccessColor(Brightness brightness) {
    return AppColors.success;
  }

  static Color getWarningColor(Brightness brightness) {
    return AppColors.warning;
  }

  static Color getErrorColor(Brightness brightness) {
    return AppColors.error;
  }

  static Color getInfoColor(Brightness brightness) {
    return AppColors.info;
  }

  // Category color getters
  static Color getCategoryColor(String category, Brightness brightness) {
    return AppColors.getCategoryColor(category);
  }

  // Chart color getters
  static Color getChartColor(int index, Brightness brightness) {
    return AppColors.getChartColor(index);
  }
}
