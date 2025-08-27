import 'package:flutter/cupertino.dart';
import '../widgets/settings_item.dart';
import '../widgets/settings_section.dart';

class BackupSyncScreen extends StatefulWidget {
  const BackupSyncScreen({super.key});

  @override
  State<BackupSyncScreen> createState() => _BackupSyncScreenState();
}

class _BackupSyncScreenState extends State<BackupSyncScreen> {
  bool _autoBackup = true;
  bool _wifiOnly = true;
  String _lastBackup = 'Today 2:30 PM';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Backup & Sync'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Backup Status Section
                const Text(
                  'Backup Status',
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
                          CupertinoIcons.cloud_upload,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Last Backup',
                      subtitle: _lastBackup,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Up to date',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      showChevron: false,
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Backup Settings Section
                const Text(
                  'Backup Settings',
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
                          CupertinoIcons.cloud,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Auto Backup',
                      subtitle: 'Automatically backup your data',
                      trailing: CupertinoSwitch(
                        value: _autoBackup,
                        onChanged: (value) {
                          setState(() {
                            _autoBackup = value;
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
                          CupertinoIcons.wifi,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Wi-Fi Only',
                      subtitle: 'Only backup when connected to Wi-Fi',
                      trailing: CupertinoSwitch(
                        value: _wifiOnly,
                        onChanged: (value) {
                          setState(() {
                            _wifiOnly = value;
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
                          CupertinoIcons.time,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Backup Frequency',
                      subtitle: 'Daily',
                      onTap: () => _showBackupFrequencySettings(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Manual Actions Section
                const Text(
                  'Manual Actions',
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
                          CupertinoIcons.arrow_up_to_line,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Backup Now',
                      subtitle: 'Create a backup immediately',
                      onTap: () => _performBackup(),
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
                          CupertinoIcons.arrow_down_to_line,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Restore from Backup',
                      subtitle: 'Restore your data from a backup',
                      onTap: () => _showRestoreOptions(),
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
                          CupertinoIcons.folder,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Manage Backups',
                      subtitle: 'View and manage your backups',
                      onTap: () => _showBackupManager(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Sync Settings Section
                const Text(
                  'Sync Settings',
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
                          CupertinoIcons.arrow_2_circlepath,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Auto Sync',
                      subtitle: 'Sync across all your devices',
                      trailing: CupertinoSwitch(
                        value: true,
                        onChanged: (value) {
                          // Handle auto sync toggle
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
                          CupertinoIcons.device_phone_portrait,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      title: 'Connected Devices',
                      subtitle: '2 devices connected',
                      onTap: () => _showConnectedDevices(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Storage Info
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
                            'Storage Usage',
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
                        'Your data is using 2.5 MB of cloud storage. Your backups are encrypted and secure.',
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

  void _showBackupFrequencySettings() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Backup Frequency'),
        actions: [
        CupertinoActionSheetAction(
          child: const Text('Hourly'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoActionSheetAction(
          child: const Text('Daily'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoActionSheetAction(
          child: const Text('Weekly'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoActionSheetAction(
          child: const Text('Manual Only'),
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

  void _performBackup() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Backup Now'),
        content: const Text('Creating backup of your data...'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _lastBackup = 'Just now';
              });
            },
          ),
        ],
      ),
    );
  }

  void _showRestoreOptions() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Restore from Backup'),
        content: const Text('This feature will be available soon. You can restore your data from previous backups.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showBackupManager() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Manage Backups'),
        content: const Text('Backup management features will be available in a future update.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showConnectedDevices() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Connected Devices'),
        content: const Text('Device management will be available in a future update.'),
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
