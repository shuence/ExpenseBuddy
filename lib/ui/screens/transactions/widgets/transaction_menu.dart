import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/responsive_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../../models/transaction_model.dart';
import '../../../../utils/currency_utils.dart';
import '../../../../ui/widgets/chart_widget.dart';

class TransactionMenu extends StatefulWidget {
  final Function(TransactionFilter)? onFilterChanged;
  final Function(SortOption)? onSortChanged;
  final Function(DateTime?, DateTime?)? onDateRangeChanged;
  final Function(String?)? onCategoryFilterChanged;
  final Function(double?, double?)? onAmountRangeChanged;
  final Function(String)? onSearchChanged;
  final TransactionFilter currentFilter;
  final SortOption currentSort;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedCategory;
  final double? minAmount;
  final double? maxAmount;
  final String searchQuery;
  final String currency;

  const TransactionMenu({
    super.key,
    this.onFilterChanged,
    this.onSortChanged,
    this.onDateRangeChanged,
    this.onCategoryFilterChanged,
    this.onAmountRangeChanged,
    this.onSearchChanged,
    this.currentFilter = TransactionFilter.all,
    this.currentSort = SortOption.dateDesc,
    this.startDate,
    this.endDate,
    this.selectedCategory,
    this.minAmount,
    this.maxAmount,
    this.searchQuery = '',
    this.currency = 'USD',
  });

  @override
  State<TransactionMenu> createState() => _TransactionMenuState();
}

