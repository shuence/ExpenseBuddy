import 'package:flutter/cupertino.dart';
import '../widgets/settings_item.dart';
import '../widgets/settings_section.dart';

class AppPreferencesScreen extends StatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen> {
  bool _darkMode = false;
  bool _hapticFeedback = true;
  bool _soundEffects = true;
  String _language = 'English';
  String _dateFormat = 'MM/DD/YYYY';
  String _theme = 'System';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('App Preferences'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Appearance Section
                const Text(
                  'Appearance',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 16),
                
                SettingsSection(
                  children: [
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemIndigo,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.paintbrush,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Theme',
                      subtitle: _theme,
                      onTap: () => _showThemeOptions(),
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.moon,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Dark Mode',
                      subtitle: 'Use dark appearance',
                      trailing: CupertinoSwitch(
                        value: _darkMode,
                        onChanged: (value) {
                          setState(() {
                            _darkMode = value;
                          });
                        },
                      ),
                      showChevron: false,
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemPurple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.textformat,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Font Size',
                      subtitle: 'Medium',
                      onTap: () => _showFontSizeOptions(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Interaction Section
                const Text(
                  'Interaction',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 16),
                
                SettingsSection(
                  children: [
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.device_phone_portrait,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Haptic Feedback',
                      subtitle: 'Vibration for interactions',
                      trailing: CupertinoSwitch(
                        value: _hapticFeedback,
                        onChanged: (value) {
                          setState(() {
                            _hapticFeedback = value;
                          });
                        },
                      ),
                      showChevron: false,
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.speaker_2,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Sound Effects',
                      subtitle: 'Audio feedback for actions',
                      trailing: CupertinoSwitch(
                        value: _soundEffects,
                        onChanged: (value) {
                          setState(() {
                            _soundEffects = value;
                          });
                        },
                      ),
                      showChevron: false,
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.hand_draw,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Gesture Navigation',
                      subtitle: 'Use swipe gestures',
                      trailing: CupertinoSwitch(
                        value: true,
                        onChanged: (value) {
                          // Handle gesture navigation
                        },
                      ),
                      showChevron: false,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Localization Section
                const Text(
                  'Localization',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 16),
                
                SettingsSection(
                  children: [
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemTeal,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.globe,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Language',
                      subtitle: _language,
                      onTap: () => _showLanguageOptions(),
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.calendar,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Date Format',
                      subtitle: _dateFormat,
                      onTap: () => _showDateFormatOptions(),
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemYellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.time,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Time Format',
                      subtitle: '12-hour',
                      onTap: () => _showTimeFormatOptions(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Data & Storage Section
                const Text(
                  'Data & Storage',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 16),
                
                SettingsSection(
                  children: [
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemPurple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.floppy_disk,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Cache Size',
                      subtitle: '12.5 MB',
                      onTap: () => _showCacheOptions(),
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.trash,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Clear Cache',
                      subtitle: 'Free up storage space',
                      onTap: () => _clearCache(),
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.arrow_down_to_line,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Offline Mode',
                      subtitle: 'Work without internet connection',
                      trailing: CupertinoSwitch(
                        value: true,
                        onChanged: (value) {
                          // Handle offline mode
                        },
                      ),
                      showChevron: false,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Reset Section
                const Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 16),
                
                SettingsSection(
                  children: [
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.arrow_counterclockwise,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Reset Preferences',
                      subtitle: 'Restore default settings',
                      onTap: () => _resetPreferences(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Preferences Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.info,
                            color: CupertinoColors.systemBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'About Preferences',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.label,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your preferences are saved locally and synced across your devices when signed in.',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeOptions() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Theme'),
        actions: [
        CupertinoActionSheetAction(
          child: const Text('Light'),
          onPressed: () {
            setState(() => _theme = 'Light');
            Navigator.pop(context);
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('Dark'),
          onPressed: () {
            setState(() => _theme = 'Dark');
            Navigator.pop(context);
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('System'),
          onPressed: () {
            setState(() => _theme = 'System');
            Navigator.pop(context);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancel'),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    );
  } 

  void _showFontSizeOptions() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Font Size'),
        actions: [
        CupertinoActionSheetAction(
          child: const Text('Small'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoActionSheetAction(
          child: const Text('Medium'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoActionSheetAction(
          child: const Text('Large'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoActionSheetAction(
          child: const Text('Extra Large'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancel'),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    );
  }

  void _showLanguageOptions() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Language'),
        actions: [
        CupertinoActionSheetAction(
          child: const Text('English'),
          onPressed: () {
            setState(() => _language = 'English');
            Navigator.pop(context);
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('Spanish'),
          onPressed: () {
            setState(() => _language = 'Spanish');
            Navigator.pop(context);
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('French'),
          onPressed: () {
            setState(() => _language = 'French');
            Navigator.pop(context);
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('German'),
          onPressed: () {
            setState(() => _language = 'German');
            Navigator.pop(context);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancel'),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    );
  }

  void _showDateFormatOptions() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Date Format'),
        actions: [
        CupertinoActionSheetAction(
          child: const Text('MM/DD/YYYY'),
          onPressed: () {
            setState(() => _dateFormat = 'MM/DD/YYYY');
            Navigator.pop(context);
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('DD/MM/YYYY'),
          onPressed: () {
            setState(() => _dateFormat = 'DD/MM/YYYY');
            Navigator.pop(context);
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('YYYY-MM-DD'),
          onPressed: () {
            setState(() => _dateFormat = 'YYYY-MM-DD');
            Navigator.pop(context);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancel'),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    );  
  }

  void _showTimeFormatOptions() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
                title: const Text('Time Format'),
        actions: [
        CupertinoActionSheetAction(
          child: const Text('12-hour'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoActionSheetAction(
          child: const Text('24-hour'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancel'),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    );
  }

  void _showCacheOptions() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Cache Information'),
        content: const Text('The app cache stores temporary data to improve performance. Current cache size: 12.5 MB'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear temporary files and may slow down the app temporarily. Continue?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Clear'),
            onPressed: () {
              Navigator.pop(context);
              // Implement cache clearing
            },
          ),
        ],
      ),
    );
  }

  void _resetPreferences() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Reset Preferences'),
        content: const Text('This will restore all settings to their default values. This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Reset'),
            onPressed: () {
              Navigator.pop(context);
              // Implement preference reset
            },
          ),
        ],
      ),
    );
  }
}
