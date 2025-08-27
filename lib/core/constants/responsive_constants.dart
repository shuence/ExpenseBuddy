import 'package:flutter/cupertino.dart';

class ResponsiveConstants {
  // Screen Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Spacing Constants
  static const double spacing2 = 2.0;
  static const double spacing6 = 6.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;
  static const double spacing60 = 60.0;
  static const double spacing64 = 64.0;
  static const double spacing80 = 80.0;
  static const double spacing96 = 96.0;
  static const double spacing120 = 120.0;

  // Font Sizes
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize24 = 24.0;
  static const double fontSize28 = 28.0;
  static const double fontSize32 = 32.0;
  static const double fontSize36 = 36.0;
  static const double fontSize48 = 48.0;

  // Icon Sizes
  static const double iconSize16 = 16.0;
  static const double iconSize20 = 20.0;
  static const double iconSize24 = 24.0;
  static const double iconSize32 = 32.0;
  static const double iconSize40 = 40.0;
  static const double iconSize48 = 48.0;
  static const double iconSize64 = 64.0;
  static const double iconSize80 = 80.0;
  static const double iconSize120 = 120.0;

  // Border Radius
  static const double radius4 = 4.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;
  static const double radius32 = 32.0;
  static const double radius48 = 48.0;

  // Container Sizes
  static const double containerHeight48 = 48.0;
  static const double containerHeight56 = 56.0;
  static const double containerHeight64 = 64.0;
  static const double containerHeight80 = 80.0;
  static const double containerHeight120 = 120.0;
  static const double containerHeight200 = 200.0;
  static const double containerHeight280 = 280.0;
  static const double containerHeight312 = 312.0;
}

class ResponsiveHelper {
  static BuildContext? _context;
  
  static void init(BuildContext context) {
    _context = context;
  }

  static MediaQueryData get mediaQuery {
    if (_context == null) {
      throw Exception('ResponsiveHelper not initialized. Call ResponsiveHelper.init(context) first.');
    }
    return MediaQuery.of(_context!);
  }

  static double get screenWidth => mediaQuery.size.width;
  static double get screenHeight => mediaQuery.size.height;
  static double get statusBarHeight => mediaQuery.padding.top;
  static double get bottomPadding => mediaQuery.padding.bottom;
  static double get safeAreaHeight => screenHeight - statusBarHeight - bottomPadding;

  // Responsive breakpoints
  static bool get isMobile => screenWidth < ResponsiveConstants.mobileBreakpoint;
  static bool get isTablet => screenWidth >= ResponsiveConstants.mobileBreakpoint && screenWidth < ResponsiveConstants.tabletBreakpoint;
  static bool get isDesktop => screenWidth >= ResponsiveConstants.desktopBreakpoint;

  // Responsive sizing helpers
  static double getResponsiveWidth(double mobile, double tablet, double desktop) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  static double getResponsiveHeight(double mobile, double tablet, double desktop) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  static double getResponsiveFontSize(double mobile, double tablet, double desktop) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  static double getResponsiveSpacing(double mobile, double tablet, double desktop) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  // Percentage helpers
  static double getWidthPercentage(double percentage) => screenWidth * (percentage / 100);
  static double getHeightPercentage(double percentage) => screenHeight * (percentage / 100);

  // Aspect ratio helpers
  static double getAspectRatio(double width, double height) => width / height;
  
  // Orientation helpers
  static bool get isPortrait => screenHeight > screenWidth;
  static bool get isLandscape => screenWidth > screenHeight;
}

// Extension methods for easier usage
extension ResponsiveExtension on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  double get statusBarHeight => mediaQuery.padding.top;
  double get bottomPadding => mediaQuery.padding.bottom;
  double get safeAreaHeight => screenHeight - statusBarHeight - bottomPadding;
  
  bool get isMobile => screenWidth < ResponsiveConstants.mobileBreakpoint;
  bool get isTablet => screenWidth >= ResponsiveConstants.mobileBreakpoint && screenWidth < ResponsiveConstants.tabletBreakpoint;
  bool get isDesktop => screenWidth >= ResponsiveConstants.desktopBreakpoint;
  bool get isPortrait => screenHeight > screenWidth;
  bool get isLandscape => screenWidth > screenHeight;
}
