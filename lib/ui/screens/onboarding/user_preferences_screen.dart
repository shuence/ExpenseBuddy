import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../models/user_preferences_model.dart';
import '../../../services/user_preferences_service.dart';
import '../../../services/firebase_service.dart';
import '../../../services/permission_service.dart';
import 'package:go_router/go_router.dart';
import '../../../router/routes.dart';

class UserPreferencesScreen extends StatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  State<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  final UserPreferencesService _preferencesService = UserPreferencesService();
  final FirebaseService _firebaseService = FirebaseService();
  final PermissionService _permissionService = PermissionService();
  
  Country? _selectedCountry;
  bool _isLoading = false;
  int _currentStep = 0;
  
  // Permission states
  bool _locationPermission = false;
  bool _cameraPermission = false;
  bool _smsPermission = false;
  bool _notificationPermission = false;
  
  // Location data
  Map<String, dynamic>? _locationData;

  @override
  void initState() {
    super.initState();
    _initializeDefaultCountry();
  }

  void _initializeDefaultCountry() {
    // Set default country to US
    _selectedCountry = Countries.findByCode('US');
  }

  // Request location permission and get location data
  Future<void> _requestLocationPermission() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _permissionService.requestLocationPermission();
      if (result['granted'] == true) {
        setState(() {
          _locationPermission = true;
          // Store location data for later use
          _locationData = {
            'latitude': result['latitude'],
            'longitude': result['longitude'],
            'city': result['city'],
            'state': result['state'],
          };
        });
        _showSuccessDialog('Location Access', 'Location permission granted successfully!');
      } else {
        _showErrorDialog('Location Permission', result['error'] ?? 'Failed to get location permission');
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to request location permission: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Request camera permission
  Future<void> _requestCameraPermission() async {
    try {
      final granted = await _permissionService.requestCameraPermission();
      setState(() => _cameraPermission = granted);
      if (granted) {
        _showSuccessDialog('Camera Access', 'Camera permission granted successfully!');
      } else {
        _showErrorDialog('Camera Permission', 'Camera permission denied');
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to request camera permission: $e');
    }
  }

  // Request SMS permission
  Future<void> _requestSmsPermission() async {
    try {
      final granted = await _permissionService.requestSmsPermission();
      setState(() => _smsPermission = granted);
      if (granted) {
        _showSuccessDialog('SMS Access', 'SMS permission granted successfully!');
      } else {
        _showErrorDialog('SMS Permission', 'SMS permission denied');
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to request SMS permission: $e');
    }
  }

  // Request notification permission
  Future<void> _requestNotificationPermission() async {
    try {
      final granted = await _permissionService.requestNotificationPermission();
      setState(() => _notificationPermission = granted);
      if (granted) {
        _showSuccessDialog('Notifications', 'Notification permission granted successfully!');
      } else {
        _showErrorDialog('Notification Permission', 'Notification permission denied');
      }
    } catch (e) {
      _showErrorDialog('Error', 'Failed to request notification permission: $e');
    }
  }

  void _showSuccessDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // Request all permissions at once
  Future<void> _requestAllPermissions() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await _permissionService.requestAllPermissions();
      
      setState(() {
        _locationPermission = results['location'] ?? false;
        _cameraPermission = results['camera'] ?? false;
        _smsPermission = results['sms'] ?? false;
        _notificationPermission = results['notification'] ?? false;
      });

      // If location permission was granted, get location data
      if (results['location'] == true) {
        final locationResult = await _permissionService.requestLocationPermission();
        if (locationResult['granted'] == true) {
          _locationData = {
            'latitude': locationResult['latitude'],
            'longitude': locationResult['longitude'],
            'city': locationResult['city'],
            'state': locationResult['state'],
          };
        }
      }

      final grantedCount = results.values.where((granted) => granted).length;
      _showSuccessDialog(
        'Permissions Updated', 
        '$grantedCount out of 4 permissions granted successfully!'
      );
    } catch (e) {
      _showErrorDialog('Error', 'Failed to request permissions: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    if (_selectedCountry == null) {
      _showErrorDialog('Selection Required', 'Please select your country and currency.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

            // Create user preferences
      final preferences = await _preferencesService.createInitialPreferences(
        userId: userId,
        country: _selectedCountry!.name,
        countryCode: _selectedCountry!.code,
        defaultCurrency: _selectedCountry!.currencyCode,
        latitude: _locationData?['latitude'],
        longitude: _locationData?['longitude'],
        city: _locationData?['city'],
        state: _locationData?['state'],
      );
      debugPrint('Preferences: $preferences');

      // Update permissions and location data
      final updates = {
        'locationPermission': _locationPermission,
        'cameraPermission': _cameraPermission,
        'smsPermission': _smsPermission,
        'notificationPermission': _notificationPermission,
        'isFirstTimeSetup': false,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Add location data if available
      if (_locationData != null) {
        updates['latitude'] = _locationData!['latitude'];
        updates['longitude'] = _locationData!['longitude'];
        updates['city'] = _locationData!['city'];
        updates['state'] = _locationData!['state'];
      }

      await _preferencesService.updatePreferences(userId, updates);

      // Mark setup as complete
      await _preferencesService.markSetupComplete(userId);

      if (mounted) {
        // Navigate to home screen
        if (!mounted) return;
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error', 'Failed to save preferences: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showCountryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Your Country'),
        actions: Countries.all.map((country) {
          return CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _selectedCountry = country);
              Navigator.of(context).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(country.name),
                Row(
                  children: [
                    Text(country.flag),
                    const SizedBox(width: 8),
                    Text('${country.currencyCode} (${country.currencySymbol})'),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? CupertinoColors.activeGreen
                    : isActive 
                        ? AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context))
                        : CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCountrySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Country & Currency',
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize24,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
          ),
        ),
        SizedBox(height: ResponsiveConstants.spacing16),
        Text(
          'This helps us set the right currency and regional settings for your expense tracking.',
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize16,
            color: CupertinoColors.systemGrey,
          ),
        ),
        SizedBox(height: ResponsiveConstants.spacing24),
        
        // Country Selection Button
        CupertinoButton(
          onPressed: _showCountryPicker,
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveConstants.spacing16),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
              border: Border.all(
                color: CupertinoColors.systemGrey4,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (_selectedCountry != null) ...[
                  Text(_selectedCountry!.flag, style: const TextStyle(fontSize: 24)),
                  SizedBox(width: ResponsiveConstants.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCountry!.name,
                          style: TextStyle(
                            fontSize: ResponsiveConstants.fontSize16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                          ),
                        ),
                        Text(
                          '${_selectedCountry!.currencyCode} (${_selectedCountry!.currencySymbol})',
                          style: TextStyle(
                            fontSize: ResponsiveConstants.fontSize14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Icon(
                    CupertinoIcons.globe,
                    color: CupertinoColors.systemGrey,
                    size: ResponsiveConstants.iconSize24,
                  ),
                  SizedBox(width: ResponsiveConstants.spacing16),
                  Text(
                    'Select Country & Currency',
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize16,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
                const Spacer(),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: CupertinoColors.systemGrey,
                  size: ResponsiveConstants.iconSize20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'App Permissions',
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize24,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
          ),
        ),
        SizedBox(height: ResponsiveConstants.spacing16),
        Text(
          'These permissions help us provide better features for expense tracking.',
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize16,
            color: CupertinoColors.systemGrey,
          ),
        ),
        SizedBox(height: ResponsiveConstants.spacing24),
        
        // Permission toggles
        _buildPermissionToggle(
          title: 'Location Access',
          subtitle: 'For location-based expenses',
          icon: CupertinoIcons.location,
          value: _locationPermission,
          onChanged: (value) {
            if (value) {
              _requestLocationPermission();
            } else {
              setState(() => _locationPermission = false);
            }
          },
        ),
        
        _buildPermissionToggle(
          title: 'Camera Access',
          subtitle: 'For scanning receipts and bills',
          icon: CupertinoIcons.camera,
          value: _cameraPermission,
          onChanged: (value) {
            if (value) {
              _requestCameraPermission();
            } else {
              setState(() => _cameraPermission = false);
            }
          },
        ),
        

        
        _buildPermissionToggle(
          title: 'SMS Access',
          subtitle: 'For automatic expense detection',
          icon: CupertinoIcons.chat_bubble,
          value: _smsPermission,
          onChanged: (value) {
            if (value) {
              _requestSmsPermission();
            } else {
              setState(() => _smsPermission = false);
            }
          },
        ),
        

        
        _buildPermissionToggle(
          title: 'Push Notifications',
          subtitle: 'For expense reminders and updates',
          icon: CupertinoIcons.bell,
          value: _notificationPermission,
          onChanged: (value) {
            if (value) {
              _requestNotificationPermission();
            } else {
              setState(() => _notificationPermission = false);
            }
          },
        ),
        
        SizedBox(height: ResponsiveConstants.spacing24),
        
        // Request All Permissions Button
        SizedBox(
          width: double.infinity,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
              borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
            ),
            child: CupertinoButton(
              onPressed: _isLoading ? null : _requestAllPermissions,
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveConstants.spacing16,
              ),
              borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
              color: CupertinoColors.transparent,
              child: _isLoading
                  ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                  : Text(
                      'Request All Permissions',
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionToggle({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.spacing16),
      padding: EdgeInsets.all(ResponsiveConstants.spacing16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
        border: Border.all(
          color: CupertinoColors.systemGrey4,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
            size: ResponsiveConstants.iconSize24,
          ),
          SizedBox(width: ResponsiveConstants.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.fontSize16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.fontSize12,
                    color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Almost Done!',
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize24,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
          ),
        ),
        SizedBox(height: ResponsiveConstants.spacing16),
        Text(
          'Your preferences have been set up. You can always change these settings later in the app.',
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize16,
            color: CupertinoColors.systemGrey,
          ),
        ),
        SizedBox(height: ResponsiveConstants.spacing32),
        
        // Summary
        Container(
          padding: EdgeInsets.all(ResponsiveConstants.spacing16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Country', _selectedCountry?.name ?? 'Not selected'),
              _buildSummaryRow('Currency', '${_selectedCountry?.currencyCode ?? 'USD'} (${_selectedCountry?.currencySymbol ?? '\$'})'),
                             _buildSummaryRow('Permissions Granted', '${[_locationPermission, _cameraPermission, _smsPermission, _notificationPermission].where((p) => p).length}/4'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.spacing8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize14,
              color: CupertinoColors.systemGrey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize14,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            Navigator.of(context).pop();
          }
        }
      },
      child: CupertinoPageScaffold(
      backgroundColor: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Setup Preferences',
          style: TextStyle(
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: CupertinoColors.systemGroupedBackground,
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ResponsiveConstants.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_currentStep == 0) _buildCountrySelection(),
                    if (_currentStep == 1) _buildPermissionsStep(),
                    if (_currentStep == 2) _buildFinalStep(),
                    
                    SizedBox(height: ResponsiveConstants.spacing16),
                    
                    // Navigation buttons
                    if (_currentStep < 2) ...[
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                          borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                        ),
                        child: CupertinoButton(
                          onPressed: _selectedCountry == null ? null : () {
                            setState(() => _currentStep++);
                          },
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveConstants.spacing16,
                          ),
                          borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                          color: CupertinoColors.transparent,
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: ResponsiveConstants.fontSize18,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                          borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                        ),
                        child: CupertinoButton(
                          onPressed: _isLoading ? null : _savePreferences,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveConstants.spacing16,
                          ),
                          borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                          color: CupertinoColors.transparent,
                          child: _isLoading
                              ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                              : Text(
                                  'Complete Setup',
                                  style: TextStyle(
                                    fontSize: ResponsiveConstants.fontSize18,
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                    
                    if (_currentStep > 0) ...[
                      SizedBox(height: ResponsiveConstants.spacing16),
                      CupertinoButton(
                        onPressed: () {
                          setState(() => _currentStep--);
                        },
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveConstants.spacing16,
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontSize: ResponsiveConstants.fontSize16,
                            color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
