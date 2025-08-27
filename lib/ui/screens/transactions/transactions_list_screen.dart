import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';
import '../../../services/user_service.dart';
import '../../../utils/currency_utils.dart';
import '../../../router/routes.dart';
import 'transaction_details_screen.dart';

enum TransactionFilter { all, income, expense }

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  TransactionFilter _selectedFilter = TransactionFilter.all;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() async {
    // Load transactions using the provider
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    
    // Get current user ID from auth service or user service
    try {
      final userService = UserService();
      final currentUser = await userService.getCurrentUser();
      if (currentUser != null) {
        await transactionProvider.loadTransactions(currentUser.uid);
      }
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }

  List<TransactionModel> _getFilteredTransactions(TransactionProvider provider) {
    List<TransactionModel> filtered;
    
    switch (_selectedFilter) {
      case TransactionFilter.all:
        filtered = provider.transactions;
        break;
      case TransactionFilter.income:
        filtered = provider.income;
        break;
      case TransactionFilter.expense:
        filtered = provider.expenses;
        break;
    }
    
    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  void _onTransactionTap(TransactionModel transaction) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => TransactionDetailsScreen(transaction: transaction),
      ),
    );
  }

  Future<void> _refreshTransactions() async {
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Transactions',
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
          onPressed: () {
            context.push(AppRoutes.addTransaction);
          },
          child: Icon(
            CupertinoIcons.add,
            color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
          ),
        ),
      ),
      backgroundColor: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
      child: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: CupertinoSlidingSegmentedControl<TransactionFilter>(
              groupValue: _selectedFilter,
              children: const {
                TransactionFilter.all: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('All'),
                ),
                TransactionFilter.expense: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Expenses'),
                  ),  
                  TransactionFilter.income: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Income'),
                  ),
                  
                },
                    onValueChanged: (TransactionFilter? value) {
                  if (value != null) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  }
                },
              ),
            ),
            
            // Transactions List
            Expanded(
              child: Consumer<TransactionProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            size: 48,
                            color: CupertinoColors.systemOrange,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${provider.error}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CupertinoButton(
                            onPressed: () {
                              _refreshTransactions();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredTransactions = _getFilteredTransactions(provider);

                  if (filteredTransactions.isEmpty) {
                    String filterText = '';
                    IconData iconData = CupertinoIcons.list_bullet;
                    
                    switch (_selectedFilter) {
                      case TransactionFilter.all:
                        filterText = 'transactions';
                        iconData = CupertinoIcons.list_bullet;
                        break;
                      case TransactionFilter.income:
                        filterText = 'income';
                        iconData = CupertinoIcons.arrow_up_circle;
                        break;
                      case TransactionFilter.expense:
                        filterText = 'expenses';
                        iconData = CupertinoIcons.arrow_down_circle;
                        break;
                    }
                    
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            iconData,
                            size: 64,
                            color: CupertinoColors.systemGrey3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No $filterText yet',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first transaction to get started',
                            style: const TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CupertinoButton.filled(
                            onPressed: () {
                              context.push(AppRoutes.addTransaction);
                            },
                            child: const Text('Add Transaction'),
                          ),
                        ],
                      ),
                    );
                  }

                  return CustomScrollView(
                    slivers: [
                      CupertinoSliverRefreshControl(
                        onRefresh: _refreshTransactions,
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final transaction = filteredTransactions[index];
                            return GestureDetector(
                              onTap: () => _onTransactionTap(transaction),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: _buildTransactionCard(transaction),
                              ),
                            );
                          },
                          childCount: filteredTransactions.length,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final isExpense = transaction.type == TransactionType.expense;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemGrey5,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isExpense 
                    ? CupertinoColors.systemRed.withOpacity(0.1)
                    : CupertinoColors.systemGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isExpense ? CupertinoIcons.arrow_down : CupertinoIcons.arrow_up,
                color: isExpense 
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemGreen,
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.category,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey2,
                    ),
                  ),
                ],
              ),
            ),
            
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '-' : '+'}${CurrencyUtils.getCurrencySymbol(transaction.currency)}${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isExpense 
                        ? CupertinoColors.systemRed
                        : CupertinoColors.systemGreen,
                  ),
                ),
                if (transaction.description != null) ...[
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 120,
                    child: Text(
                      transaction.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
