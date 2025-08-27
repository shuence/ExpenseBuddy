
import 'package:expensebuddy/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../router/routes.dart';
import '../../../services/user_preferences_service.dart';
import '../../../models/user_preferences_model.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_item.dart';
import 'widgets/sign_out_button.dart';
import 'widgets/version_info.dart';
import '../settings/sync_settings_screen.dart';
import '../../../providers/transaction_provider.dart';
import '../../../ui/widgets/sync_status_widget.dart';

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
                            Consumer<TransactionProvider>(
                              builder: (context, transactionProvider, child) {
                                final unsyncedCount = transactionProvider.unsyncedTransactions.length;
                                final failedCount = transactionProvider.failedTransactions.length;
                                
                                String subtitle = 'Manage offline sync and data backup';
                                if (unsyncedCount > 0 || failedCount > 0) {
                                  subtitle = '$unsyncedCount pending, $failedCount failed';
                                }
                                
                                return SettingsItem(
                                  icon: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.activeBlue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.arrow_clockwise,
                                      color: CupertinoColors.white,
                                      size: 20,
                                    ),
                                  ),
                                  title: 'Backup & Sync',
                                  subtitle: subtitle,
                                  trailing: (unsyncedCount > 0 || failedCount > 0)
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: failedCount > 0 
                                                ? CupertinoColors.systemRed 
                                                : CupertinoColors.systemOrange,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${unsyncedCount + failedCount}',
                                            style: const TextStyle(
                                              color: CupertinoColors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                      : null,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => const SyncSettingsScreen(),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
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