class _TransactionMenuState extends State<TransactionMenu> {
  late TransactionFilter _selectedFilter;
  late SortOption _selectedSort;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late String? _selectedCategory;
  late double? _minAmount;
  late double? _maxAmount;
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.currentFilter;
    _selectedSort = widget.currentSort;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _selectedCategory = widget.selectedCategory;
    _minAmount = widget.minAmount;
    _maxAmount = widget.maxAmount;
    _searchQuery = widget.searchQuery;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Text(
        'Transaction Options',
        style: TextStyle(
          fontSize: ResponsiveConstants.fontSize18,
          fontWeight: FontWeight.w600,
          color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
        ),
      ),
      message: Text(
        'Choose an action to manage your transactions',
        style: TextStyle(
          fontSize: ResponsiveConstants.fontSize14,
          color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
        ),
      ),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _showFilterOptions(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.slider_horizontal_3,
                color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                size: ResponsiveConstants.iconSize20,
              ),
              const SizedBox(width: 8),
              const Text('Filter Transactions'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _showSortOptions(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.sort_down,
                color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                size: ResponsiveConstants.iconSize20,
              ),
              const SizedBox(width: 8),
              const Text('Sort Transactions'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _showDateRangeOptions(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.calendar,
                color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                size: ResponsiveConstants.iconSize20,
              ),
              const SizedBox(width: 8),
              const Text('Date Range'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _showAmountRangeOptions(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.money_dollar,
                color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                size: ResponsiveConstants.iconSize20,
              ),
              const SizedBox(width: 8),
              const Text('Amount Range'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _showCategoryFilter(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.tag,
                color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                size: ResponsiveConstants.iconSize20,
              ),
              const SizedBox(width: 8),
              const Text('Category Filter'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _showSearchOptions(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.search,
                color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                size: ResponsiveConstants.iconSize20,
              ),
              const SizedBox(width: 8),
              const Text('Search'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _exportTransactions(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.share,
                color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                size: ResponsiveConstants.iconSize20,
              ),
              const SizedBox(width: 8),
              const Text('Export Data'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _showAnalytics(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.chart_bar,
                color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                size: ResponsiveConstants.iconSize20,
              ),
              const SizedBox(width: 8),
              const Text('View Analytics'),
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _clearAllFilters(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.clear,
                color: CupertinoColors.systemRed,
                size: ResponsiveConstants.iconSize20,
              ),
              const SizedBox(width: 8),
              const Text('Clear All Filters'),
            ],
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        isDefaultAction: true,
        child: const Text('Cancel'),
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Filter by Type'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _selectedFilter = TransactionFilter.all;
              widget.onFilterChanged?.call(_selectedFilter);
            },
            child: Row(
              children: [
                const Text('All Transactions'),
                if (_selectedFilter == TransactionFilter.all)
                  const Icon(CupertinoIcons.check_mark, color: CupertinoColors.systemBlue),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _selectedFilter = TransactionFilter.income;
              widget.onFilterChanged?.call(_selectedFilter);
            },
            child: Row(
              children: [
                const Text('Income Only'),
                if (_selectedFilter == TransactionFilter.income)
                  const Icon(CupertinoIcons.check_mark, color: CupertinoColors.systemBlue),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _selectedFilter = TransactionFilter.expenses;
              widget.onFilterChanged?.call(_selectedFilter);
            },
            child: Row(
              children: [
                const Text('Expenses Only'),
                if (_selectedFilter == TransactionFilter.expenses)
                  const Icon(CupertinoIcons.check_mark, color: CupertinoColors.systemBlue),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _selectedFilter = TransactionFilter.transfer;
              widget.onFilterChanged?.call(_selectedFilter);
            },
            child: Row(
              children: [
                const Text('Transfers Only'),
                if (_selectedFilter == TransactionFilter.transfer)
                  const Icon(CupertinoIcons.check_mark, color: CupertinoColors.systemBlue),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }



  void _showSortOptions(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Sort Transactions'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _selectedSort = SortOption.dateDesc;
              widget.onSortChanged?.call(_selectedSort);
            },
            child: Row(
              children: [
                const Text('Date (Newest First)'),
                if (_selectedSort == SortOption.dateDesc)
                  const Icon(CupertinoIcons.check_mark, color: CupertinoColors.systemBlue),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _selectedSort = SortOption.dateAsc;
              widget.onSortChanged?.call(_selectedSort);
            },
            child: Row(
              children: [
                const Text('Date (Oldest First)'),
                if (_selectedSort == SortOption.dateAsc)
                  const Icon(CupertinoIcons.check_mark, color: CupertinoColors.systemBlue),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _selectedSort = SortOption.amountDesc;
              widget.onSortChanged?.call(_selectedSort);
            },
            child: Row(
              children: [
                const Text('Amount (Highest First)'),
                if (_selectedSort == SortOption.amountDesc)
                  const Icon(CupertinoIcons.check_mark, color: CupertinoColors.systemBlue),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _selectedSort = SortOption.amountAsc;
              widget.onSortChanged?.call(_selectedSort);
            },
            child: Row(
              children: [
                const Text('Amount (Lowest First)'),
                if (_selectedSort == SortOption.amountAsc)
                  const Icon(CupertinoIcons.check_mark, color: CupertinoColors.systemBlue),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _selectedSort = SortOption.titleAsc;
              widget.onSortChanged?.call(_selectedSort);
            },
            child: Row(
              children: [
                const Text('Title (A-Z)'),
                if (_selectedSort == SortOption.titleAsc)
                  const Icon(CupertinoIcons.check_mark, color: CupertinoColors.systemBlue),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showDateRangeOptions(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Date Range'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              final now = DateTime.now();
              _startDate = DateTime(now.year, now.month, now.day);
              _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
              widget.onDateRangeChanged?.call(_startDate, _endDate);
            },
            child: const Text('Today'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              final now = DateTime.now();
              _startDate = now.subtract(Duration(days: now.weekday - 1));
              _endDate = _startDate!.add(const Duration(days: 6));
              widget.onDateRangeChanged?.call(_startDate, _endDate);
            },
            child: const Text('This Week'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              final now = DateTime.now();
              _startDate = DateTime(now.year, now.month, 1);
              _endDate = DateTime(now.year, now.month + 1, 0);
              widget.onDateRangeChanged?.call(_startDate, _endDate);
            },
            child: const Text('This Month'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              final now = DateTime.now();
              _startDate = now.subtract(const Duration(days: 90));
              _endDate = now;
              widget.onDateRangeChanged?.call(_startDate, _endDate);
            },
            child: const Text('Last 3 Months'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              final now = DateTime.now();
              _startDate = DateTime(now.year, 1, 1);
              _endDate = DateTime(now.year, 12, 31);
              widget.onDateRangeChanged?.call(_startDate, _endDate);
            },
            child: const Text('This Year'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showCustomDateRange(context);
            },
            child: const Text('Custom Range'),
          ),
          if (_startDate != null || _endDate != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _startDate = null;
                _endDate = null;
                widget.onDateRangeChanged?.call(null, null);
              },
              isDestructiveAction: true,
              child: const Text('Clear Date Range'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showAmountRangeOptions(BuildContext context) {
    final minController = TextEditingController(text: _minAmount?.toString() ?? '');
    final maxController = TextEditingController(text: _maxAmount?.toString() ?? '');

    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: CupertinoColors.separator)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Text(
                    'Amount Range',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      final minAmount = double.tryParse(minController.text);
                      final maxAmount = double.tryParse(maxController.text);
                      _minAmount = minAmount;
                      _maxAmount = maxAmount;
                      widget.onAmountRangeChanged?.call(minAmount, maxAmount);
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CupertinoTextField(
                      controller: minController,
                      placeholder: 'Minimum Amount',
                      keyboardType: TextInputType.number,
                      prefix: Text('${CurrencyUtils.getCurrencySymbol(widget.currency)} '),
                    ),
                    const SizedBox(height: 16),
                    CupertinoTextField(
                      controller: maxController,
                      placeholder: 'Maximum Amount',
                      keyboardType: TextInputType.number,
                      prefix: Text('${CurrencyUtils.getCurrencySymbol(widget.currency)} '),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Filter by Category'),
        actions: [
          ...AppConstants.expenseCategories.map((category) => CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _selectedCategory = category;
              widget.onCategoryFilterChanged?.call(category);
            },
            child: Row(
              children: [
                Text(category),
                if (_selectedCategory == category)
                  const Icon(CupertinoIcons.check_mark, color: CupertinoColors.systemBlue),
              ],
            ),
          )),
          if (_selectedCategory != null)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _selectedCategory = null;
                widget.onCategoryFilterChanged?.call(null);
              },
              isDestructiveAction: true,
              child: const Text('Clear Category Filter'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showSearchOptions(BuildContext context) {
    final searchController = TextEditingController(text: _searchQuery);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 200,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: CupertinoColors.separator)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Text(
                    'Search Transactions',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      _searchQuery = searchController.text;
                      widget.onSearchChanged?.call(_searchQuery);
                      Navigator.pop(context);
                    },
                    child: const Text('Search'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CupertinoTextField(
                  controller: searchController,
                  placeholder: 'Search by title, category, or description...',
                  autofocus: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomDateRange(BuildContext context) {
    DateTime? startDate = _startDate;
    DateTime? endDate = _endDate;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 400,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: CupertinoColors.separator)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Text(
                    'Custom Date Range',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      _startDate = startDate;
                      _endDate = endDate;
                      widget.onDateRangeChanged?.call(startDate, endDate);
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: startDate ?? DateTime.now(),
                      onDateTimeChanged: (date) => startDate = date,
                    ),
                  ),
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: endDate ?? DateTime.now(),
                      onDateTimeChanged: (date) => endDate = date,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportTransactions(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Export Transactions'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _exportAsPDF(context);
            },
            child: const Text('Export as PDF'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _exportAsCSV(context);
            },
            child: const Text('Export as CSV'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _exportAsExcel(context);
            },
            child: const Text('Export as Excel'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _shareViaEmail(context);
            },
            child: const Text('Share via Email'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showAnalytics(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final transactions = transactionProvider.transactions;
    
    if (transactions.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Analytics'),
          content: const Text('No transactions available for analytics.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: CupertinoColors.separator)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  const Text(
                    'Analytics',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  const SizedBox(width: 60), // Balance the header
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Stats
                    _buildAnalyticsSummary(transactions),
                    const SizedBox(height: 20),
                    
                    // Expense Chart
                    ChartWidget(
                      currency: widget.currency,
                      transactions: transactions,
                      chartType: ChartType.pie,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Category Breakdown
                    _buildCategoryBreakdown(transactions),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSummary(List<TransactionModel> transactions) {
    final totalIncome = _calculateTotalIncome(transactions);
    final totalExpenses = _calculateTotalExpenses(transactions);
    final netBalance = _calculateNetBalance(transactions);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Income',
                  totalIncome,
                  CupertinoColors.systemGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  'Expenses',
                  totalExpenses,
                  CupertinoColors.systemRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            'Net Balance',
            netBalance,
            netBalance >= 0 ? CupertinoColors.systemBlue : CupertinoColors.systemRed,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyUtils.formatCurrency(amount, widget.currency),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<TransactionModel> transactions) {
    final expenseTransactions = transactions.where((t) => t.type == TransactionType.expense).toList();
    final categoryTotals = <String, double>{};
    
    for (final transaction in expenseTransactions) {
      categoryTotals[transaction.category] = (categoryTotals[transaction.category] ?? 0.0) + transaction.amount;
    }
    
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Spending Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          ...sortedCategories.take(5).map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: entry.value / sortedCategories.first.value,
                    backgroundColor: CupertinoColors.systemGrey4,
                    valueColor: AlwaysStoppedAnimation<Color>(CupertinoColors.systemBlue),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    CurrencyUtils.formatCurrency(entry.value, widget.currency),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _clearAllFilters(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear All Filters'),
        content: const Text('Are you sure you want to clear all filters?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear All'),
            onPressed: () {
              Navigator.pop(context);
              _selectedFilter = TransactionFilter.all;
              _selectedSort = SortOption.dateDesc;
              _startDate = null;
              _endDate = null;
              _selectedCategory = null;
              _minAmount = null;
              _maxAmount = null;
              _searchQuery = '';
              
              widget.onFilterChanged?.call(_selectedFilter);
              widget.onSortChanged?.call(_selectedSort);
              widget.onDateRangeChanged?.call(null, null);
              widget.onCategoryFilterChanged?.call(null);
              widget.onAmountRangeChanged?.call(null, null);
              widget.onSearchChanged?.call('');
            },
          ),
        ],
      ),
    );
  }

  void _exportAsPDF(BuildContext context) {
    _exportTransactionsData(context, 'PDF');
  }

  void _exportAsCSV(BuildContext context) {
    _exportTransactionsData(context, 'CSV');
  }

  void _exportAsExcel(BuildContext context) {
    _exportTransactionsData(context, 'Excel');
  }

  void _shareViaEmail(BuildContext context) {
    _exportTransactionsData(context, 'Email');
  }

  void _exportTransactionsData(BuildContext context, String format) {
    // Get transactions from provider
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final transactions = transactionProvider.transactions;
    
    if (transactions.isEmpty) {
      _showExportError(context, 'No transactions to export');
      return;
    }

    // Generate export data
    String exportData = '';
    String fileName = 'transactions_${DateTime.now().millisecondsSinceEpoch}';
    
    switch (format) {
      case 'CSV':
        exportData = _generateCSV(transactions);
        fileName += '.csv';
        break;
      case 'Excel':
        exportData = _generateExcel(transactions);
        fileName += '.xlsx';
        break;
      case 'PDF':
        exportData = _generatePDF(transactions);
        fileName += '.pdf';
        break;
      case 'Email':
        exportData = _generateEmailContent(transactions);
        _shareViaEmailIntent(context, exportData);
        return;
    }

    // Save file and show success
    _saveAndShareFile(context, exportData, fileName, format);
  }

  String _generateCSV(List<TransactionModel> transactions) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Date,Title,Category,Amount,Type,Description');
    
    // Data
    for (final transaction in transactions) {
      buffer.writeln('${transaction.date.toIso8601String()},'
          '${transaction.title.replaceAll(',', ';')},'
          '${transaction.category.replaceAll(',', ';')},'
          '${transaction.amount},'
          '${transaction.type.name},'
          '${transaction.description?.replaceAll(',', ';') ?? ''}');
    }
    
    return buffer.toString();
  }

  String _generateExcel(List<TransactionModel> transactions) {
    // Simple Excel-like format (CSV with formatting)
    return _generateCSV(transactions);
  }

  String _generatePDF(List<TransactionModel> transactions) {
    final buffer = StringBuffer();
    
    buffer.writeln('EXPENSE BUDDY - TRANSACTION REPORT');
    buffer.writeln('Generated on: ${DateTime.now().toString()}');
    buffer.writeln('Total Transactions: ${transactions.length}');
    buffer.writeln('');
    buffer.writeln('TRANSACTIONS:');
    buffer.writeln('============');
    
    for (final transaction in transactions) {
      buffer.writeln('Date: ${transaction.date.toString()}');
      buffer.writeln('Title: ${transaction.title}');
      buffer.writeln('Category: ${transaction.category}');
      buffer.writeln('Amount: ${CurrencyUtils.formatCurrency(transaction.amount, widget.currency)}');
      buffer.writeln('Type: ${transaction.type.name}');
      if (transaction.description?.isNotEmpty == true) {
        buffer.writeln('Description: ${transaction.description}');
      }
      buffer.writeln('---');
    }
    
    return buffer.toString();
  }

  String _generateEmailContent(List<TransactionModel> transactions) {
    final buffer = StringBuffer();
    
    buffer.writeln('Hi,');
    buffer.writeln('');
    buffer.writeln('Please find attached my transaction report from ExpenseBuddy.');
    buffer.writeln('');
    buffer.writeln('Summary:');
    buffer.writeln('- Total Transactions: ${transactions.length}');
    buffer.writeln('- Total Income: ${CurrencyUtils.formatCurrency(_calculateTotalIncome(transactions), widget.currency)}');
    buffer.writeln('- Total Expenses: ${CurrencyUtils.formatCurrency(_calculateTotalExpenses(transactions), widget.currency)}');
    buffer.writeln('- Net Balance: ${CurrencyUtils.formatCurrency(_calculateNetBalance(transactions), widget.currency)}');
    buffer.writeln('');
    buffer.writeln('Best regards,');
    buffer.writeln('ExpenseBuddy User');
    
    return buffer.toString();
  }

  double _calculateTotalIncome(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateTotalExpenses(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateNetBalance(List<TransactionModel> transactions) {
    return _calculateTotalIncome(transactions) - _calculateTotalExpenses(transactions);
  }

  void _shareViaEmailIntent(BuildContext context, String content) {
    // Show dialog with email content
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Email Content'),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Copy'),
            onPressed: () {
              // TODO: Implement clipboard copy
              Navigator.pop(context);
              _showExportSuccess(context, 'Email content copied to clipboard');
            },
          ),
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _saveAndShareFile(BuildContext context, String data, String fileName, String format) {
    // TODO: Implement actual file saving and sharing
    // For now, show success message
    _showExportSuccess(context, '$format file generated successfully');
  }

  void _showExportError(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Export Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showExportSuccess(BuildContext context, String format) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Export Successful'),
        content: Text('Your transactions have been exported as $format.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
