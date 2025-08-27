import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../services/user_service.dart';
import '../../../services/user_preferences_service.dart';
import '../../../providers/budget_provider.dart';
import '../../widgets/budget_header.dart';
import '../../widgets/budget_summary_card.dart';
import '../../widgets/budget_category_item.dart';
import 'add_budget_screen.dart';
import 'adjust_budget_screen.dart';
import 'budget_details_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final UserService _userService = UserService();
  final UserPreferencesService _preferencesService = UserPreferencesService();
  late DateTime _selectedDate;
  List<DateTime> _availableMonths = [];
  String _userCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _generateAvailableMonths();
    _loadUserPreferences();
    _loadBudgetData();
  }

  void _generateAvailableMonths() {
    final now = DateTime.now();
    _availableMonths = [];
    
    // Generate months from 6 months ago to 6 months in the future
    for (int i = -6; i <= 6; i++) {
      final month = DateTime(now.year, now.month + i, 1);
      _availableMonths.add(month);
    }
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String get _currentMonthString => _formatMonth(_selectedDate);

  Future<void> _loadUserPreferences() async {
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null) {
        final preferences = await _preferencesService.getUserPreferences(currentUser.uid);
        setState(() {
          _userCurrency = preferences?.defaultCurrency ?? 'USD';
        });
      }
    } catch (e) {
      debugPrint('Error loading user preferences: $e');
    }
  }

  Future<void> _loadBudgetData() async {
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null && mounted) {
        final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
        await budgetProvider.loadBudgetsForMonth(currentUser.uid, _selectedDate);
      }
    } catch (e) {
      debugPrint('Error loading budget data: $e');
    }
  }

  Future<void> _refreshBudgetData() async {
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null && mounted) {
        final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
        await budgetProvider.refreshBudgetsForMonth(currentUser.uid, _selectedDate);
      }
    } catch (e) {
      debugPrint('Error refreshing budget data: $e');
    }
  }

  void _showMonthPicker() {
    int selectedIndex = _availableMonths.indexWhere((month) => 
      month.year == _selectedDate.year && month.month == _selectedDate.month);
    if (selectedIndex == -1) selectedIndex = 6; // Default to current month

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
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
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                      ),
                    ),
                  ),
                  Text(
                    'Select Month',
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _loadBudgetData(); // Reload data for selected month
                    },
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(initialItem: selectedIndex),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedDate = _availableMonths[index];
                  });
                },
                children: _availableMonths.map((month) => 
                  Center(child: Text(_formatMonth(month)))
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddBudget() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const AddBudgetScreen(),
      ),
    );
    
    if (result == true) {
      // Refresh budget data after adding new budget
      await _loadBudgetData();
    }
  }

  void _navigateToAdjustBudgets() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const AdjustBudgetScreen(),
      ),
    );
    
    if (result == true) {
      // Refresh budget data after adjusting budgets
      await _loadBudgetData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Budget',
          style: TextStyle(
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
        border: null,
        leading: CupertinoNavigationBarBackButton(
          color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
      child: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          if (budgetProvider.isLoading) {
            return const Center(
              child: CupertinoActivityIndicator(radius: 16),
            );
          }
          
          if (budgetProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 64,
                    color: CupertinoColors.systemOrange,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error loading budgets',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    budgetProvider.error!,
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  CupertinoButton.filled(
                    onPressed: _loadBudgetData,
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          final budgetSummary = budgetProvider.budgetSummary;
          final budgets = budgetProvider.budgets;
          
          return CustomScrollView(
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: _refreshBudgetData,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _getHorizontalPadding(context),
                    vertical: _getVerticalPadding(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with month selector and title
                      BudgetHeader(
                        currentMonth: _currentMonthString,
                        onMonthTap: _showMonthPicker,
                      ),
                      
                      SizedBox(height: ResponsiveConstants.spacing16),
                      
                      // Action Buttons at top
                      _buildActionButtons(context),
                      
                      SizedBox(height: _getSectionSpacing(context)),
                      
                      // Budget Summary Card with circular progress
                      if (budgetSummary != null)
                        BudgetSummaryCard(
                          budgetSummary: budgetSummary,
                          currency: _userCurrency,
                        )
                      else if (budgets.isEmpty)
                        _buildEmptyBudgetCard(context),
                      
                      SizedBox(height: _getSectionSpacing(context)),
                    ],
                  ),
                ),
              ),
              
              // Budget Categories List
              if (budgets.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _getHorizontalPadding(context),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final budget = budgets[index];
                        return BudgetCategoryItem(
                          budget: budget,
                          currency: _userCurrency,
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => BudgetDetailsScreen(budget: budget),
                              ),
                            );
                          },
                        );
                      },
                      childCount: budgets.length,
                    ),
                  ),
                ),
              
              // Bottom padding for navigation bar
              SliverToBoxAdapter(
                child: SizedBox(height: _getBottomPadding(context)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyBudgetCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveConstants.spacing24),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
        border: Border.all(
          color: CupertinoColors.systemGrey5.resolveFrom(context),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.chart_pie,
            size: 64,
            color: CupertinoColors.systemGrey3,
          ),
          SizedBox(height: ResponsiveConstants.spacing16),
          Text(
            'No budgets yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
          SizedBox(height: ResponsiveConstants.spacing8),
          Text(
            'Create your first budget to start tracking your spending',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveConstants.spacing16),
          CupertinoButton.filled(
            onPressed: _navigateToAddBudget,
            child: Text('Create Budget'),
          ),
        ],
      ),
    );
  }

  // Responsive helper methods
  double _getHorizontalPadding(BuildContext context) {
    if (context.isDesktop) return ResponsiveConstants.spacing24;
    if (context.isTablet) return ResponsiveConstants.spacing20;
    return ResponsiveConstants.spacing16;
  }

  double _getVerticalPadding(BuildContext context) {
    if (context.isDesktop) return ResponsiveConstants.spacing16;
    if (context.isTablet) return ResponsiveConstants.spacing12;
    return ResponsiveConstants.spacing12;
  }

  double _getSectionSpacing(BuildContext context) {
    if (context.isDesktop) return ResponsiveConstants.spacing40;
    if (context.isTablet) return ResponsiveConstants.spacing32;
    return ResponsiveConstants.spacing24;
  }

  double _getBottomPadding(BuildContext context) {
    if (context.isDesktop) return ResponsiveConstants.spacing96;
    if (context.isTablet) return ResponsiveConstants.spacing80;
    return ResponsiveConstants.spacing80;
  }

  Widget _buildActionButtons(BuildContext context) {
    final isTablet = context.isTablet;
    final isDesktop = context.isDesktop;
    
    return Flex(
      direction: isDesktop ? Axis.horizontal : Axis.horizontal,
      children: [
        // Add Budget Button
        Expanded(
          child: CupertinoButton(
            onPressed: _navigateToAddBudget,
            color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
            borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
            padding: EdgeInsets.symmetric(
              vertical: _getButtonPadding(isTablet, isDesktop),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.add,
                  color: CupertinoColors.white,
                  size: _getButtonIconSize(isTablet, isDesktop),
                ),
                SizedBox(width: ResponsiveConstants.spacing8),
                Text(
                  'Add Budget',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: _getButtonTextSize(isTablet, isDesktop),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(width: ResponsiveConstants.spacing12),
        
        // Adjust Limits Button
        Expanded(
          child: CupertinoButton(
            onPressed: _navigateToAdjustBudgets,
            color: CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
            padding: EdgeInsets.symmetric(
              vertical: _getButtonPadding(isTablet, isDesktop),
            ),
            child: Text(
              'Adjust Limits',
              style: TextStyle(
                color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                fontWeight: FontWeight.w600,
                fontSize: _getButtonTextSize(isTablet, isDesktop),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _getButtonPadding(bool isTablet, bool isDesktop) {
    if (isDesktop) return ResponsiveConstants.spacing16;
    if (isTablet) return ResponsiveConstants.spacing12;
    return ResponsiveConstants.spacing12;
  }

  double _getButtonIconSize(bool isTablet, bool isDesktop) {
    if (isDesktop) return ResponsiveConstants.iconSize20;
    if (isTablet) return ResponsiveConstants.iconSize20;
    return 18.0;
  }

  double _getButtonTextSize(bool isTablet, bool isDesktop) {
    if (isDesktop) return ResponsiveConstants.fontSize14;
    if (isTablet) return ResponsiveConstants.fontSize14;
    return ResponsiveConstants.fontSize12;
  }
}