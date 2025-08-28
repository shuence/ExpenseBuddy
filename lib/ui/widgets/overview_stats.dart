import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/responsive_constants.dart';
import '../../utils/currency_utils.dart';

class OverviewStats extends StatelessWidget {
  final double income;
  final double expenses;
  final double savings;
  final String currency;

  const OverviewStats({
    super.key,
    required this.income,
    required this.expenses,
    required this.savings,
    this.currency = 'USD',
  });

  @override
  Widget build(BuildContext context) {
    final currencySymbol = CurrencyUtils.getCurrencySymbol(currency);
    
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            icon: CupertinoIcons.arrow_up_right,
            iconColor: AppColors.primary,
            title: 'Income',
            amount: '$currencySymbol${income.toStringAsFixed(0)}',
          ),
        ),
        SizedBox(width: ResponsiveConstants.spacing12),
        Expanded(
          child: _StatItem(
            icon: CupertinoIcons.arrow_down_left,
            iconColor: CupertinoColors.systemRed,
            title: 'Expenses',
            amount: '$currencySymbol${expenses.toStringAsFixed(0)}',
          ),
        ),
        SizedBox(width: ResponsiveConstants.spacing12),
        Expanded(
          child: _StatItem(
            icon: CupertinoIcons.square_stack_3d_up,
            iconColor: AppColors.success,
            title: 'Savings',
            amount: '$currencySymbol${savings.toStringAsFixed(0)}',
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String amount;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 10,
            ),
            SizedBox(width: ResponsiveConstants.spacing4),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: CupertinoColors.systemGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveConstants.spacing6),
        Text(
          amount,
          style: TextStyle(
            fontSize: ResponsiveConstants.fontSize14,
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
          ),
        ),
      ],
    );
  }
}
