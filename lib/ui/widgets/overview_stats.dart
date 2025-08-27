import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/responsive_constants.dart';

class OverviewStats extends StatelessWidget {
  const OverviewStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            icon: CupertinoIcons.arrow_up_right,
            iconColor: Color(0xFF2ECC71),
            title: 'Income',
            amount: '\$3,240',
          ),
        ),
        SizedBox(width: ResponsiveConstants.spacing12),
        Expanded(
          child: _StatItem(
            icon: CupertinoIcons.arrow_down_left,
            iconColor: CupertinoColors.systemRed,
            title: 'Expenses',
            amount: '\$1,865',
          ),
        ),
        SizedBox(width: ResponsiveConstants.spacing12),
        Expanded(
          child: _StatItem(
            icon: CupertinoIcons.square_stack_3d_up,
            iconColor: Color(0xFF4CAF50),
            title: 'Savings',
            amount: '\$1,375',
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
