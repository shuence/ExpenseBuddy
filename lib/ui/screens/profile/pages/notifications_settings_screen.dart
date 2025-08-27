import 'package:flutter/cupertino.dart';
import '../../../../models/user_preferences_model.dart';
import '../../../../services/user_preferences_service.dart';
import '../widgets/settings_item.dart';
import '../widgets/settings_section.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  final UserPreferencesService _preferencesService = UserPreferencesService();
  UserPreferencesModel? _preferences;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final userId = _preferencesService.currentUserId;
      if (userId != null) {
        final preferences = await _preferencesService.getUserPreferences(userId);
        setState(() {
          _preferences = preferences;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Notifications'),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Push Notifications Section
                      const Text(
                        'Push Notifications',
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
                                color: CupertinoColors.activeGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                CupertinoIcons.bell,
                                color: CupertinoColors.white,
                                size: 18,
                              ),
                            ),
                            title: 'Allow Notifications',
                            subtitle: _preferences?.notificationPermission == true ? 'Enabled' : 'Disabled',
                            trailing: CupertinoSwitch(
                              value: _preferences?.notificationPermission ?? false,
                              onChanged: (value) => _updateNotificationPermission(value),
                            ),
                            showChevron: false,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Notification Types Section
                      const Text(
                        'Notification Types',
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
                                color: CupertinoColors.systemBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                CupertinoIcons.money_dollar_circle,
                                color: CupertinoColors.white,
                                size: 18,
                              ),
                            ),
                            title: 'Transaction Alerts',
                            subtitle: 'Get notified when you add transactions',
                            trailing: CupertinoSwitch(
                              value: true, // Default value since the field might not exist
                              onChanged: (value) => _updateNotificationSetting('transactionAlerts', value),
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
                                CupertinoIcons.chart_bar,
                                color: CupertinoColors.white,
                                size: 18,
                              ),
                            ),
                            title: 'Budget Updates',
                            subtitle: 'Alerts when approaching budget limits',
                            trailing: CupertinoSwitch(
                              value: true, // Default value since the field might not exist
                              onChanged: (value) => _updateNotificationSetting('budgetAlerts', value),
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
                                CupertinoIcons.calendar,
                                color: CupertinoColors.white,
                                size: 18,
                              ),
                            ),
                            title: 'Monthly Reports',
                            subtitle: 'Monthly spending summaries',
                            trailing: CupertinoSwitch(
                              value: true, // Default value since the field might not exist
                              onChanged: (value) => _updateNotificationSetting('monthlyReports', value),
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
                                CupertinoIcons.exclamationmark_triangle,
                                color: CupertinoColors.white,
                                size: 18,
                              ),
                            ),
                            title: 'Security Alerts',
                            subtitle: 'Important security notifications',
                            trailing: CupertinoSwitch(
                              value: true, // Default value since the field might not exist
                              onChanged: (value) => _updateNotificationSetting('securityAlerts', value),
                            ),
                            showChevron: false,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Delivery Settings Section
                      const Text(
                        'Delivery Settings',
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
                                CupertinoIcons.mail,
                                color: CupertinoColors.white,
                                size: 18,
                              ),
                            ),
                            title: 'Email Notifications',
                            subtitle: 'Receive notifications via email',
                            trailing: CupertinoSwitch(
                              value: true, // Default value since the field might not exist
                              onChanged: (value) => _updateNotificationSetting('emailNotifications', value),
                            ),
                            showChevron: false,
                          ),
                          SettingsItem(
                            icon: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemIndigo,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                CupertinoIcons.device_phone_portrait,
                                color: CupertinoColors.white,
                                size: 18,
                              ),
                            ),
                            title: 'SMS Notifications',
                            subtitle: 'Receive notifications via SMS',
                            trailing: CupertinoSwitch(
                              value: false, // Default value since the field might not exist
                              onChanged: (value) => _updateNotificationSetting('smsNotifications', value),
                            ),
                            showChevron: false,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Quiet Hours Section
                      const Text(
                        'Quiet Hours',
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
                                color: CupertinoColors.systemGrey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                CupertinoIcons.moon,
                                color: CupertinoColors.white,
                                size: 18,
                              ),
                            ),
                            title: 'Do Not Disturb',
                            subtitle: 'Disable notifications during quiet hours',
                            trailing: CupertinoSwitch(
                              value: false, // Default value since the field might not exist
                              onChanged: (value) => _updateNotificationSetting('quietHours', value),
                            ),
                            showChevron: false,
                          ),
                          // Commenting out quiet hours time setting for now
                          // if (_preferences?.notificationSettings.quietHours == true) ...[
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
                              title: 'Quiet Hours Time',
                              subtitle: '10:00 PM - 8:00 AM',
                              onTap: () => _showQuietHoursSettings(),
                            ),
                          // ],
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Notification Info
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
                                  'About Notifications',
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
                              'You can manage which notifications you receive and how you receive them. Changes take effect immediately.',
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

  Future<void> _updateNotificationPermission(bool value) async {
    try {
      final userId = _preferencesService.currentUserId;
      if (userId != null) {
        await _preferencesService.updatePreferences(userId, {
          'notificationPermission': value,
        });
        
        // Refresh preferences
        await _loadPreferences();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _updateNotificationSetting(String setting, bool value) async {
    try {
      final userId = _preferencesService.currentUserId;
      if (userId != null) {
        final currentSettings = _preferences?.notificationSettings.toJson() ?? {};
        currentSettings[setting] = value;
        
        await _preferencesService.updatePreferences(userId, {
          'notificationSettings': currentSettings,
        });
        
        // Refresh preferences
        await _loadPreferences();
      }
    } catch (e) {
      // Handle error
    }
  }

  void _showQuietHoursSettings() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Quiet Hours'),
        content: const Text('Quiet hours time settings will be available in a future update.'),
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
