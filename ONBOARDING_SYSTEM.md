# Onboarding System Documentation

## Overview

The ExpenseBuddy app includes a complete onboarding system with 3 screens that introduces users to the app's key features. The system automatically detects if a user has seen the onboarding and only shows it once.

## Features

### 🎯 **3 Onboarding Screens**
1. **Track Your Daily Expenses** - Introduces expense tracking
2. **Smart Analytics** - Highlights reporting features  
3. **Financial Freedom** - Emphasizes financial goals

### 🔄 **Smart Navigation**
- **PageView**: Smooth horizontal swiping between screens
- **Previous/Next**: Navigation buttons with smart visibility
- **Skip Option**: Users can skip onboarding entirely
- **Auto-completion**: Automatically navigates to login after completion

### 💾 **Persistent State**
- **SharedPreferences**: Remembers if user has seen onboarding
- **One-time Display**: Onboarding only shows on first app launch
- **Automatic Detection**: App checks onboarding status on startup

## Architecture

### **Models**
- `OnboardingPage`: Individual page data structure
- `OnboardingData`: Static data for all 3 pages

### **BLoC Pattern**
- `OnboardingBloc`: Manages onboarding state and logic
- `OnboardingEvent`: User actions (next, previous, complete, etc.)
- `OnboardingState`: Current state (loading, loaded, etc.)

### **Widgets**
- `OnboardingScreen`: Main container with PageView
- `OnboardingPageWidget`: Individual page display
- `OnboardingIndicator`: Page position dots

## Implementation Details

### **1. Onboarding Flow**
```
Splash Screen → Onboarding → Login Screen
     ↓              ↓           ↓
  3 seconds    User views    App ready
  delay       3 screens     for use
```

### **2. State Management**
```dart
// Check if user has seen onboarding
final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

// Save onboarding completion
await prefs.setBool('has_seen_onboarding', true);
```

### **3. Navigation Logic**
- **First Launch**: Splash → Onboarding → Login
- **Subsequent Launches**: Splash → Login (skips onboarding)

## Usage

### **Basic Implementation**
```dart
// The onboarding system is automatically integrated
// No additional code needed in your screens
```

### **Manual Control (if needed)**
```dart
// Check onboarding status
final onboardingBloc = context.read<OnboardingBloc>();
final hasSeen = onboardingBloc.hasSeenOnboarding;

// Force show onboarding (for testing)
// Clear SharedPreferences key: 'has_seen_onboarding'
```

## Customization

### **Modifying Content**
Edit `lib/models/onboarding_model.dart`:
```dart
class OnboardingData {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Your Title',
      subtitle: 'Your Subtitle', 
      description: 'Your description text',
      imagePath: 'assets/images/your_image.png',
      buttonText: 'Your Button Text',
    ),
    // Add more pages...
  ];
}
```

### **Changing Icons**
Edit `_getIconForPage()` in `OnboardingPageWidget`:
```dart
IconData _getIconForPage(String title) {
  switch (title.toLowerCase()) {
    case 'your title':
      return CupertinoIcons.your_icon;
    // Add more cases...
  }
}
```

### **Styling**
- **Colors**: Uses `AppTheme` for consistency
- **Spacing**: Uses `ResponsiveConstants` for responsive design
- **Typography**: Configurable font sizes and weights

## File Structure

```
lib/
├── models/
│   └── onboarding_model.dart          # Data models
├── providers/
│   └── onboarding_provider.dart       # BLoC implementation
├── ui/screens/onboarding/
│   ├── onboarding_screen.dart         # Main screen
│   └── widgets/
│       ├── onboarding_page_widget.dart # Individual page
│       └── onboarding_indicator.dart   # Page dots
└── router/
    ├── app_router.dart                # Route configuration
    └── routes.dart                    # Route constants
```

## Dependencies

### **Required Packages**
- `flutter_bloc`: State management
- `equatable`: State comparison
- `shared_preferences`: Persistence
- `injectable`: Dependency injection
- `go_router`: Navigation

### **Integration Points**
- **Dependency Injection**: Automatically registered
- **App Router**: Onboarding route configured
- **Theme System**: Uses app's color scheme
- **Responsive System**: Adapts to screen sizes

## Testing

### **Manual Testing**
1. **First Launch**: Verify onboarding appears
2. **Complete Onboarding**: Verify navigation to login
3. **Restart App**: Verify onboarding doesn't appear
4. **Skip Onboarding**: Verify immediate navigation

### **Reset for Testing**
```dart
// Clear onboarding status
final prefs = await SharedPreferences.getInstance();
await prefs.remove('has_seen_onboarding');
```

## Troubleshooting

### **Common Issues**

#### **Onboarding Not Showing**
- Check if `has_seen_onboarding` is true in SharedPreferences
- Verify onboarding route is properly configured
- Check for navigation errors in console

#### **Navigation Issues**
- Ensure `AppRoutes.onboarding` is defined
- Verify `OnboardingScreen` is imported in router
- Check BLoC provider registration

#### **State Management Issues**
- Verify `OnboardingBloc` is registered in DI
- Check event handling in BLoC
- Ensure proper state emission

### **Debug Information**
```dart
// Add debug prints in OnboardingBloc
debugPrint('Onboarding status: $hasSeenOnboarding');
debugPrint('Current page: $currentPageIndex');
debugPrint('Total pages: ${pages.length}');
```

## Future Enhancements

### **Potential Improvements**
- **Custom Animations**: Page transitions, entrance effects
- **Video Content**: Animated explanations
- **Interactive Elements**: Touch gestures, swipe hints
- **Localization**: Multiple language support
- **A/B Testing**: Different onboarding flows

### **Analytics Integration**
```dart
// Track onboarding completion
analytics.track('onboarding_completed', {
  'pages_viewed': currentPageIndex + 1,
  'completion_time': completionDuration,
});
```

## Best Practices

### ✅ **Do's**
- Keep onboarding content concise and focused
- Use consistent visual language
- Test on multiple device sizes
- Provide clear navigation options
- Respect user's time with skip option

### ❌ **Don'ts**
- Don't make onboarding too long
- Don't force users through every screen
- Don't use complex animations on low-end devices
- Don't forget to test the complete flow
- Don't hardcode navigation paths

---

**Remember**: The onboarding system is designed to be user-friendly and efficient. It should introduce your app's value proposition without overwhelming new users. Keep it simple, engaging, and quick to complete!
