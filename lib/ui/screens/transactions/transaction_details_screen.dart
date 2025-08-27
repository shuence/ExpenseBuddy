import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../models/transaction_model.dart';
import 'edit_transaction_screen.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionModel transaction;
  
  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  void _editTransaction(BuildContext context) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => EditTransactionScreen(transaction: transaction),
      ),
    );
    
    if (result == true) {
      // Transaction was updated, pop back to refresh the list
      if (context.mounted) {
        context.pop(true);
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome 
        ? const Color(0xFF2ECC71) 
        : const Color(0xFFE74C3C);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Transaction Details',
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
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _editTransaction(context),
          child: Icon(
            CupertinoIcons.pencil,
            color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
            size: 24,
          ),
        ),
      ),
      backgroundColor: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveConstants.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Transaction Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(ResponsiveConstants.spacing20),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
                  border: Border.all(
                    color: CupertinoColors.systemGrey5.resolveFrom(context),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Transaction Type Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveConstants.spacing12,
                        vertical: ResponsiveConstants.spacing6,
                      ),
                      decoration: BoxDecoration(
                        color: isIncome 
                            ? const Color(0xFF2ECC71).withOpacity(0.1)
                            : const Color(0xFFE74C3C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(ResponsiveConstants.radius20),
                      ),
                      child: Text(
                        isIncome ? 'Income' : 'Expense',
                        style: TextStyle(
                          color: amountColor,
                          fontSize: ResponsiveConstants.fontSize12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveConstants.spacing16),
                    
                    // Amount
                    Text(
                      '${isIncome ? '+' : '-'}${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize28,
                        fontWeight: FontWeight.bold,
                        color: amountColor,
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveConstants.spacing8),
                    
                    // Title
                    Text(
                      transaction.title,
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: ResponsiveConstants.spacing4),
                    
                    // Category
                    Text(
                      transaction.category,
                      style: TextStyle(
                        fontSize: ResponsiveConstants.fontSize16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: ResponsiveConstants.spacing24),
              
              // Details Section
              Text(
                'Details',
                style: TextStyle(
                  fontSize: ResponsiveConstants.fontSize18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                ),
              ),
              
              SizedBox(height: ResponsiveConstants.spacing12),
              
              // Details Cards
              _buildDetailCard(
                context,
                icon: CupertinoIcons.calendar,
                title: 'Date',
                value: _formatDate(transaction.date),
              ),
              
              SizedBox(height: ResponsiveConstants.spacing12),
              
              _buildDetailCard(
                context,
                icon: CupertinoIcons.time,
                title: 'Time',
                value: _formatTime(transaction.date),
              ),
              
              SizedBox(height: ResponsiveConstants.spacing12),
              
              _buildDetailCard(
                context,
                icon: CupertinoIcons.money_dollar_circle,
                title: 'Currency',
                value: transaction.currency,
              ),
              
              if (transaction.description != null && transaction.description!.isNotEmpty) ...[
                SizedBox(height: ResponsiveConstants.spacing12),
                _buildDetailCard(
                  context,
                  icon: CupertinoIcons.doc_text,
                  title: 'Description',
                  value: transaction.description!,
                  isMultiline: true,
                ),
              ],
              
              SizedBox(height: ResponsiveConstants.spacing24),
              
              // Metadata Section
              Text(
                'Metadata',
                style: TextStyle(
                  fontSize: ResponsiveConstants.fontSize18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                ),
              ),
              
              SizedBox(height: ResponsiveConstants.spacing12),
              
              _buildDetailCard(
                context,
                icon: CupertinoIcons.add_circled,
                title: 'Created',
                value: _formatDate(transaction.createdAt),
              ),
              
              SizedBox(height: ResponsiveConstants.spacing12),
              
              _buildDetailCard(
                context,
                icon: CupertinoIcons.pencil_circle,
                title: 'Last Updated',
                value: _formatDate(transaction.updatedAt),
              ),
              
              SizedBox(height: ResponsiveConstants.spacing12),
              
              _buildDetailCard(
                context,
                icon: CupertinoIcons.number,
                title: 'Transaction ID',
                value: transaction.id,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isMultiline = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveConstants.spacing16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
        border: Border.all(
          color: CupertinoColors.systemGrey5.resolveFrom(context),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
            size: 20,
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
                    color: CupertinoColors.systemGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                SizedBox(height: ResponsiveConstants.spacing4),
                
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveConstants.fontSize16,
                    color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
