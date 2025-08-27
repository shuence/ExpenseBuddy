import 'package:flutter/cupertino.dart';
import '../widgets/settings_item.dart';
import '../widgets/settings_section.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _biometricAuth = false;
  bool _appLock = true;

  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Privacy & Security'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Authentication Section
                const Text(
                  'Authentication',
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
                          color: CupertinoColors.systemGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.lock_shield,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Biometric Authentication',
                      subtitle: 'Use Face ID or Touch ID to unlock',
                      trailing: CupertinoSwitch(
                        value: _biometricAuth,
                        onChanged: (value) {
                          setState(() {
                            _biometricAuth = value;
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
                          CupertinoIcons.lock,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'App Lock',
                      subtitle: 'Require authentication to open app',
                      trailing: CupertinoSwitch(
                        value: _appLock,
                        onChanged: (value) {
                          setState(() {
                            _appLock = value;
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
                          color: CupertinoColors.systemOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.time,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Auto-Lock Timer',
                      subtitle: 'Lock app after 5 minutes',
                      onTap: () => _showAutoLockOptions(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Data Protection Section
                const Text(
                  'Data Protection',
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
                          CupertinoIcons.shield,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Data Encryption',
                      subtitle: 'All data is encrypted at rest',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Enabled',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      showChevron: false,
                    ),
                    SettingsItem(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemTeal,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.eye_slash,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Hide in App Switcher',
                      subtitle: 'Hide app content when switching apps',
                      trailing: CupertinoSwitch(
                        value: true,
                        onChanged: (value) {
                          // Handle hide in app switcher
                        },
                      ),
                      showChevron: false,
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
                          CupertinoIcons.camera,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Screenshot Protection',
                      subtitle: 'Prevent screenshots in sensitive areas',
                      trailing: CupertinoSwitch(
                        value: false,
                        onChanged: (value) {
                          // Handle screenshot protection
                        },
                      ),
                      showChevron: false,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Privacy Settings Section
                const Text(
                  'Privacy Settings',
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
                          CupertinoIcons.chart_bar,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Analytics',
                      subtitle: 'Help improve the app',
                      trailing: CupertinoSwitch(
                        value: true,
                        onChanged: (value) {
                          // Handle analytics toggle
                        },
                      ),
                      showChevron: false,
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
                          CupertinoIcons.exclamationmark_triangle,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Crash Reports',
                      subtitle: 'Send crash reports to improve stability',
                      trailing: CupertinoSwitch(
                        value: true,
                        onChanged: (value) {
                          // Handle crash reports toggle
                        },
                      ),
                      showChevron: false,
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
                          CupertinoIcons.location,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Location Services',
                      subtitle: 'Used for location-based features',
                      trailing: CupertinoSwitch(
                        value: false,
                        onChanged: (value) {
                          // Handle location services
                        },
                      ),
                      showChevron: false,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Account Security Section
                const Text(
                  'Account Security',
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
                          CupertinoIcons.device_phone_portrait,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Active Sessions',
                      subtitle: 'Manage your active login sessions',
                      onTap: () => _showActiveSessions(),
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
                          CupertinoIcons.bell,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Security Alerts',
                      subtitle: 'Get notified of security events',
                      trailing: CupertinoSwitch(
                        value: true,
                        onChanged: (value) {
                          // Handle security alerts
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
                          CupertinoIcons.doc_text,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      onTap: () => _showPrivacyPolicy(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Security Info
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
                            CupertinoIcons.shield_lefthalf_fill,
                            color: CupertinoColors.activeGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Your Data is Secure',
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
                        'We use industry-standard encryption to protect your financial data. Your information is never shared with third parties without your consent.',
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

  void _showAutoLockOptions() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Auto-Lock Timer'),
        actions: [
        CupertinoActionSheetAction(
          child: const Text('Immediately'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoActionSheetAction(
          child: const Text('1 minute'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoActionSheetAction(
          child: const Text('5 minutes'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoActionSheetAction(
          child: const Text('15 minutes'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoActionSheetAction(
          child: const Text('Never'),
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

  void _showActiveSessions() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Active Sessions'),
        content: const Text('Session management will be available in a future update.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text('The privacy policy will be displayed in a future update.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
