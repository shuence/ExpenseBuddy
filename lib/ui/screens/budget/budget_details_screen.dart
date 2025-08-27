import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../models/budget_model.dart';
import '../../../models/user_preferences_model.dart';
import '../../../services/user_preferences_service.dart';
import '../../../utils/currency_utils.dart';
import '../../widgets/currency_icon.dart';

class BudgetDetailsScreen extends StatefulWidget {
  final BudgetModel budget;

  const BudgetDetailsScreen({
    super.key,
    required this.budget,
  });

  @override
  State<BudgetDetailsScreen> createState() => _BudgetDetailsScreenState();
}

class _BudgetDetailsScreenState extends State<BudgetDetailsScreen> {
  final UserPreferencesService _preferencesService = UserPreferencesService();
  UserPreferencesModel? _userPreferences;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    try {
      final currentUser = await _preferencesService.currentUserId;
      if (currentUser != null) {
        final preferences = await _preferencesService.getUserPreferences(currentUser);
        setState(() {
          _userPreferences = preferences;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user preferences: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadUserPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.budget.name,
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
          ? const Center(child: CupertinoActivityIndicator(radius: 16))
          : CustomScrollView(
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: _refreshData,
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
                        // Budget Overview Card
                        _buildBudgetOverviewCard(context),
                        
                        SizedBox(height: _getSectionSpacing(context)),
                        
                        // Spending Progress Section
                        _buildSpendingProgressSection(context),
                        
                        SizedBox(height: _getSectionSpacing(context)),
                        
                        // Budget Details Section
                        _buildBudgetDetailsSection(context),
                        
                        SizedBox(height: _getSectionSpacing(context)),
                        
                        // Recent Transactions Section
                        _buildRecentTransactionsSection(context),
                      ],
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

  Widget _buildBudgetOverviewCard(BuildContext context) {
    final currencyCode = _userPreferences?.defaultCurrency ?? 'USD';
    final currencySymbol = CurrencyUtils.getCurrencySymbol(currencyCode);
    final currencyName = CurrencyUtils.getCurrencyName(currencyCode);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveConstants.spacing24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCategoryColor(),
            _getCategoryColor().withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius20),
        boxShadow: [
          BoxShadow(
            color: _getCategoryColor().withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and currency info
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
                ),
                child: Center(
                  child: Text(
                    widget.budget.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              
              SizedBox(width: ResponsiveConstants.spacing16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.budget.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.spacing4),
                    Row(
                      children: [
                        CurrencyIcon(
                          currencyCode: currencyCode,
                          size: 16,
                        ),
                        SizedBox(width: ResponsiveConstants.spacing4),
                        Text(
                          currencyName,
                          style: TextStyle(
                            fontSize: ResponsiveConstants.fontSize14,
                            color: CupertinoColors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveConstants.spacing24),
          
          // Amount Information
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent',
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize14,
                        color: CupertinoColors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.spacing4),
                    Text(
                      '$currencySymbol${widget.budget.spentAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Budget',
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize14,
                        color: CupertinoColors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: ResponsiveConstants.spacing4),
                    Text(
                      '$currencySymbol${widget.budget.allocatedAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveConstants.spacing16),
          
          // Remaining Amount
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveConstants.spacing16),
            decoration: BoxDecoration(
              color: CupertinoColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remaining',
                  style: TextStyle(
                    fontSize: ResponsiveConstants.fontSize14,
                    color: CupertinoColors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  '$currencySymbol${widget.budget.remainingAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingProgressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending Progress',
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize18,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
          ),
        ),
        
        SizedBox(height: ResponsiveConstants.spacing16),
        
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(ResponsiveConstants.spacing20),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
            borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
            border: Border.all(
              color: CupertinoColors.systemGrey5.resolveFrom(context),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Progress Bar
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(ResponsiveConstants.radius8),
                    ),
                  ),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (widget.budget.spentPercentage / 100).clamp(0.0, 1.0),
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(),
                        borderRadius: BorderRadius.circular(ResponsiveConstants.radius8),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: ResponsiveConstants.spacing16),
              
              // Progress Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.budget.spentPercentage.round()}% used',
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveConstants.spacing8,
                      vertical: ResponsiveConstants.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ResponsiveConstants.radius8),
                    ),
                    child: Text(
                      widget.budget.status,
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetDetailsSection(BuildContext context) {
    final currencyCode = _userPreferences?.defaultCurrency ?? 'USD';
    final currencySymbol = CurrencyUtils.getCurrencySymbol(currencyCode);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Details',
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize18,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
          ),
        ),
        
        SizedBox(height: ResponsiveConstants.spacing16),
        
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(ResponsiveConstants.spacing20),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
            borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
            border: Border.all(
              color: CupertinoColors.systemGrey5.resolveFrom(context),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildDetailRow(
                context,
                'Period Type',
                widget.budget.periodType.capitalize(),
                CupertinoIcons.calendar,
              ),
              _buildDetailRow(
                context,
                'Start Date',
                _formatDate(widget.budget.startDate),
                CupertinoIcons.calendar_today,
              ),
              _buildDetailRow(
                context,
                'End Date',
                _formatDate(widget.budget.endDate),
                CupertinoIcons.calendar_today,
              ),
              _buildDetailRow(
                context,
                'Allocated Amount',
                '$currencySymbol${widget.budget.allocatedAmount.toStringAsFixed(2)}',
                CupertinoIcons.money_dollar_circle,
              ),
              _buildDetailRow(
                context,
                'Spent Amount',
                '$currencySymbol${widget.budget.spentAmount.toStringAsFixed(2)}',
                CupertinoIcons.money_dollar,
              ),
              _buildDetailRow(
                context,
                'Remaining Amount',
                '$currencySymbol${widget.budget.remainingAmount.toStringAsFixed(2)}',
                CupertinoIcons.money_dollar_circle_fill,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize18,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
          ),
        ),
        
        SizedBox(height: ResponsiveConstants.spacing16),
        
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(ResponsiveConstants.spacing20),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
            borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
            border: Border.all(
              color: CupertinoColors.systemGrey5.resolveFrom(context),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                CupertinoIcons.doc_text,
                size: 48,
                color: CupertinoColors.systemGrey3,
              ),
              SizedBox(height: ResponsiveConstants.spacing16),
              Text(
                'No transactions yet',
                style: TextStyle(
                  fontSize: ResponsiveConstants.fontSize16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                ),
              ),
              SizedBox(height: ResponsiveConstants.spacing8),
              Text(
                'Transactions for this budget will appear here',
                style: TextStyle(
                  fontSize: ResponsiveConstants.fontSize14,
                  color: CupertinoColors.systemGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveConstants.spacing16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getCategoryColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveConstants.radius8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: _getCategoryColor(),
            ),
          ),
          
          SizedBox(width: ResponsiveConstants.spacing12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.fontSize12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                SizedBox(height: ResponsiveConstants.spacing2),
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
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    switch (widget.budget.name) {
      case 'Food & Dining':
        return const Color(0xFF2ECC71);
      case 'Transportation':
        return const Color(0xFF3498DB);
      case 'Bills & Utilities':
        return const Color(0xFFE74C3C);
      case 'Entertainment':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFF2ECC71);
    }
  }

  Color _getStatusColor() {
    switch (widget.budget.status) {
      case 'Near limit':
        return CupertinoColors.systemRed;
      case 'Warning':
        return CupertinoColors.systemOrange;
      case 'On track':
        return const Color(0xFF2ECC71);
      default:
        return CupertinoColors.systemGrey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
