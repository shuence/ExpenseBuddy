import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/responsive_constants.dart';
import '../../models/transaction_model.dart';
import '../../router/routes.dart';
import '../../utils/currency_utils.dart';

class RecentTransactions extends StatelessWidget {
  final List<TransactionModel> transactions;
  final VoidCallback? onSeeAllPressed;
  final Function(TransactionModel)? onTransactionTap;

  const RecentTransactions({
    super.key,
    required this.transactions,
    this.onSeeAllPressed,
    this.onTransactionTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & dining':
      case 'groceries':
        return CupertinoIcons.cart_fill;
      case 'transportation':
      case 'transport':
        return CupertinoIcons.car_fill;
      case 'entertainment':
        return CupertinoIcons.gamecontroller_fill;
      case 'bills':
      case 'utilities':
        return CupertinoIcons.bolt_fill;
      case 'income':
      case 'salary':
        return CupertinoIcons.money_dollar_circle_fill;
      case 'shopping':
        return CupertinoIcons.bag_fill;
      case 'healthcare':
        return CupertinoIcons.heart_fill;
      default:
        return CupertinoIcons.circle_fill;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & dining':
      case 'groceries':
        return const Color(0xFF4CAF50);
      case 'transportation':
      case 'transport':
        return CupertinoColors.systemBlue;
      case 'entertainment':
        return const Color(0xFF9C27B0);
      case 'bills':
      case 'utilities':
        return CupertinoColors.systemOrange;
      case 'income':
      case 'salary':
        return const Color(0xFF2ECC71);
      case 'shopping':
        return CupertinoColors.systemPink;
      case 'healthcare':
        return CupertinoColors.systemRed;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: onSeeAllPressed ?? () {
                context.push(AppRoutes.transactions);
              },
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
        if (transactions.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.spacing24),
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.list_bullet,
                    size: 48,
                    color: CupertinoColors.systemGrey3,
                  ),
                  SizedBox(height: ResponsiveConstants.spacing8),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize14,
                      color: CupertinoColors.systemGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: ResponsiveConstants.spacing4),
                  Text(
                    'Add your first transaction to get started',
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize12,
                      color: CupertinoColors.systemGrey2,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...transactions.take(3).map((transaction) => GestureDetector(
            onTap: () => onTransactionTap?.call(transaction),
            child: TransactionItem(
              title: transaction.title,
              subtitle: transaction.description ?? transaction.category,
              amount: '${transaction.type == TransactionType.expense ? '-' : '+'}${CurrencyUtils.getCurrencySymbol(transaction.currency)}${transaction.amount.toStringAsFixed(2)}',
              time: _formatTime(transaction.date),
              icon: _getCategoryIcon(transaction.category),
              iconColor: _getCategoryColor(transaction.category),
            ),
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
