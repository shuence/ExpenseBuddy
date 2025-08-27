import 'package:flutter/cupertino.dart';
import '../../../../models/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getCategoryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(),
                color: _getCategoryColor(),
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(transaction.date),
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Amount
            Text(
              _formatAmount(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: transaction.type == TransactionType.income
                    ? const Color(0xFF2ECC71)
                    : const Color(0xFFE74C3C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (transaction.category.toLowerCase()) {
      case 'food':
      case 'grocery':
      case 'grocery shopping':
        return const Color(0xFFFF6B35);
      case 'transport':
      case 'uber':
      case 'uber ride':
        return const Color(0xFF3498DB);
      case 'bills':
      case 'electric bill':
      case 'utilities':
        return const Color(0xFFF39C12);
      case 'entertainment':
      case 'netflix':
      case 'netflix subscription':
        return const Color(0xFFE74C3C);
      case 'salary':
      case 'income':
        return const Color(0xFF2ECC71);
      case 'transfer':
      case 'bank transfer':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  IconData _getCategoryIcon() {
    switch (transaction.category.toLowerCase()) {
      case 'food':
      case 'grocery':
      case 'grocery shopping':
        return CupertinoIcons.bag;
      case 'transport':
      case 'uber':
      case 'uber ride':
        return CupertinoIcons.car;
      case 'bills':
      case 'electric bill':
      case 'utilities':
        return CupertinoIcons.doc_text;
      case 'entertainment':
      case 'netflix':
      case 'netflix subscription':
        return CupertinoIcons.tv;
      case 'salary':
      case 'income':
        return CupertinoIcons.money_dollar;
      case 'transfer':
      case 'bank transfer':
        return CupertinoIcons.arrow_right_arrow_left;
      default:
        return CupertinoIcons.circle;
    }
  }

  String _formatAmount() {
    final prefix = transaction.type == TransactionType.income ? '+' : '-';
    String symbol = '\$';
    
    switch (transaction.currency.toUpperCase()) {
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
    
    return '$prefix$symbol${transaction.amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);
    
    if (transactionDate == today) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date); // Day name
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
