import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../models/transaction_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../providers/transaction_provider.dart';
import '../../../services/user_service.dart';
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
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null && mounted) {
        final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
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
      case TransactionFilter.expenses:
        filtered = provider.expenses;
        break;
      case TransactionFilter.transfer:
        filtered = provider.transactions
            .where((t) => t.category.toLowerCase().contains('transfer'))
            .toList();
        break;
    }
    
    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  double _calculateTotalBalance(TransactionProvider provider) {
    double total = 0;
    for (final transaction in provider.transactions) {
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
  }

  Future<void> _onRefresh() async {
    await _loadTransactions();
  }

  void _onTransactionTap(TransactionModel transaction) {
    print('Tapped transaction: ${transaction.title}');
    // Navigate to transaction details
  }
    @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.brightnessOf(context);
    
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.getBackgroundColor(brightness),
      child: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          return Stack(
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
                            totalBalance: _calculateTotalBalance(transactionProvider),
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
                    transactionProvider.isLoading
                        ? const SliverFillRemaining(
                            child: Center(
                              child: CupertinoActivityIndicator(radius: 16),
                            ),
                          )
                        : transactionProvider.error != null
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
                                        transactionProvider.error!,
                                        style: TextStyle(
                                          fontSize: ResponsiveConstants.fontSize14,
                                          color: CupertinoColors.systemGrey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: ResponsiveConstants.spacing24),
                                      CupertinoButton.filled(
                                        onPressed: () => _onRefresh(),
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : _getFilteredTransactions(transactionProvider).isEmpty
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
                                        final filteredTransactions = _getFilteredTransactions(transactionProvider);
                                        final transaction = filteredTransactions[index];
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: index == filteredTransactions.length - 1 
                                                ? ResponsiveConstants.spacing120 
                                                : 0,
                                          ),
                                          child: TransactionItem(
                                            transaction: transaction,
                                            onTap: () => _onTransactionTap(transaction),
                                          ),
                                        );
                                      },
                                      childCount: _getFilteredTransactions(transactionProvider).length,
                                    ),
                                  ),
                  ],
                ),
              ),
              
              // Floating Add Button
              const FloatingAddButton(),
            ],
          );
        },
      ),
    );
  }
}
