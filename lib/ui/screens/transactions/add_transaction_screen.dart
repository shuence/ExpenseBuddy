import 'package:expensebuddy/services/user_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/budget_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/user_preferences_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final UserPreferencesService _userPreferencesService = UserPreferencesService();

  String _selectedCategory = AppConstants.expenseCategories.first;
  String _selectedCurrency = AppConstants.currencies.first;
  String _userDefaultCurrency = AppConstants.currencies.first;
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.expense;
  bool _isLoadingCurrency = true;
  bool _showAmountError = false;
  bool _showTitleError = false;

  @override
  void initState() {
    super.initState();
    _loadUserDefaultCurrency();
  }

  Future<void> _loadUserDefaultCurrency() async {
    try {
      final defaultCurrency = await _userPreferencesService.getUserDefaultCurrency();
      if (mounted) {
        setState(() {
          _selectedCurrency = defaultCurrency;
          _userDefaultCurrency = defaultCurrency;
          _isLoadingCurrency = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCurrency = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  void _showDatePicker() {
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
            initialDateTime: _selectedDate,
            mode: CupertinoDatePickerMode.date,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                _selectedDate = newDate;
              });
            },
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: CupertinoColors.separator),
                  ),
                ),
                child: const Text(
                  'Select Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedCategory = AppConstants.expenseCategories[index];
                    });
                  },
                  children: AppConstants.expenseCategories
                      .map((category) => Center(child: Text(category)))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: CupertinoColors.separator),
                  ),
                ),
                child: const Text(
                  'Select Currency',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
                             Expanded(
                 child: CupertinoPicker(
                   itemExtent: 40,
                   scrollController: FixedExtentScrollController(
                     initialItem: AppConstants.currencies.indexOf(_selectedCurrency),
                   ),
                   onSelectedItemChanged: (int index) {
                     setState(() {
                       _selectedCurrency = AppConstants.currencies[index];
                     });
                   },
                   children: AppConstants.currencies.map((currency) => 
                     Center(
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Text(currency),
                           if (currency == _userDefaultCurrency) ...[
                             const SizedBox(width: 8),
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                               decoration: BoxDecoration(
                                 color: const Color(0xFF2ECC71).withOpacity(0.1),
                                 borderRadius: BorderRadius.circular(4),
                               ),
                               child: Text(
                                 'Default',
                                 style: TextStyle(
                                   fontSize: 10,
                                   color: const Color(0xFF2ECC71),
                                   fontWeight: FontWeight.w500,
                                 ),
                               ),
                             ),
                           ],
                         ],
                       ),
                     ),
                   ).toList(),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() async {
    // Reset error states
    setState(() {
      _showTitleError = false;
      _showAmountError = false;
    });

    // Validate title is not empty
    if (_titleController.text.trim().isEmpty) {
      setState(() {
        _showTitleError = true;
      });
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Title Required'),
          content: const Text('Please enter a title for the transaction.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Validate amount is not empty and is a valid number
    if (_amountController.text.trim().isEmpty) {
      setState(() {
        _showAmountError = true;
      });
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Amount Required'),
          content: const Text('Please enter an amount for the transaction.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Validate amount is a valid number
    double? amount;
    try {
      amount = double.parse(_amountController.text.trim());
      if (amount <= 0) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Invalid Amount'),
            content: const Text('Please enter a valid amount greater than 0.'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Invalid Amount'),
          content: const Text('Please enter a valid number for the amount.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Get current user ID
      String? userId;
      try {
        final userService = UserService();
        final currentUser = await userService.getCurrentUser();
        userId = currentUser?.uid;
      } catch (e) {
        debugPrint('Error getting user: $e');
      }
      
      if (userId == null) {
        // Show error if user not found
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: const Text('Unable to save transaction. Please try again.'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }

      final transaction = TransactionModel(
        id: _generateId(),
        title: _titleController.text.trim(),
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        userId: userId,
        currency: _selectedCurrency,
        type: _selectedType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await context.read<TransactionProvider>().addTransaction(transaction);
        
        // Refresh budgets if it's an expense (to update spent amounts)
        if (transaction.type == TransactionType.expense && mounted) {
          final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
          // Refresh budgets for the current month and the transaction month
          final currentMonth = DateTime.now();
          final transactionMonth = transaction.date;
          
          // Refresh both months if they're different
          await budgetProvider.refreshBudgetsForMonth(userId, currentMonth);
          if (currentMonth.month != transactionMonth.month || currentMonth.year != transactionMonth.year) {
            await budgetProvider.refreshBudgetsForMonth(userId, transactionMonth);
          }
        }
        
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text('Failed to save transaction: $e'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _selectedType == TransactionType.income;
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          isIncome ? 'Add Income' : 'Add Expense',
          style: TextStyle(
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
        border: null,
        leading: CupertinoNavigationBarBackButton(
          color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
          onPressed: () =>context.pop(),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveTransaction,
          child: Text(
            'Save',
            style: TextStyle(
              color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      backgroundColor: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Section with Amount Input
                      _buildHeroSection(context, isIncome),
                      
                      const SizedBox(height: 32),
                      
                      // Transaction Details Section
                      _buildDetailsSection(context),
                      
                      const SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isIncome) {
    final typeColor = isIncome 
        ? const Color(0xFF2ECC71) 
        : const Color(0xFFE74C3C);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            typeColor.withOpacity(0.1),
            typeColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: typeColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Transaction Type Selector
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CupertinoSlidingSegmentedControl<TransactionType>(
              groupValue: _selectedType,
              children: {
                TransactionType.expense: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.minus_circle_fill,
                        color: _selectedType == TransactionType.expense 
                            ? CupertinoColors.white
                            : const Color(0xFFE74C3C),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text('Expense'),
                    ],
                  ),
                ),
                TransactionType.income: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.plus_circle_fill,
                        color: _selectedType == TransactionType.income 
                            ? CupertinoColors.white
                            : const Color(0xFF2ECC71),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text('Income'),
                    ],
                  ),
                ),
              },
              onValueChanged: (TransactionType? value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                    // Reset category when type changes
                    _selectedCategory = value == TransactionType.expense 
                        ? AppConstants.expenseCategories.first
                        : AppConstants.incomeCategories.first;
                  });
                }
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Amount Input Section
          Column(
            children: [
              Text(
                'Amount',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                   _isLoadingCurrency 
                       ? CupertinoActivityIndicator(radius: 12)
                       : Text(
                           _selectedCurrency,
                           style: TextStyle(
                             fontSize: 24,
                             color: typeColor,
                             fontWeight: FontWeight.w600,
                           ),
                         ),
                  
                  const SizedBox(width: 8),
                  
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CupertinoTextField(
                          controller: _amountController,
                          placeholder: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: typeColor,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _showAmountError
                                  ? CupertinoColors.systemRed
                                  : CupertinoColors.systemGrey5,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          onChanged: (value) {
                            setState(() {
                              _showAmountError = false;
                            });
                          },
                        ),
                        if (_showAmountError)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 16),
                            child: Text(
                              'Amount is required',
                              style: TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.systemRed,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Title Field
        _buildDetailCard(
          context,
          icon: CupertinoIcons.textformat,
          title: 'Title *',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CupertinoTextField(
                controller: _titleController,
                placeholder: 'Enter transaction title',
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _showTitleError
                        ? CupertinoColors.systemRed
                        : CupertinoColors.systemGrey5,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                onChanged: (value) {
                  setState(() {
                    _showTitleError = false;
                  });
                },
              ),
              if (_showTitleError)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 16),
                  child: Text(
                    'Title is required',
                    style: TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemRed,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Category Field
        _buildDetailCard(
          context,
          icon: CupertinoIcons.tag,
          title: 'Category',
          child: GestureDetector(
            onTap: _showCategoryPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.systemGrey,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Date and Currency Row
        Row(
          children: [
            // Date Field
            Expanded(
              child: _buildDetailCard(
                context,
                icon: CupertinoIcons.calendar,
                title: 'Date',
                child: GestureDetector(
                  onTap: _showDatePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                          ),
                        ),
                        Icon(
                          CupertinoIcons.chevron_right,
                          color: CupertinoColors.systemGrey,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Currency Field
            Expanded(
              child: _buildDetailCard(
                context,
                icon: CupertinoIcons.money_dollar_circle,
                title: 'Currency',
                child: GestureDetector(
                  onTap: _showCurrencyPicker,
                                       child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 _selectedCurrency,
                                 style: TextStyle(
                                   fontSize: 16,
                                   color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                                 ),
                               ),
                               if (_selectedCurrency == _userDefaultCurrency)
                                 Text(
                                   'Default',
                                   style: TextStyle(
                                     fontSize: 12,
                                     color: CupertinoColors.systemGrey,
                                   ),
                                 ),
                             ],
                           ),
                           Icon(
                             CupertinoIcons.chevron_right,
                             color: CupertinoColors.systemGrey,
                             size: 18,
                           ),
                         ],
                       ),
                     ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Description Field
        _buildDetailCard(
          context,
          icon: CupertinoIcons.doc_text,
          title: 'Description (Optional)',
          child: CupertinoTextField(
            controller: _descriptionController,
            placeholder: 'Add a note about this transaction...',
            maxLines: 3,
            decoration: const BoxDecoration(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemGrey5.resolveFrom(context),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4.resolveFrom(context).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6.resolveFrom(context).withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          child,
        ],
      ),
    );
  }
}
