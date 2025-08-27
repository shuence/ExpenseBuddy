import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/user_model.dart';

import '../widgets/settings_item.dart';
import '../widgets/settings_section.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Account Settings'),
      ),
      child: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state is Authenticated || state is AuthenticatedButNoPreferences 
                ? (state is Authenticated ? (state).user : (state as AuthenticatedButNoPreferences).user)
                : null;
            
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Personal Information Section
                    const Text(
                      'Personal Information',
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
                          icon: const Icon(
                            CupertinoIcons.person,
                            color: CupertinoColors.activeBlue,
                          ),
                          title: 'Full Name',
                          subtitle: user?.displayName ?? 'Not set',
                          onTap: () => _editName(context, user),
                        ),
                        SettingsItem(
                          icon: const Icon(
                            CupertinoIcons.mail,
                            color: CupertinoColors.activeOrange,
                          ),
                          title: 'Email Address',
                          subtitle: user?.email ?? 'Not set',
                          onTap: () => _editEmail(context, user),
                        ),
                        SettingsItem(
                          icon: const Icon(
                            CupertinoIcons.phone,
                            color: CupertinoColors.activeGreen,
                          ),
                          title: 'Phone Number',
                          subtitle: 'Not set',
                          onTap: () => _editPhone(context),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Security Section
                    const Text(
                      'Security',
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
                          icon: const Icon(
                            CupertinoIcons.lock,
                            color: CupertinoColors.systemRed,
                          ),
                          title: 'Change Password',
                          subtitle: 'Update your password',
                          onTap: () => _changePassword(context),
                        ),
                        SettingsItem(
                          icon: const Icon(
                            CupertinoIcons.person_2,
                            color: CupertinoColors.systemPurple,
                          ),
                          title: 'Two-Factor Authentication',
                          subtitle: 'Disabled',
                          onTap: () => _configureTwoFactor(context),
                        ),
                        SettingsItem(
                          icon: const Icon(
                            CupertinoIcons.device_phone_portrait,
                            color: CupertinoColors.systemIndigo,
                          ),
                          title: 'Connected Devices',
                          subtitle: 'Manage your devices',
                          onTap: () => _manageDevices(context),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Account Actions Section
                    const Text(
                      'Account Actions',
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
                          icon: const Icon(
                            CupertinoIcons.cloud_download,
                            color: CupertinoColors.systemBlue,
                          ),
                          title: 'Download My Data',
                          subtitle: 'Export your account data',
                          onTap: () => _downloadData(context),
                        ),
                        SettingsItem(
                          icon: const Icon(
                            CupertinoIcons.delete,
                            color: CupertinoColors.destructiveRed,
                          ),
                          title: 'Delete Account',
                          subtitle: 'Permanently delete your account',
                          onTap: () => _deleteAccount(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _editName(BuildContext context, UserModel? user) {
    // Implement name editing
    _showEditDialog(
      context,
      'Edit Name',
      user?.displayName ?? '',
      (value) async {
        // Update name logic
      },
    );
  }

  void _editEmail(BuildContext context, UserModel? user) {
    // Show info that email cannot be changed directly
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Email Address'),
        content: const Text('To change your email address, please contact support or create a new account.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _editPhone(BuildContext context) {
    _showEditDialog(
      context,
      'Add Phone Number',
      '',
      (value) async {
        // Update phone logic
      },
    );
  }

  void _changePassword(BuildContext context) {
    // Navigate to change password screen or show dialog
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Change Password'),
        content: const Text('A password reset link will be sent to your email address.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Send Link'),
            onPressed: () {
              Navigator.pop(context);
              // Send password reset email
            },
          ),
        ],
      ),
    );
  }

  void _configureTwoFactor(BuildContext context) {
    // Implement 2FA configuration
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Two-Factor Authentication'),
        content: const Text('This feature is coming soon!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _manageDevices(BuildContext context) {
    // Implement device management
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Connected Devices'),
        content: const Text('Device management is coming soon!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _downloadData(BuildContext context) {
    // Implement data export
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Download Data'),
        content: const Text('Your data export will be prepared and sent to your email address.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Request Export'),
            onPressed: () {
              Navigator.pop(context);
              // Request data export
            },
          ),
        ],
      ),
    );
  }

  void _deleteAccount(BuildContext context) {
    // Implement account deletion with confirmation
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This action cannot be undone. All your data will be permanently deleted.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context);
              // Implement account deletion
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String initialValue,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: initialValue);
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Enter value',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('Save'),
            onPressed: () {
              Navigator.pop(context);
              onSave(controller.text);
            },
          ),
        ],
      ),
    );
  }
}
