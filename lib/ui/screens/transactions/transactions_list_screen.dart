import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';
import '../../../router/routes.dart';
import 'transaction_details_screen.dart';
import 'widgets/transaction_list.dart';

enum TransactionFilter { all, income, expense }

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  TransactionFilter _selectedFilter = TransactionFilter.all;
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    setState(() {
      _isLoading = true;
    });

    // Sample data
    _allTransactions = [
      TransactionModel(
        id: '1',
        title: 'Grocery Shopping',
        amount: 85.50,
        category: 'Food',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        userId: 'user123',
        currency: 'USD',
        type: TransactionType.expense,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: 'Weekly grocery shopping at the local supermarket',
      ),
      TransactionModel(
        id: '2',
        title: 'Salary',
        amount: 3500.00,
        category: 'Income',
        date: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'user123',
        currency: 'USD',
        type: TransactionType.income,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TransactionModel(
        id: '3',
        title: 'Uber Ride',
        amount: 12.75,
        category: 'Transport',
        date: DateTime.now().subtract(const Duration(hours: 6)),
        userId: 'user123',
        currency: 'USD',
        type: TransactionType.expense,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: 'Ride to downtown office',
      ),
      TransactionModel(
        id: '4',
        title: 'Electric Bill',
        amount: 89.30,
        category: 'Bills',
        date: DateTime.now().subtract(const Duration(days: 2)),
        userId: 'user123',
        currency: 'USD',
        type: TransactionType.expense,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TransactionModel(
        id: '5',
        title: 'Netflix Subscription',
        amount: 15.99,
        category: 'Entertainment',
        date: DateTime.now().subtract(const Duration(days: 3)),
        userId: 'user123',
        currency: 'USD',
        type: TransactionType.expense,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    _applyFilter();
    
    setState(() {
      _isLoading = false;
    });
  }

  void _applyFilter() {
    switch (_selectedFilter) {
      case TransactionFilter.all:
        _filteredTransactions = _allTransactions;
        break;
      case TransactionFilter.income:
        _filteredTransactions = _allTransactions
            .where((t) => t.type == TransactionType.income)
            .toList();
        break;
      case TransactionFilter.expense:
        _filteredTransactions = _allTransactions
            .where((t) => t.type == TransactionType.expense)
            .toList();
        break;
    }
    
    // Sort by date (newest first)
    _filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
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
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
    _loadSampleData();
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
                              provider.loadTransactions('demo_user');
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredTransactions = _selectedFilter == TransactionType.expense
                      ? provider.expenses
                      : provider.income;

                  if (filteredTransactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedFilter == TransactionType.expense
                                ? CupertinoIcons.money_dollar_circle
                                : CupertinoIcons.arrow_up_circle,
                            size: 64,
                            color: CupertinoColors.systemGrey3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ${_selectedFilter == TransactionType.expense ? 'expenses' : 'income'} yet',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first ${_selectedFilter == TransactionType.expense ? 'expense' : 'income'} to get started',
                            style: const TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey2,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      return _buildTransactionCard(transaction);
                    },
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
                  '${isExpense ? '-' : '+'}${transaction.currency} ${transaction.amount.toStringAsFixed(2)}',
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
