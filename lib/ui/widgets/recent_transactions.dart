import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/responsive_constants.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {
        'title': 'Grocery Shopping',
        'subtitle': 'Whole Foods Market',
        'amount': '-\$85.20',
        'time': 'Today',
        'icon': CupertinoIcons.cart_fill,
        'iconColor': Color(0xFF4CAF50),
      },
      {
        'title': 'Transport',
        'subtitle': 'Uber Ride',
        'amount': '-\$12.50',
        'time': 'Today',
        'icon': CupertinoIcons.car_fill,
        'iconColor': CupertinoColors.systemBlue,
      },
      {
        'title': 'Entertainment',
        'subtitle': 'Netflix',
        'amount': '-\$15.99',
        'time': 'Yesterday',
        'icon': CupertinoIcons.gamecontroller_fill,
        'iconColor': Color(0xFF4CAF50),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: ResponsiveConstants.fontSize16,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {},
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: ResponsiveConstants.fontSize12,
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveConstants.spacing16),
        ...transactions.map((transaction) => TransactionItem(
          title: transaction['title'] as String,
          subtitle: transaction['subtitle'] as String,
          amount: transaction['amount'] as String,
          time: transaction['time'] as String,
          icon: transaction['icon'] as IconData,
          iconColor: transaction['iconColor'] as Color,
        )),
      ],
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final String time;
  final IconData icon;
  final Color iconColor;

  const TransactionItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.time,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveConstants.spacing8),
      padding: EdgeInsets.all(ResponsiveConstants.spacing12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
        border: Border.all(
          color: CupertinoColors.systemGrey6.resolveFrom(context),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: ResponsiveConstants.iconSize16,
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
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: ResponsiveConstants.fontSize14,
                  fontWeight: FontWeight.w600,
                  color: amount.startsWith('-') 
                      ? CupertinoColors.systemRed 
                      : Color(0xFF4CAF50),
                ),
              ),
              SizedBox(height: ResponsiveConstants.spacing2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
