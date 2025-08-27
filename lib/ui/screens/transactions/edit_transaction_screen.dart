import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';
import '../../../core/constants/app_constants.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;
  
  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  late String _selectedCategory;
  late String _selectedCurrency;
  late DateTime _selectedDate;
  late TransactionType _selectedType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current transaction data
    _titleController = TextEditingController(text: widget.transaction.title);
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _descriptionController = TextEditingController(text: widget.transaction.description ?? '');
    
    _selectedCategory = widget.transaction.category;
    _selectedCurrency = widget.transaction.currency;
    _selectedDate = widget.transaction.date;
    _selectedType = widget.transaction.type;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
            use24hFormat: true,
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
    final categories = _selectedType == TransactionType.expense 
        ? AppConstants.expenseCategories 
        : AppConstants.incomeCategories;
        
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
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32.0,
            scrollController: FixedExtentScrollController(
              initialItem: categories.indexOf(_selectedCategory),
            ),
            onSelectedItemChanged: (int selectedItem) {
              setState(() {
                _selectedCategory = categories[selectedItem];
              });
            },
            children: categories.map((String category) {
              return Center(child: Text(category));
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showCurrencyPicker() {
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
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32.0,
            scrollController: FixedExtentScrollController(
              initialItem: AppConstants.currencies.indexOf(_selectedCurrency),
            ),
            onSelectedItemChanged: (int selectedItem) {
              setState(() {
                _selectedCurrency = AppConstants.currencies[selectedItem];
              });
            },
            children: AppConstants.currencies.map((String currency) {
              return Center(child: Text(currency));
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _updateTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedTransaction = widget.transaction.copyWith(
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        category: _selectedCategory,
        currency: _selectedCurrency,
        date: _selectedDate,
        type: _selectedType,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await context.read<TransactionProvider>().updateTransaction(updatedTransaction);

      if (mounted) {
        // Show success message
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Success'),
            content: const Text('Transaction updated successfully'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  context.pop(true); // Return to previous screen with success result
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to update transaction: $e'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _deleteTransaction() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction? This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              
              try {
                await context.read<TransactionProvider>().deleteTransaction(widget.transaction.id);
                if (mounted) {
                  context.pop(true); // Return to previous screen
                }
              } catch (e) {
                if (mounted) {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Error'),
                      content: Text('Failed to delete transaction: $e'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Edit Transaction',
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _deleteTransaction,
              child: Icon(
                CupertinoIcons.delete,
                color: CupertinoColors.destructiveRed,
                size: 24,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _isLoading ? null : _updateTransaction,
              child: _isLoading 
                  ? const CupertinoActivityIndicator(radius: 10)
                  : Text(
                      'Save',
                      style: TextStyle(
                        color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Transaction Type Selector
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.resolveFrom(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CupertinoSlidingSegmentedControl<TransactionType>(
                  groupValue: _selectedType,
                  children: const {
                    TransactionType.expense: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('Expense'),
                    ),
                    TransactionType.income: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('Income'),
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

              // Title Field
              CupertinoFormSection(
                header: const Text('Title'),
                children: [
                  CupertinoTextFormFieldRow(
                    controller: _titleController,
                    placeholder: 'Enter title',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Amount Field
              CupertinoFormSection(
                header: const Text('Amount'),
                children: [
                  CupertinoTextFormFieldRow(
                    controller: _amountController,
                    placeholder: '0.00',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Amount must be greater than 0';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Category Field
              CupertinoFormSection(
                header: const Text('Category'),
                children: [
                  GestureDetector(
                    onTap: _showCategoryPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_selectedCategory),
                          const Icon(
                            CupertinoIcons.chevron_right,
                            color: CupertinoColors.systemGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Date Field
              CupertinoFormSection(
                header: const Text('Date'),
                children: [
                  GestureDetector(
                    onTap: _showDatePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                          const Icon(
                            CupertinoIcons.chevron_right,
                            color: CupertinoColors.systemGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Currency Field
              CupertinoFormSection(
                header: const Text('Currency'),
                children: [
                  GestureDetector(
                    onTap: _showCurrencyPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_selectedCurrency),
                          const Icon(
                            CupertinoIcons.chevron_right,
                            color: CupertinoColors.systemGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Description Field
              CupertinoFormSection(
                header: const Text('Description (Optional)'),
                children: [
                  CupertinoTextFormFieldRow(
                    controller: _descriptionController,
                    placeholder: 'Enter description',
                    maxLines: 3,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
