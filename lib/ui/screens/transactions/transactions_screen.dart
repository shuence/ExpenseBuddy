import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../../../models/transaction_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import 'widgets/transactions_header.dart';
import 'widgets/balance_card.dart';
import 'widgets/transaction_filter_tabs.dart';
import 'widgets/transaction_item.dart';
import 'widgets/floating_add_button.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionFilter _selectedFilter = TransactionFilter.all;
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    // Sample data matching the image design
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
      ),
      TransactionModel(
        id: '2',
        title: 'Uber Ride',
        amount: 24.99,
        category: 'Transport',
        date: DateTime.now().subtract(const Duration(hours: 5)),
        userId: 'user123',
        currency: 'USD',
        type: TransactionType.expense,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TransactionModel(
        id: '3',
        title: 'Electric Bill',
        amount: 120.00,
        category: 'Bills',
        date: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'user123',
        currency: 'USD',
        type: TransactionType.expense,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TransactionModel(
        id: '4',
        title: 'Netflix Subscription',
        amount: 15.99,
        category: 'Entertainment',
        date: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'user123',
        currency: 'USD',
        type: TransactionType.expense,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TransactionModel(
        id: '5',
        title: 'Salary Deposit',
        amount: 3200.00,
        category: 'Salary',
        date: DateTime.now().subtract(const Duration(days: 30)),
        userId: 'user123',
        currency: 'USD',
        type: TransactionType.income,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TransactionModel(
        id: '6',
        title: 'Bank Transfer',
        amount: 500.00,
        category: 'Transfer',
        date: DateTime.now().subtract(const Duration(days: 62)),
        userId: 'user123',
        currency: 'USD',
        type: TransactionType.expense,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    
    _applyFilter();
  }

  void _applyFilter() {
    setState(() {
      switch (_selectedFilter) {
        case TransactionFilter.all:
          _filteredTransactions = _allTransactions;
          break;
        case TransactionFilter.income:
          _filteredTransactions = _allTransactions
              .where((t) => t.type == TransactionType.income)
              .toList();
          break;
        case TransactionFilter.expenses:
          _filteredTransactions = _allTransactions
              .where((t) => t.type == TransactionType.expense)
              .toList();
          break;
        case TransactionFilter.transfer:
          _filteredTransactions = _allTransactions
              .where((t) => t.category.toLowerCase().contains('transfer'))
              .toList();
          break;
      }
    });
  }

  double _calculateTotalBalance() {
    double total = 0;
    for (final transaction in _allTransactions) {
      if (transaction.type == TransactionType.income) {
        total += transaction.amount;
      } else {
        total -= transaction.amount;
      }
    }
    return total;
  }

  void _onFilterChanged(TransactionFilter filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilter();
  }

  Future<void> _onRefresh() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Refreshing transactions...');
  }

  void _onTransactionTap(TransactionModel transaction) {
    debugPrint('Tapped transaction: ${transaction.title}');
    // Navigate to transaction details
  }
    @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.getBackgroundColor(brightness),
      child: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TransactionsHeader(),
                      
                      // Balance Card
                      BalanceCard(
                        totalBalance: _calculateTotalBalance(),
                        currency: 'USD',
                        period: 'This Month',
                        monthlyChange: 580.50,
                        isIncreasePositive: true,
                      ),
                      
                      SizedBox(height: ResponsiveConstants.spacing20),
                      
                      // Filter Tabs
                      TransactionFilterTabs(
                        selectedFilter: _selectedFilter,
                        onFilterChanged: _onFilterChanged,
                      ),
                      
                      SizedBox(height: ResponsiveConstants.spacing20),
                    ],
                  ),
                ),
                
                // Pull to refresh
                CupertinoSliverRefreshControl(
                  onRefresh: _onRefresh,
                ),
                
                // Transaction List
                _isLoading
                    ? const SliverFillRemaining(
                        child: Center(
                          child: CupertinoActivityIndicator(radius: 16),
                        ),
                      )
                    : _errorMessage != null
                        ? SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    CupertinoIcons.exclamationmark_circle,
                                    size: 48,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                  SizedBox(height: ResponsiveConstants.spacing16),
                                  Text(
                                    'Error loading transactions',
                                    style: TextStyle(
                                      fontSize: ResponsiveConstants.fontSize18,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.label,
                                    ),
                                  ),
                                  SizedBox(height: ResponsiveConstants.spacing8),
                                  Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      fontSize: ResponsiveConstants.fontSize14,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: ResponsiveConstants.spacing24),
                                  CupertinoButton.filled(
                                    onPressed: () {
                                      setState(() {
                                        _isLoading = true;
                                        _errorMessage = null;
                                      });
                                      _onRefresh();
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _filteredTransactions.isEmpty
                            ? SliverFillRemaining(
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
                                      SizedBox(height: ResponsiveConstants.spacing24),
                                      Text(
                                        'No transactions yet',
                                        style: TextStyle(
                                          fontSize: ResponsiveConstants.fontSize20,
                                          fontWeight: FontWeight.w600,
                                          color: CupertinoColors.label,
                                        ),
                                      ),
                                      SizedBox(height: ResponsiveConstants.spacing8),
                                      Text(
                                        'Your transactions will appear here\nonce you start adding them',
                                        style: TextStyle(
                                          fontSize: ResponsiveConstants.fontSize16,
                                          color: CupertinoColors.systemGrey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final transaction = _filteredTransactions[index];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: index == _filteredTransactions.length - 1 
                                            ? ResponsiveConstants.spacing120 
                                            : 0,
                                      ),
                                      child: TransactionItem(
                                        transaction: transaction,
                                        onTap: () => _onTransactionTap(transaction),
                                      ),
                                    );
                                  },
                                  childCount: _filteredTransactions.length,
                                ),
                              ),
              ],
            ),
          ),
          
          // Floating Add Button
          const FloatingAddButton(),
        ],
      ),
    );
  }
}
