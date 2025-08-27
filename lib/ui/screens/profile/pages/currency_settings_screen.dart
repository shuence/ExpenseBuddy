import 'package:flutter/cupertino.dart';
import '../../../../models/user_preferences_model.dart';
import '../../../../services/user_preferences_service.dart';
import '../widgets/settings_item.dart';
import '../widgets/settings_section.dart';
import '../../../widgets/currency_icon.dart';

class CurrencySettingsScreen extends StatefulWidget {
  const CurrencySettingsScreen({super.key});

  @override
  State<CurrencySettingsScreen> createState() => _CurrencySettingsScreenState();
}

class _CurrencySettingsScreenState extends State<CurrencySettingsScreen> {
  final UserPreferencesService _preferencesService = UserPreferencesService();
  UserPreferencesModel? _preferences;
  bool _isLoading = true;

  // Popular currencies
  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': 'A\$'},
    {'code': 'CAD', 'name': 'Canadian Dollar', 'symbol': 'C\$'},
    {'code': 'CHF', 'name': 'Swiss Franc', 'symbol': 'CHF'},
    {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥'},
    {'code': 'INR', 'name': 'Indian Rupee', 'symbol': '₹'},
    {'code': 'KRW', 'name': 'South Korean Won', 'symbol': '₩'},
    {'code': 'MXN', 'name': 'Mexican Peso', 'symbol': '\$'},
    {'code': 'BRL', 'name': 'Brazilian Real', 'symbol': 'R\$'},
    {'code': 'RUB', 'name': 'Russian Ruble', 'symbol': '₽'},
    {'code': 'SGD', 'name': 'Singapore Dollar', 'symbol': 'S\$'},
    {'code': 'HKD', 'name': 'Hong Kong Dollar', 'symbol': 'HK\$'},
  ];

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
        middle: Text('Currency'),
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
                      
                      // Current Currency Section
                      const Text(
                        'Current Currency',
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
                              child: Center(
                                child: CurrencyIcon(
                                  currencyCode: _preferences?.defaultCurrency ?? 'USD',
                                  size: 18,
                                ),
                              ),
                            ),
                            title: _getCurrentCurrencyName(),
                            subtitle: _preferences?.defaultCurrency ?? 'USD - United States Dollar',
                            showChevron: false,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Select Currency Section
                      const Text(
                        'Select Currency',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      SettingsSection(
                        children: _currencies.map((currency) {
                          final isSelected = _preferences?.defaultCurrency == currency['code'];
                          return SettingsItem(
                            icon: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? CupertinoColors.activeBlue 
                                    : CupertinoColors.systemGrey4,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: CurrencyIcon(
                                  currencyCode: currency['code']!,
                                  size: 16,
                                ),
                              ),
                            ),
                            title: currency['name']!,
                            subtitle: '${currency['code']} - ${currency['name']}',
                            trailing: isSelected
                                ? const Icon(
                                    CupertinoIcons.check_mark,
                                    color: CupertinoColors.activeBlue,
                                    size: 20,
                                  )
                                : null,
                            showChevron: false,
                            onTap: () => _selectCurrency(currency['code']!),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Currency Info
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
                                  'About Currency Settings',
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
                              'Your selected currency will be used for all transactions and reports. You can change this setting at any time.',
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

  String _getCurrentCurrencyName() {
    final currentCode = _preferences?.defaultCurrency ?? 'USD';
    final currency = _currencies.firstWhere(
      (c) => c['code'] == currentCode,
      orElse: () => {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
    );
    return currency['name']!;
  }

  Future<void> _selectCurrency(String currencyCode) async {
    try {
      final userId = _preferencesService.currentUserId;
      if (userId != null) {
        await _preferencesService.updatePreferences(userId, {
          'defaultCurrency': currencyCode,
        });
        
        // Refresh preferences
        await _loadPreferences();
        
        // Show success feedback
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Currency Updated'),
              content: Text('Your default currency has been changed to $currencyCode.'),
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
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to update currency. Please try again.'),
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
  }
}
