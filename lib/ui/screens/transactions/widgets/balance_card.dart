import 'package:flutter/cupertino.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/responsive_constants.dart';

class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final String currency;
  final String period;
  final double? monthlyChange;
  final bool? isIncreasePositive;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    this.currency = 'USD',
    this.period = 'This Month',
    this.monthlyChange,
    this.isIncreasePositive,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    
    return Container(
              margin: EdgeInsets.symmetric(
                horizontal: ResponsiveConstants.spacing20,
                vertical: ResponsiveConstants.spacing8,
              ),
              padding: EdgeInsets.all(ResponsiveConstants.spacing24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.getPrimaryColor(brightness),
                    AppTheme.getPrimaryColor(brightness).withOpacity(0.8),
                    AppTheme.getAccentColor(brightness).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(ResponsiveConstants.radius24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getPrimaryColor(brightness).withOpacity(0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppTheme.getPrimaryColor(brightness).withOpacity(0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          fontSize: ResponsiveConstants.fontSize14,
                          color: CupertinoColors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveConstants.spacing8,
                          vertical: ResponsiveConstants.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                        ),
                        child: Text(
                          period,
                          style: TextStyle(
                            fontSize: ResponsiveConstants.fontSize12,
                            color: CupertinoColors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: ResponsiveConstants.spacing16),
                  
                  // Balance Amount
                  Text(
                    _formatCurrency(totalBalance, currency),
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize28,
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  
                  SizedBox(height: ResponsiveConstants.spacing12),
                  
                  // Monthly Change (if provided)
                  if (monthlyChange != null) ...[
                    Row(
                      children: [
                        Icon(
                          isIncreasePositive == true
                              ? CupertinoIcons.arrow_up_right
                              : CupertinoIcons.arrow_down_right,
                          color: CupertinoColors.white.withOpacity(0.8),
                          size: ResponsiveConstants.iconSize16,
                        ),
                        SizedBox(width: ResponsiveConstants.spacing4),
                        Text(
                          '${isIncreasePositive == true ? '+' : ''}${_formatCurrency(monthlyChange!, currency)}',
                          style: TextStyle(
                            fontSize: ResponsiveConstants.fontSize12,
                            color: CupertinoColors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: ResponsiveConstants.spacing8),
                        Text(
                          'vs last month',
                          style: TextStyle(
                            fontSize: ResponsiveConstants.fontSize12,
                            color: CupertinoColors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                  

                ],
              ),
            );
  }

  String _formatCurrency(double amount, String currency) {
    String symbol = '\$';
    switch (currency.toUpperCase()) {
      case 'EUR':
        symbol = '€';
        break;
      case 'GBP':
        symbol = '£';
        break;
      case 'JPY':
        symbol = '¥';
        break;
      case 'INR':
        symbol = '₹';
        break;
      default:
        symbol = '\$';
    }
    
    // Format with commas for thousands
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formattedAmount = amount.toStringAsFixed(2).replaceAllMapped(formatter, (Match m) => '${m[1]},');
    
    return '$symbol$formattedAmount';
  }
}
