import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../models/budget_model.dart';
import '../../../services/user_service.dart';
import '../../../providers/budget_provider.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final TextEditingController _amountController = TextEditingController();
  
  String _selectedCategory = 'Food & Dining';
  String _selectedIcon = '🍽️';
  String _selectedPeriod = 'Monthly';
  bool _isLoading = false;

  final List<Map<String, String>> _categories = [
    {'name': 'Food & Dining', 'icon': '🍽️'},
    {'name': 'Transportation', 'icon': '🚗'},
    {'name': 'Entertainment', 'icon': '💳'},
    {'name': 'Shopping', 'icon': '🛍️'},
    {'name': 'Healthcare', 'icon': '🏥'},
    {'name': 'Education', 'icon': '📚'},
    {'name': 'Travel', 'icon': '✈️'},
    {'name': 'Utilities', 'icon': '⚡'},
    {'name': 'Fitness', 'icon': '💪'},
    {'name': 'Other', 'icon': '📝'},
  ];

  final List<String> _periods = ['Weekly', 'Monthly', 'Yearly'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    if (_amountController.text.isEmpty) {
      _showErrorDialog('Please enter a budget amount');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorDialog('Please enter a valid amount');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user ID
      final userService = UserService();
      final currentUser = await userService.getCurrentUser();
      
      if (currentUser == null) {
        _showErrorDialog('User not found. Please log in again.');
        return;
      }

      final budget = BudgetModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _selectedCategory,
        icon: _selectedIcon,
        allocatedAmount: amount,
        spentAmount: 0.0,
        periodType: _selectedPeriod.toLowerCase(),
        startDate: _getStartDate(),
        endDate: _getEndDate(),
        color: '#2ECC71',
        userId: currentUser.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
      await budgetProvider.addBudget(budget);
      
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Failed to create budget. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  DateTime _getEndDate() {
    final now = DateTime.now();
    switch (_selectedPeriod.toLowerCase()) {
      case 'weekly':
        // End of current week (Sunday)
        final daysUntilSunday = 7 - now.weekday;
        return DateTime(now.year, now.month, now.day + daysUntilSunday, 23, 59, 59);
      case 'yearly':
        // End of current year
        return DateTime(now.year, 12, 31, 23, 59, 59);
      default: // monthly
        // End of current month
        return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }
  }

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedPeriod.toLowerCase()) {
      case 'weekly':
        // Start of current week (Monday)
        final daysSinceMonday = now.weekday - 1;
        return DateTime(now.year, now.month, now.day - daysSinceMonday);
      case 'yearly':
        // Start of current year
        return DateTime(now.year, 1, 1);
      default: // monthly
        // Start of current month
        return DateTime(now.year, now.month, 1);
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.spacing16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedCategory = _categories[index]['name']!;
                    _selectedIcon = _categories[index]['icon']!;
                  });
                },
                children: _categories.map((category) => Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(category['icon']!, style: const TextStyle(fontSize: 20)),
                      SizedBox(width: ResponsiveConstants.spacing8),
                      Text(category['name']!),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPeriodPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: ResponsiveConstants.spacing16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  Text(
                    'Select Period',
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedPeriod = _periods[index];
                  });
                },
                children: _periods.map((period) => Center(
                  child: Text(period),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Add Budget',
          style: TextStyle(
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(
            CupertinoIcons.back,
            color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
          ),
        ),
        trailing: _isLoading
            ? const CupertinoActivityIndicator(radius: 10)
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saveBudget,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
      child: Container(
        color: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(ResponsiveConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Selection
                _buildSectionTitle('Category'),
                SizedBox(height: ResponsiveConstants.spacing8),
                _buildSelectionTile(
                  title: _selectedCategory,
                  subtitle: 'Tap to change category',
                  icon: _selectedIcon,
                  onTap: _showCategoryPicker,
                ),
                
                SizedBox(height: ResponsiveConstants.spacing24),
                
                // Budget Amount
                _buildSectionTitle('Budget Amount'),
                SizedBox(height: ResponsiveConstants.spacing8),
                Container(
                  padding: EdgeInsets.all(ResponsiveConstants.spacing16),
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
                    borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                    border: Border.all(
                      color: CupertinoColors.systemGrey4.resolveFrom(context),
                      width: 0.5,
                    ),
                  ),
                  child: CupertinoTextField(
                    controller: _amountController,
                    placeholder: 'Enter amount',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefix: Text(
                      '\$ ',
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                      ),
                    ),
                    decoration: null,
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize16,
                      color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                    ),
                  ),
                ),
                
                SizedBox(height: ResponsiveConstants.spacing24),
                
                // Period Selection
                _buildSectionTitle('Budget Period'),
                SizedBox(height: ResponsiveConstants.spacing8),
                _buildSelectionTile(
                  title: _selectedPeriod,
                  subtitle: 'How often this budget resets',
                  icon: '📅',
                  onTap: _showPeriodPicker,
                ),
                
                SizedBox(height: ResponsiveConstants.spacing40),
                
                // Info Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(ResponsiveConstants.spacing16),
                  decoration: BoxDecoration(
                    color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                    border: Border.all(
                      color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.info_circle,
                            color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                            size: ResponsiveConstants.iconSize16,
                          ),
                          SizedBox(width: ResponsiveConstants.spacing8),
                          Text(
                            'Budget Tips',
                            style: TextStyle(
                              fontSize: ResponsiveConstants.fontSize14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveConstants.spacing8),
                      Text(
                        '• Start with realistic amounts based on your spending history\n• You can adjust budget limits anytime\n• Track your progress with real-time updates',
                        style: TextStyle(
                          fontSize: ResponsiveConstants.fontSize12,
                          color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: ResponsiveConstants.spacing40),
                
                // Save Button at Bottom
                Container(
                  width: double.infinity,
                  height: 50,
                  child: CupertinoButton(
                    onPressed: _isLoading ? null : _saveBudget,
                    color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                    borderRadius: BorderRadius.circular(10),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CupertinoActivityIndicator(
                                radius: 10,
                                color: CupertinoColors.white,
                              ),
                              SizedBox(width: ResponsiveConstants.spacing8),
                              Text(
                                'Saving...',
                                style: TextStyle(
                                  fontSize: ResponsiveConstants.fontSize14,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Save Budget',
                            style: TextStyle(
                              fontSize: ResponsiveConstants.fontSize14,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white,
                            ),
                          ),
                  ),
                ),
                
                SizedBox(height: ResponsiveConstants.spacing20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ResponsiveConstants.fontSize16,
        fontWeight: FontWeight.w600,
        color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
      ),
    );
  }

  Widget _buildSelectionTile({
    required String title,
    required String subtitle,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ResponsiveConstants.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
          borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
          border: Border.all(
            color: CupertinoColors.systemGrey4.resolveFrom(context),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(ResponsiveConstants.radius8),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            SizedBox(width: ResponsiveConstants.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.spacing2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize12,
                      color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
              size: ResponsiveConstants.iconSize16,
            ),
          ],
        ),
      ),
    );
  }
}
