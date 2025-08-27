
import 'package:expensebuddy/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../router/routes.dart';
import '../../../services/user_preferences_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../models/user_preferences_model.dart';
import 'package:provider/provider.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_item.dart';
import 'widgets/sign_out_button.dart';
import 'widgets/version_info.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserPreferencesService _preferencesService = UserPreferencesService();
  UserPreferencesModel? _userPreferences;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    try {
      final userId = _preferencesService.currentUserId;
      if (userId != null) {
        final preferences = await _preferencesService.getUserPreferences(userId);
        if (mounted) {
          setState(() {
            _userPreferences = preferences;
          });
        }
      }
    } catch (e) {
      // Handle error silently, will use defaults
    }
  }

  Future<void> _refreshData() async {
    await _loadUserPreferences();
  }

  String _getCurrencyDisplay() {
    if (_userPreferences?.defaultCurrency != null) {
      // Find currency info
      final currencyCode = _userPreferences!.defaultCurrency;
      final country = _preferencesService.findCountryByCurrencyCode(currencyCode);
      if (country != null) {
        return '$currencyCode - ${country.name}';
      }
      return '$currencyCode - ${_userPreferences!.country}';
    }
    return 'USD - United States Dollar';
  }

  void _showSyncStatusDialog(BuildContext context, TransactionProvider transactionProvider) {
    final connectivityService = ConnectivityService();
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sync Status'),
        content: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  connectivityService.isConnected 
                      ? CupertinoIcons.checkmark_circle_fill 
                      : CupertinoIcons.xmark_circle_fill,
                  color: connectivityService.isConnected 
                      ? CupertinoColors.systemGreen 
                      : CupertinoColors.systemRed,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  connectivityService.isConnected ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: connectivityService.isConnected 
                        ? CupertinoColors.systemGreen 
                        : CupertinoColors.systemRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              connectivityService.isConnected 
                  ? 'Your device is connected to the internet. All transactions should sync automatically.'
                  : 'Your device is offline. Transactions will sync when connection is restored.',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () async {
              Navigator.pop(context);
              await _testConnectivity(context);
            },
            child: const Text('Test Connection'),
          ),
          if (connectivityService.isConnected)
            CupertinoDialogAction(
              onPressed: () async {
                Navigator.pop(context);
                _showRetrySyncDialog(context, transactionProvider);
              },
              child: const Text('Retry Sync'),
            ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRetrySyncDialog(BuildContext context, TransactionProvider transactionProvider) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Retry Firebase Sync'),
        content: const Text(
          'This will attempt to sync all your local transactions to Firebase. '
          'Make sure you have a stable internet connection.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () async {
              Navigator.pop(context);
              await _performRetrySync(context, transactionProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _performRetrySync(BuildContext context, TransactionProvider transactionProvider) async {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Syncing...'),
        content: const Column(
          children: [
            CupertinoActivityIndicator(),
            SizedBox(height: 16),
            Text('Syncing transactions to Firebase...'),
          ],
        ),
      ),
    );

    try {
      final result = await transactionProvider.retryAllFirebaseSyncs();
      Navigator.pop(context); // Close loading dialog
      
      if (result['success'] == true) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Sync Complete'),
            content: Text(
              'Successfully synced ${result['successCount']} transactions to Firebase.\n'
              '${result['failureCount']} transactions failed to sync.',
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Sync Failed'),
            content: Text('Failed to sync: ${result['error']}'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Sync Error'),
          content: Text('An error occurred: $e'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _testConnectivity(BuildContext context) async {
    final connectivityService = ConnectivityService();
    
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Testing Connection...'),
        content: const Column(
          children: [
            CupertinoActivityIndicator(),
            SizedBox(height: 16),
            Text('Checking your internet connection...'),
          ],
        ),
      ),
    );

    try {
      final isConnected = await connectivityService.testNetworkConnectivity();
      Navigator.pop(context); // Close loading dialog
      
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(isConnected ? 'Connection Test Passed' : 'Connection Test Failed'),
          content: Text(
            isConnected 
                ? 'Your device is connected to the internet and can reach external services.'
                : 'Your device appears to be offline or cannot reach external services.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Connection Test Error'),
          content: Text('An error occurred while testing: $e'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            debugPrint('ProfileScreen: Auth state: ${state.runtimeType}');
            
            UserModel? user;
            if (state is Authenticated) {
              user = state.user;
              debugPrint('ProfileScreen: Found Authenticated state with user: ${user.displayName}');
            } else if (state is AuthenticatedButNoPreferences) {
              user = state.user;
              debugPrint('ProfileScreen: Found AuthenticatedButNoPreferences state with user: ${user.displayName}');
            } else {
              debugPrint('ProfileScreen: No authenticated state found, state is: ${state.runtimeType}');
            }
                
            debugPrint('ProfileScreen: Final user: $user');
            debugPrint('ProfileScreen: User displayName: ${user?.displayName}');
            debugPrint('ProfileScreen: User email: ${user?.email}');
            
            return CustomScrollView(
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: _refreshData,
                ),
                SliverToBoxAdapter(
                  child: Column(
                children: [
                  // Profile Header
                  GestureDetector(
                    onTap: () {
                      context.push(AppRoutes.accountSettings);
                    },
                    child: ProfileHeader(user: user),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Settings Sections
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Main Settings
                        SettingsSection(
                          children: [
                            SettingsItem(
                              icon: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.activeGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  CupertinoIcons.person,
                                  color: CupertinoColors.white,
                                  size: 20,
                                ),
                              ),
                              title: 'Account Settings',
                              subtitle: 'Security, Password, Personal info',
                              onTap: () {
                                context.push(AppRoutes.accountSettings);
                              },
                            ),
                            SettingsItem(
                              icon: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.activeGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  CupertinoIcons.money_dollar,
                                  color: CupertinoColors.white,
                                  size: 20,
                                ),
                              ),
                              title: 'Currency',
                              subtitle: _getCurrencyDisplay(),
                              onTap: () {
                                context.push(AppRoutes.currencySettings);
                              },
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Notifications and Backup
                        SettingsSection(
                          children: [
                            SettingsItem(
                              icon: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.activeGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  CupertinoIcons.bell,
                                  color: CupertinoColors.white,
                                  size: 20,
                                ),
                              ),
                              title: 'Notifications',
                              trailing: Container(
                                width: 48,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.activeGreen,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  CupertinoIcons.check_mark,
                                  color: CupertinoColors.white,
                                  size: 16,
                                ),
                              ),
                              showChevron: false,
                              onTap: () {
                                context.push(AppRoutes.notificationsSettings);
                              },
                            ),
                            // Removed backup & sync section
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Sync Status Section
                        Consumer<TransactionProvider>(
                          builder: (context, transactionProvider, child) {
                            return SettingsSection(
                              children: [
                                SettingsItem(
                                  icon: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.systemBlue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.cloud,
                                      color: CupertinoColors.white,
                                      size: 20,
                                    ),
                                  ),
                                  title: 'Sync Status',
                                  subtitle: 'Check cloud sync status',
                                  onTap: () {
                                    _showSyncStatusDialog(context, transactionProvider);
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Privacy and Preferences
                        SettingsSection(
                          children: [
                            SettingsItem(
                              icon: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.activeGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  CupertinoIcons.shield,
                                  color: CupertinoColors.white,
                                  size: 20,
                                ),
                              ),
                              title: 'Privacy & Security',
                              onTap: () {
                                context.push(AppRoutes.privacySecuritySettings);
                              },
                            ),
                            SettingsItem(
                              icon: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.activeGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  CupertinoIcons.settings,
                                  color: CupertinoColors.white,
                                  size: 20,
                                ),
                              ),
                              title: 'App Preferences',
                              onTap: () {
                                context.push(AppRoutes.appPreferencesSettings);
                              },
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Help and About
                        SettingsSection(
                          children: [
                            SettingsItem(
                              icon: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.activeGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  CupertinoIcons.question_circle,
                                  color: CupertinoColors.white,
                                  size: 20,
                                ),
                              ),
                              title: 'Help & Support',
                              onTap: () {
                                context.push(AppRoutes.helpSupportSettings);
                              },
                            ),
                            SettingsItem(
                              icon: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.activeGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  CupertinoIcons.info,
                                  color: CupertinoColors.white,
                                  size: 20,
                                ),
                              ),
                              title: 'About ExpenseBuddy',
                              onTap: () {
                                context.push(AppRoutes.aboutSettings);
                              },
                            ),
                          ],
                        ),
                        
                        // Sign Out Button
                        const SignOutButton(),
                        
                        // Version Info
                        const VersionInfo(),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
            );
          }
        ),
      ),
    );
  } 
}
