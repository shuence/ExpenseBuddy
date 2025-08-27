import 'package:flutter/cupertino.dart';
import '../../../../models/transaction_model.dart';
import 'transaction_item.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function()? onRefresh;
  final Function(TransactionModel)? onTransactionTap;

  const TransactionList({
    super.key,
    required this.transactions,
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Expanded(
        child: Center(
          child: CupertinoActivityIndicator(radius: 16),
        ),
      );
    }

    if (errorMessage != null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_circle,
                size: 48,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading transactions',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (onRefresh != null)
                CupertinoButton.filled(
                  onPressed: onRefresh,
                  child: const Text('Retry'),
                ),
            ],
          ),
        ),
      );
    }

    if (transactions.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  CupertinoIcons.creditcard,
                  size: 48,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No transactions yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your transactions will appear here\nonce you start adding them',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CupertinoButton.filled(
                onPressed: () {
                  // Navigate to add transaction
                },
                child: const Text('Add Transaction'),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: onRefresh ?? () async {},
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final transaction = transactions[index];
                return TransactionItem(
                  transaction: transaction,
                  onTap: () => onTransactionTap?.call(transaction),
                );
              },
              childCount: transactions.length,
            ),
          ),
          // Add some bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}
