import 'package:flutter/cupertino.dart';

/// Comprehensive color constants for the ExpenseBuddy app
/// All colors are defined here as constants for consistency and maintainability
class AppColors {
  // Primary Brand Colors
  static const Color primary = AppColors.primary;      // Emerald Green
  static const Color primaryDark = AppColors.primaryDark;  // Darker Emerald
  static const Color primaryLight = AppColors.primaryLight; // Lighter Emerald
  
  // Secondary Brand Colors
  static const Color secondary = AppColors.secondary;    // Navy Blue
  static const Color secondaryDark = AppColors.secondaryDark; // Darker Navy
  static const Color secondaryLight = AppColors.secondaryLight; // Lighter Navy
  
  // Accent Colors
  static const Color accent = AppColors.chart10;       // Yellow
  static const Color accentDark = AppColors.accentDark;   // Golden Yellow
  static const Color accentLight = AppColors.accentLight;  // Light Yellow
  
  // Semantic Colors
  static const Color success = AppColors.primary;      // Green
  static const Color successDark = AppColors.primaryDark;  // Dark Green
  static const Color successLight = AppColors.primaryLight; // Light Green
  
  static const Color warning = AppColors.accentDark;      // Orange
  static const Color warningDark = AppColors.warningDark;  // Dark Orange
  static const Color warningLight = AppColors.accentLight; // Light Orange
  
  static const Color error = AppColors.error;        // Red
  static const Color errorDark = AppColors.errorDark;    // Dark Red
  static const Color errorLight = Color(0xFFEC7063);   // Light Red
  
  static const Color info = AppColors.info;         // Blue
  static const Color infoDark = AppColors.infoDark;     // Dark Blue
  static const Color infoLight = Color(0xFF5DADE2);    // Light Blue
  
  // Neutral Colors
  static const Color neutral50 = Color(0xFFFAFAFA);    // Very Light Gray
  static const Color neutral100 = Color(0xFFF5F5F5);   // Light Gray
  static const Color neutral200 = Color(0xFFEEEEEE);   // Gray
  static const Color neutral300 = AppColors.neutral300;   // Medium Gray
  static const Color neutral400 = AppColors.neutral400;   // Dark Gray
  static const Color neutral500 = AppColors.neutral500;   // Medium Dark Gray
  static const Color neutral600 = AppColors.neutral600;   // Dark Gray
  static const Color neutral700 = AppColors.neutral700;   // Very Dark Gray
  static const Color neutral800 = AppColors.neutral800;   // Almost Black
  static const Color neutral900 = AppColors.neutral900;   // Black
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F3F4);
  static const Color lightTextPrimary = Color(0xFF2D3436);
  static const Color lightTextSecondary = Color(0xFF636E72);
  static const Color lightTextTertiary = AppColors.chart9;
  static const Color lightBorder = AppColors.neutral300;
  static const Color lightDivider = Color(0xFFF0F0F0);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2D2D2D);
  static const Color darkTextPrimary = Color(0xFFECF0F1);
  static const Color darkTextSecondary = Color(0xFFBDC3C7);
  static const Color darkTextTertiary = AppColors.chart9;
  static const Color darkBorder = AppColors.neutral800;
  static const Color darkDivider = Color(0xFF2D2D2D);
  
  // Chart Colors (for data visualization)
  static const Color chart1 = AppColors.primary;  // Green
  static const Color chart2 = AppColors.info;  // Blue
  static const Color chart3 = AppColors.error;  // Red
  static const Color chart4 = AppColors.accentDark;  // Orange
  static const Color chart5 = AppColors.chart5;  // Purple
  static const Color chart6 = AppColors.chart6;  // Teal
  static const Color chart7 = AppColors.warningDark;  // Dark Orange
  static const Color chart8 = AppColors.secondaryLight;  // Dark Blue
  static const Color chart9 = AppColors.chart9;  // Gray
  static const Color chart10 = AppColors.chart10; // Yellow
  
  // Category Colors (for expense/income categories)
  static const Color categoryFood = AppColors.primary;      // Green
  static const Color categoryTransport = AppColors.info; // Blue
  static const Color categoryShopping = AppColors.chart5; // Purple
  static const Color categoryEntertainment = AppColors.accentDark; // Orange
  static const Color categoryHealthcare = AppColors.error;    // Red
  static const Color categoryEducation = AppColors.chart6;     // Teal
  static const Color categoryHousing = AppColors.secondaryLight;       // Dark Blue
  static const Color categoryUtilities = AppColors.chart9;     // Gray
  static const Color categoryInsurance = AppColors.chart10;     // Yellow
  static const Color categoryTravel = AppColors.warningDark;        // Dark Orange
  static const Color categoryGifts = AppColors.categoryGifts;         // Pink
  static const Color categoryOther = AppColors.categoryOther;         // Blue Gray
  
  // Transparent Colors
  static const Color transparent = Color(0x00000000);
  static const Color whiteTransparent = Color(0x80FFFFFF);
  static const Color blackTransparent = Color(0x80000000);
  
  // Gradient Colors
  static const List<Color> primaryGradient = [primary, primaryDark];
  static const List<Color> secondaryGradient = [secondary, secondaryDark];
  static const List<Color> successGradient = [success, successDark];
  static const List<Color> errorGradient = [error, errorDark];
  static const List<Color> warningGradient = [warning, warningDark];
  static const List<Color> infoGradient = [info, infoDark];
  
  // Helper method to get category color by name
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
        return categoryFood;
      case 'transportation':
        return categoryTransport;
      case 'shopping':
        return categoryShopping;
      case 'entertainment':
        return categoryEntertainment;
      case 'healthcare':
        return categoryHealthcare;
      case 'education':
        return categoryEducation;
      case 'housing':
        return categoryHousing;
      case 'utilities':
        return categoryUtilities;
      case 'insurance':
        return categoryInsurance;
      case 'travel':
        return categoryTravel;
      case 'gifts':
        return categoryGifts;
      default:
        return categoryOther;
    }
  }
  
  // Helper method to get chart color by index
  static Color getChartColor(int index) {
    final colors = [
      chart1, chart2, chart3, chart4, chart5,
      chart6, chart7, chart8, chart9, chart10
    ];
    return colors[index % colors.length];
  }
}