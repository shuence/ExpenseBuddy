import 'package:flutter/cupertino.dart';

class AppTheme {
  // Light Mode Colors
  static const Color lightPrimary = Color(0xFF2ECC71);     // Emerald Green
  static const Color lightSecondary = Color(0xFF2C3E50);   // Navy Blue
  static const Color lightAccent = Color(0xFFF1C40F);      // Yellow
  static const Color lightBackground = Color(0xFFF8F9FA);  // Light Gray
  static const Color lightSurface = Color(0xFFFFFFFF);      // White
  static const Color lightTextPrimary = Color(0xFF2D3436); // Dark Gray
  static const Color lightTextSecondary = Color(0xFF636E72); // Muted Gray

  // Dark Mode Colors
  static const Color darkPrimary = Color(0xFF27AE60);      // Darker Emerald Green
  static const Color darkSecondary = Color(0xFF34495E);    // Slate Blue
  static const Color darkAccent = Color(0xFFF39C12);       // Golden Yellow
  static const Color darkBackground = Color(0xFF121212);   // Dark Charcoal
  static const Color darkSurface = Color(0xFF1E1E1E);     // Dark Gray
  static const Color darkTextPrimary = Color(0xFFECF0F1); // White
  static const Color darkTextSecondary = Color(0xFFBDC3C7); // Gray

  // Common Colors
  static const Color errorColor = Color(0xFFE74C3C);

  // Light Theme
  static CupertinoThemeData get lightTheme {
    return const CupertinoThemeData(
      primaryColor: lightPrimary,
      scaffoldBackgroundColor: lightBackground,
      barBackgroundColor: lightSurface,
      primaryContrastingColor: lightTextPrimary,
      brightness: Brightness.light,
    );
  }

  // Dark Theme
  static CupertinoThemeData get darkTheme {
    return const CupertinoThemeData(
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBackground,
      barBackgroundColor: darkSurface,
      primaryContrastingColor: darkTextPrimary,
      brightness: Brightness.dark,
    );
  }

  // Default theme (can be used for backward compatibility)
  static CupertinoThemeData get cupertinoTheme => lightTheme;

  // Helper methods to get colors based on brightness
  static Color getPrimaryColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkPrimary : lightPrimary;
  }

  static Color getSecondaryColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkSecondary : lightSecondary;
  }

  static Color getAccentColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkAccent : lightAccent;
  }

  static Color getBackgroundColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkBackground : lightBackground;
  }

  static Color getSurfaceColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkSurface : lightSurface;
  }

  static Color getTextPrimaryColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;
  }

  static Color getTextSecondaryColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  }

  static Color getBorderColor(Brightness brightness) {
    return brightness == Brightness.dark ? darkTextSecondary.withOpacity(0.3) : lightTextSecondary.withOpacity(0.3);
  }
}
