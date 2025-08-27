import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../models/budget_model.dart';
import '../../../services/budget_service.dart';
import '../../widgets/budget_header.dart';
import '../../widgets/budget_summary_card.dart';
import '../../widgets/budget_category_item.dart';
import 'add_budget_screen.dart';
import 'adjust_budget_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final BudgetService _budgetService = BudgetService();
  BudgetSummary? _budgetSummary;
  bool _isLoading = true;
  String _currentMonth = 'September 2023';

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  Future<void> _loadBudgetData() async {
    try {
      final budgetSummary = await _budgetService.getBudgetSummary();
      if (mounted) {
        setState(() {
          _budgetSummary = budgetSummary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMonthPicker() {
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
                      // TODO: Update month selection
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
                onSelectedItemChanged: (index) {
                  // TODO: Handle month selection
                },
                children: const [
                  Center(child: Text('January 2023')),
                  Center(child: Text('February 2023')),
                  Center(child: Text('March 2023')),
                  Center(child: Text('April 2023')),
                  Center(child: Text('May 2023')),
                  Center(child: Text('June 2023')),
                  Center(child: Text('July 2023')),
                  Center(child: Text('August 2023')),
                  Center(child: Text('September 2023')),
                  Center(child: Text('October 2023')),
                  Center(child: Text('November 2023')),
                  Center(child: Text('December 2023')),
                ],
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
      child: _isLoading
          ? const Center(
              child: CupertinoActivityIndicator(radius: 16),
            )
          : CustomScrollView(
              slivers: [
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
                            currentMonth: _currentMonth,
                            onMonthTap: _showMonthPicker,
                          ),
                          
                          SizedBox(height: ResponsiveConstants.spacing16),
                          
                          // Action Buttons at top
                          _buildActionButtons(context),
                          
                          SizedBox(height: _getSectionSpacing(context)),
                          
                          // Budget Summary Card with circular progress
                          if (_budgetSummary != null)
                            BudgetSummaryCard(budgetSummary: _budgetSummary!),
                          
                          SizedBox(height: _getSectionSpacing(context)),
                        ],
                      ),
                    ),
                  ),
                  
                  // Budget Categories List
                  if (_budgetSummary != null)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: _getHorizontalPadding(context),
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final budget = _budgetSummary!.budgets[index];
                            return BudgetCategoryItem(
                              budget: budget,
                              onTap: () {
                                // TODO: Navigate to budget details
                              },
                            );
                          },
                          childCount: _budgetSummary!.budgets.length,
                        ),
                      ),
                    ),
                  
                  // Bottom padding for navigation bar
                  SliverToBoxAdapter(
                    child: SizedBox(height: _getBottomPadding(context)),
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