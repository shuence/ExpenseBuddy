import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/responsive_constants.dart';
import '../../models/budget_model.dart';
import 'circular_progress_indicator.dart';
import 'currency_icon.dart';

class BudgetSummaryCard extends StatelessWidget {
  final BudgetSummary budgetSummary;
  final String currency;

  const BudgetSummaryCard({
    super.key,
    required this.budgetSummary,
    this.currency = 'USD',
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final isDesktop = context.isDesktop;
    final isMobile = context.isMobile;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getResponsivePadding(isTablet, isDesktop)),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4.withOpacity(0.3),
            blurRadius: isDesktop ? 16 : 12,
            offset: Offset(0, isDesktop ? 6 : 4),
          ),
        ],
      ),
      child: isMobile ? _buildMobileLayout() : _buildTabletDesktopLayout(isTablet, isDesktop),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Circular Progress
        CircularProgressWidget(
          percentage: budgetSummary.spentPercentage,
          progressColor: _getProgressColor(budgetSummary.spentPercentage),
          backgroundColor: CupertinoColors.systemGrey5,
          child: Builder(
            builder: (context) => Center(
              child: Text(
                '${budgetSummary.spentPercentage.round()}%',
                style: TextStyle(
                  fontSize: ResponsiveConstants.fontSize14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(height: ResponsiveConstants.spacing16),
        
        // Budget Details
        _buildBudgetDetails(ResponsiveConstants.fontSize12, ResponsiveConstants.fontSize16, ResponsiveConstants.fontSize12),
      ],
    );
  }

  Widget _buildTabletDesktopLayout(bool isTablet, bool isDesktop) {
    return Row(
      children: [
        // Circular Progress
        CircularProgressWidget(
          percentage: budgetSummary.spentPercentage,
          progressColor: _getProgressColor(budgetSummary.spentPercentage),
          backgroundColor: CupertinoColors.systemGrey5,
          child: Builder(
            builder: (context) => Center(
              child: Text(
                '${budgetSummary.spentPercentage.round()}%',
                style: TextStyle(
                  fontSize: isDesktop ? ResponsiveConstants.fontSize18 : ResponsiveConstants.fontSize16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(width: isDesktop ? ResponsiveConstants.spacing32 : ResponsiveConstants.spacing24),
        
        // Budget Details
        Expanded(
          child: _buildBudgetDetails(
            isDesktop ? ResponsiveConstants.fontSize14 : ResponsiveConstants.fontSize12,
            isDesktop ? ResponsiveConstants.fontSize20 : ResponsiveConstants.fontSize18,
            isDesktop ? ResponsiveConstants.fontSize12 : ResponsiveConstants.fontSize12,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetDetails(double titleFontSize, double amountFontSize, double spentFontSize) {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: ResponsiveConstants.spacing12,
                height: ResponsiveConstants.spacing12,
                decoration: BoxDecoration(
                  color: _getProgressColor(budgetSummary.spentPercentage),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: ResponsiveConstants.spacing8),
              Text(
                'Total Budget',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveConstants.spacing8),
          
          Row(
                                    children: [
                          CurrencyIcon(
                            currencyCode: currency,
                            size: amountFontSize * 0.8,
                          ),
              SizedBox(width: ResponsiveConstants.spacing4),
              Text(
                '${budgetSummary.totalSpent.toStringAsFixed(0)} / ${budgetSummary.totalBudget.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: amountFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveConstants.spacing6),
          
          Text(
            '${budgetSummary.spentPercentage.round()}% spent',
            style: TextStyle(
              fontSize: spentFontSize,
              fontWeight: FontWeight.w500,
              color: _getProgressColor(budgetSummary.spentPercentage),
            ),
          ),
        ],
      ),
    );
  }

  double _getResponsivePadding(bool isTablet, bool isDesktop) {
    if (isDesktop) return ResponsiveConstants.spacing32;
    if (isTablet) return ResponsiveConstants.spacing24;
    return ResponsiveConstants.spacing20;
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 90) return CupertinoColors.systemRed;
    if (percentage >= 75) return CupertinoColors.systemOrange;
    return const Color(0xFF2ECC71);
  }
}
