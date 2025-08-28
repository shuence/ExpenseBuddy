import 'package:flutter/cupertino.dart';
import '../constants/colors.dart';

/// Theme extensions for easy access to theme colors and properties
/// Provides semantic color access and common theme operations
extension ThemeExtensions on BuildContext {
  /// Get theme brightness
  Brightness get themeBrightness => CupertinoTheme.brightnessOf(this);
  
  /// Check if dark mode is active
  bool get isDarkMode => themeBrightness == Brightness.dark;
  
  /// Get primary color
  Color get primaryColor => AppColors.primary;
  
  /// Get secondary color
  Color get secondaryColor => AppColors.secondary;
  
  /// Get accent color
  Color get accentColor => AppColors.accent;
  
  /// Get background color based on theme
  Color get backgroundColor => isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
  
  /// Get surface color based on theme
  Color get surfaceColor => isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
  
  /// Get surface variant color based on theme
  Color get surfaceVariantColor => isDarkMode ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
  
  /// Get primary text color based on theme
  Color get textPrimaryColor => isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  
  /// Get secondary text color based on theme
  Color get textSecondaryColor => isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  
  /// Get tertiary text color based on theme
  Color get textTertiaryColor => isDarkMode ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
  
  /// Get border color based on theme
  Color get borderColor => isDarkMode ? AppColors.darkBorder : AppColors.lightBorder;
  
  /// Get divider color based on theme
  Color get dividerColor => isDarkMode ? AppColors.darkDivider : AppColors.lightDivider;
  
  /// Get success color
  Color get successColor => AppColors.success;
  
  /// Get warning color
  Color get warningColor => AppColors.warning;
  
  /// Get error color
  Color get errorColor => AppColors.error;
  
  /// Get info color
  Color get infoColor => AppColors.info;
  
  /// Get neutral color by index (50-900)
  Color getNeutralColor(int index) {
    switch (index) {
      case 50: return AppColors.neutral50;
      case 100: return AppColors.neutral100;
      case 200: return AppColors.neutral200;
      case 300: return AppColors.neutral300;
      case 400: return AppColors.neutral400;
      case 500: return AppColors.neutral500;
      case 600: return AppColors.neutral600;
      case 700: return AppColors.neutral700;
      case 800: return AppColors.neutral800;
      case 900: return AppColors.neutral900;
      default: return AppColors.neutral500;
    }
  }
  
  /// Get category color
  Color getCategoryColor(String category) => AppColors.getCategoryColor(category);
  
  /// Get chart color by index
  Color getChartColor(int index) => AppColors.getChartColor(index);
  
  /// Get gradient colors
  List<Color> get primaryGradient => AppColors.primaryGradient;
  List<Color> get secondaryGradient => AppColors.secondaryGradient;
  List<Color> get successGradient => AppColors.successGradient;
  List<Color> get errorGradient => AppColors.errorGradient;
  List<Color> get warningGradient => AppColors.warningGradient;
  List<Color> get infoGradient => AppColors.infoGradient;
  
  /// Get color with opacity
  Color getColorWithOpacity(Color color, double opacity) => color.withOpacity(opacity);
  
  /// Get theme-aware shadow color
  Color get shadowColor => isDarkMode 
      ? AppColors.blackTransparent 
      : AppColors.blackTransparent;
  
  /// Get theme-aware card elevation
  double get cardElevation => isDarkMode ? 8.0 : 4.0;
  
  /// Get theme-aware border radius
  double get defaultBorderRadius => 12.0;
  
  /// Get theme-aware spacing
  double get defaultSpacing => 16.0;
  
  /// Get theme-aware icon size
  double get defaultIconSize => 24.0;
  
  /// Get theme-aware text scale factor
  double get textScaleFactor => MediaQuery.of(this).textScaleFactor;
  
  /// Get responsive font size
  double getResponsiveFontSize(double baseSize) {
    final scaleFactor = textScaleFactor;
    return baseSize * scaleFactor;
  }
  
  /// Get theme-aware button style
  ButtonStyle get primaryButtonStyle => ButtonStyle(
    backgroundColor: MaterialStateProperty.all(primaryColor),
    foregroundColor: MaterialStateProperty.all(CupertinoColors.white),
    padding: MaterialStateProperty.all(
      EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: 12),
    ),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
    ),
  );
  
  /// Get theme-aware input decoration
  InputDecoration get defaultInputDecoration => InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      borderSide: BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      borderSide: BorderSide(color: errorColor),
    ),
    filled: true,
    fillColor: surfaceColor,
    contentPadding: EdgeInsets.symmetric(
      horizontal: defaultSpacing,
      vertical: 12,
    ),
  );
}

/// Color utility extensions
extension ColorExtensions on Color {
  /// Get color with opacity
  Color withAlpha(int alpha) => withAlpha(alpha);
  
  /// Get lighter version of color
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
  
  /// Get darker version of color
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
  
  /// Get contrasting text color (black or white)
  Color get contrastingTextColor {
    final luminance = computeLuminance();
    return luminance > 0.5 ? AppColors.neutral900 : AppColors.neutral50;
  }
}