import 'package:expensebuddy/router/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../models/transaction_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/transaction_provider.dart';
import '../../../services/user_service.dart';
import '../../../services/user_preferences_service.dart';
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
  final UserPreferencesService _preferencesService = UserPreferencesService();
  String _userCurrency = 'USD';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _searchSuggestions = [];
  bool _showSearchSuggestions = false;
  bool _showSearchBar = false;

  // Advanced Filters
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;
  String? _selectedCategory;
  SortOption _sortOption = SortOption.dateDesc;
  bool _showAdvancedFilters = false;

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    _loadTransactions();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPreferences() async {
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null) {
        final preferences = await _preferencesService.getUserPreferences(
          currentUser.uid,
        );
        setState(() {
          _userCurrency = preferences?.defaultCurrency ?? 'USD';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading user preferences: $e');
      }
    }
  }

  Future<void> _loadTransactions() async {
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null && mounted) {
        final transactionProvider = Provider.of<TransactionProvider>(
          context,
          listen: false,
        );
        await transactionProvider.loadTransactions(currentUser.uid);
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }
  }

  List<TransactionModel> _getFilteredTransactions(
    TransactionProvider provider,
  ) {
    List<TransactionModel> filtered;

    switch (_selectedFilter) {
      case TransactionFilter.all:
        filtered = provider.transactions;
        break;
      case TransactionFilter.income:
        filtered = provider.getTransactionsByType(TransactionType.income);
        break;
      case TransactionFilter.expenses:
        filtered = provider.getTransactionsByType(TransactionType.expense);
        break;
      case TransactionFilter.transfer:
        filtered = provider.transactions
            .where((t) => t.category.toLowerCase().contains('transfer'))
            .toList();
        break;
    }

    // Apply search filter if query is not empty
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction.title.toLowerCase().contains(_searchQuery) ||
            transaction.category.toLowerCase().contains(_searchQuery) ||
            (transaction.description?.toLowerCase().contains(_searchQuery) ??
                false);
      }).toList();
    }

    // Apply date range filter
    if (_startDate != null) {
      filtered = filtered
          .where(
            (transaction) => transaction.date.isAfter(
              _startDate!.subtract(const Duration(days: 1)),
            ),
          )
          .toList();
    }

    if (_endDate != null) {
      filtered = filtered
          .where(
            (transaction) => transaction.date.isBefore(
              _endDate!.add(const Duration(days: 1)),
            ),
          )
          .toList();
    }

    // Apply amount range filter
    if (_minAmount != null) {
      filtered = filtered
          .where((transaction) => transaction.amount >= _minAmount!)
          .toList();
    }

    if (_maxAmount != null) {
      filtered = filtered
          .where((transaction) => transaction.amount <= _maxAmount!)
          .toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered
          .where((transaction) => transaction.category == _selectedCategory)
          .toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case SortOption.dateDesc:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.dateAsc:
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.amountDesc:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortOption.amountAsc:
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case SortOption.titleAsc:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.titleDesc:
        filtered.sort((a, b) => b.title.compareTo(a.title));
        break;
    }

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

  void _onSortChanged(SortOption sort) {
    setState(() {
      _sortOption = sort;
    });
  }

  void _onDateRangeChanged(DateTime? start, DateTime? end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }

  void _onCategoryFilterChanged(String? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onAmountRangeChanged(double? min, double? max) {
    setState(() {
      _minAmount = min;
      _maxAmount = max;
    });
  }

  Future<void> _onRefresh() async {
    await _loadTransactions();
  }

  void _onTransactionTap(TransactionModel transaction) {
    debugPrint('Tapped transaction: ${transaction.title}');
    context.push(AppRoutes.transactionDetails, extra: transaction);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _showSearchSuggestions = _searchQuery.isNotEmpty;
      _updateSearchSuggestions();
    });
  }

  void _updateSearchSuggestions() {
    if (_searchQuery.isEmpty) {
      _searchSuggestions = [];
      return;
    }

    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );
    final allTransactions = transactionProvider.transactions;

    final suggestions = <String>{};

    // Add transaction titles
    for (final transaction in allTransactions) {
      if (transaction.title.toLowerCase().contains(_searchQuery)) {
        suggestions.add(transaction.title);
      }
    }

    // Add categories
    for (final transaction in allTransactions) {
      if (transaction.category.toLowerCase().contains(_searchQuery)) {
        suggestions.add(transaction.category);
      }
    }

    // Add descriptions
    for (final transaction in allTransactions) {
      if (transaction.description?.toLowerCase().contains(_searchQuery) ==
          true) {
        suggestions.add(transaction.description!);
      }
    }

    setState(() {
      _searchSuggestions = suggestions.take(5).toList();
    });
  }

  void _onSuggestionTap(String suggestion) {
    setState(() {
      _searchController.text = suggestion;
      _searchQuery = suggestion.toLowerCase();
      _showSearchSuggestions = false;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _searchSuggestions = [];
      _showSearchSuggestions = false;
      _showSearchBar = false;
    });
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (!_showSearchBar) {
        _clearSearch();
      }
    });
  }


  void _clearAllFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _minAmount = null;
      _maxAmount = null;
      _selectedCategory = null;
      _sortOption = SortOption.dateDesc;
      _clearSearch();
    });
  }

  void _applyFilters() {
    setState(() {
      _showAdvancedFilters = false;
    });
  }

  Widget _buildSearchBar() {
    if (!_showSearchBar) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.spacing20),
      child: Column(
        children: [
          // Search Input
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
              border: Border.all(color: CupertinoColors.systemGrey5, width: 1),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CupertinoTextField(
              controller: _searchController,
              placeholder: 'Search transactions...',
              prefix: Padding(
                padding: EdgeInsets.only(left: ResponsiveConstants.spacing12),
                child: Icon(
                  CupertinoIcons.search,
                  color: CupertinoColors.systemGrey,
                  size: 20,
                ),
              ),
              suffix: _searchQuery.isNotEmpty
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _clearSearch,
                      child: Icon(
                        CupertinoIcons.clear,
                        color: CupertinoColors.systemGrey,
                        size: 20,
                      ),
                    )
                  : null,
              decoration: null,
              style: TextStyle(
                fontSize: ResponsiveConstants.fontSize16,
                color: CupertinoColors.label,
              ),
            ),
          ),

          // Search Suggestions
          if (_showSearchSuggestions && _searchSuggestions.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: ResponsiveConstants.spacing8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(
                  ResponsiveConstants.radius12,
                ),
                border: Border.all(
                  color: CupertinoColors.systemGrey5,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _searchSuggestions
                    .map(
                      (suggestion) => GestureDetector(
                        onTap: () => _onSuggestionTap(suggestion),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveConstants.spacing16,
                            vertical: ResponsiveConstants.spacing12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.search,
                                color: CupertinoColors.systemGrey,
                                size: 16,
                              ),
                              SizedBox(width: ResponsiveConstants.spacing8),
                              Expanded(
                                child: Text(
                                  suggestion,
                                  style: TextStyle(
                                    fontSize: ResponsiveConstants.fontSize14,
                                    color: CupertinoColors.label,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
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
                          TransactionsHeader(
                            onSearchTap: _toggleSearchBar,
                            currentFilter: _selectedFilter,
                            currentSort: _sortOption,
                            onFilterChanged: _onFilterChanged,
                            onSortChanged: _onSortChanged,
                            onDateRangeChanged: _onDateRangeChanged,
                            onCategoryFilterChanged: _onCategoryFilterChanged,
                            onAmountRangeChanged: _onAmountRangeChanged,
                            onSearchChanged: (query) =>
                                setState(() => _searchQuery = query),
                            currency: _userCurrency,
                          ),

                          // Search Bar
                          _buildSearchBar(),

                          // Advanced Filters
                          if (_showAdvancedFilters) _buildAdvancedFilters(),

                          SizedBox(height: ResponsiveConstants.spacing16),

                          // Balance Card
                          BalanceCard(
                            totalBalance: _calculateTotalBalance(
                              transactionProvider,
                            ),
                            currency: _userCurrency,
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

                          // Filter Statistics
                          _buildFilterStatistics(transactionProvider),

                          SizedBox(height: ResponsiveConstants.spacing20),
                        ],
                      ),
                    ),

                    // Pull to refresh
                    CupertinoSliverRefreshControl(onRefresh: _onRefresh),

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
                                  SizedBox(
                                    height: ResponsiveConstants.spacing16,
                                  ),
                                  Text(
                                    'Error loading transactions',
                                    style: TextStyle(
                                      fontSize: ResponsiveConstants.fontSize18,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.label,
                                    ),
                                  ),
                                  SizedBox(
                                    height: ResponsiveConstants.spacing8,
                                  ),
                                  Text(
                                    transactionProvider.error!,
                                    style: TextStyle(
                                      fontSize: ResponsiveConstants.fontSize14,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                    height: ResponsiveConstants.spacing24,
                                  ),
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
                                  SizedBox(
                                    height: ResponsiveConstants.spacing24,
                                  ),
                                  Text(
                                    'No transactions yet',
                                    style: TextStyle(
                                      fontSize: ResponsiveConstants.fontSize20,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.label,
                                    ),
                                  ),
                                  SizedBox(
                                    height: ResponsiveConstants.spacing8,
                                  ),
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
                                final filteredTransactions =
                                    _getFilteredTransactions(
                                      transactionProvider,
                                    );
                                final transaction = filteredTransactions[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        index == filteredTransactions.length - 1
                                        ? ResponsiveConstants.spacing120
                                        : 0,
                                  ),
                                  child: TransactionItem(
                                    transaction: transaction,
                                    onTap: () => _onTransactionTap(transaction),
                                  ),
                                );
                              },
                              childCount: _getFilteredTransactions(
                                transactionProvider,
                              ).length,
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

  Widget _buildFilterStatistics(TransactionProvider provider) {
    final filteredTransactions = _getFilteredTransactions(provider);
    final totalTransactions = provider.transactions.length;
    final filteredCount = filteredTransactions.length;

    if (totalTransactions == 0) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.spacing20),
      padding: EdgeInsets.all(ResponsiveConstants.spacing12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.withOpacity(0.5),
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.info_circle,
            size: 16,
            color: CupertinoColors.systemGrey,
          ),
          SizedBox(width: ResponsiveConstants.spacing8),
          Expanded(
            child: Text(
              'Showing $filteredCount of $totalTransactions transactions',
              style: TextStyle(
                fontSize: ResponsiveConstants.fontSize12,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _clearSearch,
              child: Text(
                'Clear Search',
                style: TextStyle(
                  fontSize: ResponsiveConstants.fontSize12,
                  color: CupertinoColors.systemBlue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveConstants.spacing20),
      padding: EdgeInsets.all(ResponsiveConstants.spacing16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(ResponsiveConstants.radius16),
        border: Border.all(color: CupertinoColors.systemGrey5, width: 1),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                CupertinoIcons.slider_horizontal_3,
                color: CupertinoColors.systemBlue,
                size: 20,
              ),
              SizedBox(width: ResponsiveConstants.spacing8),
              Text(
                'Advanced Filters',
                style: TextStyle(
                  fontSize: ResponsiveConstants.fontSize16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _clearAllFilters,
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: ResponsiveConstants.fontSize12,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveConstants.spacing16),

          // Date Range
          Text(
            'Date Range',
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          SizedBox(height: ResponsiveConstants.spacing8),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveConstants.spacing8,
                  ),
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(
                    ResponsiveConstants.radius8,
                  ),
                  onPressed: () => _selectDate(true),
                  child: Text(
                    _startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Start Date',
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize12,
                      color: CupertinoColors.label,
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveConstants.spacing8),
              Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveConstants.spacing8,
                  ),
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(
                    ResponsiveConstants.radius8,
                  ),
                  onPressed: () => _selectDate(false),
                  child: Text(
                    _endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'End Date',
                    style: TextStyle(
                      fontSize: ResponsiveConstants.fontSize12,
                      color: CupertinoColors.label,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveConstants.spacing16),

          // Amount Range
          Text(
            'Amount Range',
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          SizedBox(height: ResponsiveConstants.spacing8),
          Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  placeholder: 'Min Amount',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _minAmount = double.tryParse(value);
                    });
                  },
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(
                      ResponsiveConstants.radius8,
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveConstants.spacing8),
              Expanded(
                child: CupertinoTextField(
                  placeholder: 'Max Amount',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _maxAmount = double.tryParse(value);
                    });
                  },
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(
                      ResponsiveConstants.radius8,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveConstants.spacing16),

          // Sort Options
          Text(
            'Sort By',
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          SizedBox(height: ResponsiveConstants.spacing8),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(ResponsiveConstants.radius8),
            ),
            child: CupertinoSlidingSegmentedControl<SortOption>(
              groupValue: _sortOption,
              children: {
                SortOption.dateDesc: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text('Newest', style: TextStyle(fontSize: 12)),
                ),
                SortOption.dateAsc: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text('Oldest', style: TextStyle(fontSize: 12)),
                ),
                SortOption.amountDesc: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text('High-Low', style: TextStyle(fontSize: 12)),
                ),
                SortOption.amountAsc: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text('Low-High', style: TextStyle(fontSize: 12)),
                ),
              },
              onValueChanged: (SortOption? value) {
                if (value != null) {
                  setState(() {
                    _sortOption = value;
                  });
                }
              },
            ),
          ),

          SizedBox(height: ResponsiveConstants.spacing16),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              onPressed: _applyFilters,
              child: Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate(bool isStartDate) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoDatePicker(
            initialDateTime: isStartDate
                ? (_startDate ?? DateTime.now())
                : (_endDate ?? DateTime.now()),
            mode: CupertinoDatePickerMode.date,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                if (isStartDate) {
                  _startDate = newDate;
                } else {
                  _endDate = newDate;
                }
              });
            },
          ),
        ),
      ),
    );
  }
}
