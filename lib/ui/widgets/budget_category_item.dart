import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/responsive_constants.dart';
import '../../models/budget_model.dart';
import 'currency_icon.dart';

class BudgetCategoryItem extends StatelessWidget {
  final BudgetModel budget;
  final VoidCallback? onTap;
  final String currency;

  const BudgetCategoryItem({
    super.key,
    required this.budget,
    this.onTap,
    this.currency = 'USD',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveConstants.spacing16),
        padding: EdgeInsets.all(ResponsiveConstants.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
          borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey4.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Category Header
            Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                  ),
                  child: Center(
                    child: Text(
                      budget.icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                
                SizedBox(width: ResponsiveConstants.spacing12),
                
                // Category Name and Change
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.name,
                        style: TextStyle(
                          fontSize: ResponsiveConstants.fontSize14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                        ),
                      ),
                      SizedBox(height: ResponsiveConstants.spacing2),
                      Text(
                        '${budget.isPositiveChange ? '+' : ''}${budget.changePercentage}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: budget.isPositiveChange 
                            ? const AppColors.primary 
                            : CupertinoColors.systemRed,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status and Percentage
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (budget.status == 'Near limit')
                      Text(
                        budget.status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.systemRed,
                        ),
                      ),
                    SizedBox(height: ResponsiveConstants.spacing2),
                    Text(
                      '${budget.spentPercentage.round()}%',
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveConstants.spacing16),
            
            // Progress Bar
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(ResponsiveConstants.radius4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (budget.spentPercentage / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getCategoryColor(),
                        borderRadius: BorderRadius.circular(ResponsiveConstants.radius4),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: ResponsiveConstants.spacing8),
                
                // Amount Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                                          Row(
                        children: [
                          CurrencyIcon(
                            currencyCode: currency,
                            size: 12,
                          ),
                        SizedBox(width: ResponsiveConstants.spacing4),
                        Text(
                          '${budget.spentAmount.toStringAsFixed(0)} / ${budget.allocatedAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: ResponsiveConstants.fontSize12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${budget.spentPercentage.round()}%',
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (budget.name) {
      case 'Food & Dining':
        return const AppColors.primary;
      case 'Transportation':
        return const AppColors.info;
      case 'Bills & Utilities':
        return const AppColors.error;
      case 'Entertainment':
        return const AppColors.chart5;
      default:
        return const AppColors.primary;
    }
  }
}
