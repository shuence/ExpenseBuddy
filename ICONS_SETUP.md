# Flutter Launcher Icons Setup Guide

## Prerequisites
1. Add your app icon image file named `app_icon.png` to the `assets/icons/` directory
2. The image should be at least 1024x1024 pixels for best results
3. Use PNG format for best compatibility

## Generate Icons
After adding your app icon image, run the following command to generate launcher icons for all platforms:

```bash
flutter pub run flutter_launcher_icons:main
```

This will generate icons for:
- Android (launcher_icon)
- iOS
- Web
- Windows
- macOS

## Configuration
The flutter_launcher_icons configuration is already set up in `pubspec.yaml` with the following settings:
- Android: "launcher_icon"
- iOS: true
- Web: enabled with background and theme colors
- Windows: enabled with 48px icon size
- macOS: enabled

## Customization
You can modify the configuration in `pubspec.yaml` under the `flutter_launcher_icons` section to:
- Change icon names
- Adjust icon sizes
- Modify colors for web
- Enable/disable specific platforms
