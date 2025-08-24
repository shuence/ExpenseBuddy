# Responsive System Documentation

## Overview

The ExpenseBuddy app includes a comprehensive responsive system that automatically adapts to different screen sizes, orientations, and device types. This system provides consistent spacing, sizing, and layout across all devices.

## Features

### 🎯 **Automatic Device Detection**
- **Mobile**: < 600px width
- **Tablet**: 600px - 900px width  
- **Desktop**: > 1200px width

### 📱 **Responsive Breakpoints**
```dart
static const double mobileBreakpoint = 600;
static const double tabletBreakpoint = 900;
static const double desktopBreakpoint = 1200;
```

### 🎨 **Consistent Design Tokens**
- **Spacing**: 4px to 120px in consistent increments
- **Font Sizes**: 12px to 48px
- **Icon Sizes**: 16px to 120px
- **Border Radius**: 4px to 48px
- **Container Heights**: Predefined common heights

## Usage Examples

### 1. **Basic Responsive Constants**

```dart
import 'package:your_app/core/constants/responsive_constants.dart';

// Spacing
SizedBox(height: ResponsiveConstants.spacing16);
SizedBox(height: ResponsiveConstants.spacing24);
SizedBox(height: ResponsiveConstants.spacing32);

// Font Sizes
Text(
  'Hello World',
  style: TextStyle(
    fontSize: ResponsiveConstants.fontSize18,
    fontWeight: FontWeight.w600,
  ),
);

// Icon Sizes
Icon(
  CupertinoIcons.star,
  size: ResponsiveConstants.iconSize24,
);

// Border Radius
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
  ),
);
```

### 2. **Context Extensions (Recommended)**

```dart
import 'package:your_app/core/constants/responsive_constants.dart';

@override
Widget build(BuildContext context) {
  return Column(
    children: [
      // Device type detection
      if (context.isMobile) 
        _buildMobileLayout()
      else if (context.isTablet)
        _buildTabletLayout()
      else
        _buildDesktopLayout(),
      
      // Screen dimensions
      Text('Width: ${context.screenWidth}px'),
      Text('Height: ${context.screenHeight}px'),
      Text('Orientation: ${context.isPortrait ? "Portrait" : "Landscape"}'),
      
      // Safe area
      Container(
        height: context.safeAreaHeight,
        child: YourWidget(),
      ),
    ],
  );
}
```

### 3. **Responsive Layout Patterns**

#### **Responsive Grid**
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: context.isMobile ? 1 : context.isTablet ? 2 : 3,
    crossAxisSpacing: ResponsiveConstants.spacing16,
    mainAxisSpacing: ResponsiveConstants.spacing16,
    childAspectRatio: context.isMobile ? 1.5 : 1.2,
  ),
  // ... rest of grid
);
```

#### **Responsive Cards**
```dart
Widget _buildResponsiveCards(BuildContext context) {
  if (context.isMobile) {
    // Mobile: Stacked vertically
    return Column(
      children: [
        _buildCard('Card 1'),
        SizedBox(height: ResponsiveConstants.spacing16),
        _buildCard('Card 2'),
      ],
    );
  } else if (context.isTablet) {
    // Tablet: Side by side
    return Row(
      children: [
        Expanded(child: _buildCard('Card 1')),
        SizedBox(width: ResponsiveConstants.spacing16),
        Expanded(child: _buildCard('Card 2')),
      ],
    );
  } else {
    // Desktop: Three columns
    return Row(
      children: [
        Expanded(child: _buildCard('Card 1')),
        SizedBox(width: ResponsiveConstants.spacing16),
        Expanded(child: _buildCard('Card 2')),
        SizedBox(width: ResponsiveConstants.spacing16),
        Expanded(child: _buildCard('Card 3')),
      ],
    );
  }
}
```

#### **Responsive Padding**
```dart
Container(
  padding: EdgeInsets.all(
    context.isMobile 
      ? ResponsiveConstants.spacing16
      : context.isTablet 
        ? ResponsiveConstants.spacing20
        : ResponsiveConstants.spacing24
  ),
  child: YourWidget(),
);
```

### 4. **ResponsiveHelper Static Methods**

```dart
import 'package:your_app/core/constants/responsive_constants.dart';

// Initialize in your app
ResponsiveHelper.init(context);

// Use anywhere in your app
double width = ResponsiveHelper.screenWidth;
double height = ResponsiveHelper.screenHeight;
bool isMobile = ResponsiveHelper.isMobile;
bool isTablet = ResponsiveHelper.isTablet;
bool isDesktop = ResponsiveHelper.isDesktop;

// Responsive sizing helpers
double responsiveWidth = ResponsiveHelper.getResponsiveWidth(100, 150, 200);
double responsiveHeight = ResponsiveHelper.getResponsiveHeight(50, 75, 100);
double responsiveFontSize = ResponsiveHelper.getResponsiveFontSize(14, 16, 18);
double responsiveSpacing = ResponsiveHelper.getResponsiveSpacing(16, 20, 24);

// Percentage helpers
double widthPercentage = ResponsiveHelper.getWidthPercentage(50); // 50% of screen width
double heightPercentage = ResponsiveHelper.getHeightPercentage(30); // 30% of screen height
```

## Best Practices

### ✅ **Do's**
- Use `ResponsiveConstants` for all spacing, sizing, and typography
- Use context extensions (`context.isMobile`, `context.screenWidth`) for device detection
- Design mobile-first, then enhance for larger screens
- Test on multiple device sizes and orientations
- Use consistent spacing increments throughout your app

### ❌ **Don'ts**
- Don't hardcode pixel values
- Don't use `MediaQuery.of(context)` directly (use extensions instead)
- Don't create different layouts for every screen size (use breakpoints)
- Don't forget to test on different orientations

## Migration Guide

### **From Hardcoded Values**
```dart
// Before
SizedBox(height: 16)
Text(style: TextStyle(fontSize: 18))

// After  
SizedBox(height: ResponsiveConstants.spacing16)
Text(style: TextStyle(fontSize: ResponsiveConstants.fontSize18))
```

### **From MediaQuery**
```dart
// Before
MediaQuery.of(context).size.width
MediaQuery.of(context).size.height

// After
context.screenWidth
context.screenHeight
```

### **From Device Detection**
```dart
// Before
if (MediaQuery.of(context).size.width < 600) {
  // Mobile logic
}

// After
if (context.isMobile) {
  // Mobile logic
}
```

## Available Constants

### **Spacing**
- `spacing4` to `spacing120` in consistent increments

### **Font Sizes**
- `fontSize12` to `fontSize48`

### **Icon Sizes**
- `iconSize16` to `iconSize120`

### **Border Radius**
- `radius4` to `radius48`

### **Container Heights**
- `containerHeight48` to `containerHeight312`

## Example Implementation

See `lib/ui/widgets/responsive_example.dart` for a complete working example that demonstrates:
- Responsive grid layouts
- Adaptive card arrangements
- Screen information display
- Device-specific layouts

## Testing

### **Device Preview**
The app includes Device Preview for testing different screen sizes:
- Enable in debug mode
- Test various device configurations
- Verify responsive behavior

### **Manual Testing**
- Test on actual devices
- Test different orientations
- Test various screen sizes
- Verify touch targets on mobile

## Support

For questions or issues with the responsive system:
1. Check this documentation
2. Review the example widget
3. Check existing implementations in the codebase
4. Follow the established patterns

---

**Remember**: The responsive system is designed to make your app look great on all devices automatically. Use the constants and extensions consistently, and your app will adapt beautifully to any screen size!
