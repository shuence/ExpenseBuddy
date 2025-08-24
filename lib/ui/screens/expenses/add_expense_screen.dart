import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/expense_provider.dart';
import '../../../models/expense.dart';
import '../../../core/theme/app_theme.dart';
import '../../../router/routes.dart';
// Generate simple ID for demo purposes
String _generateId() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Food & Drinks';
  String _selectedCurrency = 'USD';
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Food & Drinks',
    'Transportation',
    'Entertainment',
    'Shopping',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Other'
  ];

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD'];

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                maximumDate: DateTime.now(),
                onDateTimeChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: _categories.indexOf(_selectedCategory),
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedCategory = _categories[index];
                  });
                },
                children: _categories.map((category) {
                  return Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 200,
        color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: _currencies.indexOf(_selectedCurrency),
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedCurrency = _currencies[index];
                  });
                },
                children: _currencies.map((currency) {
                  return Center(
                    child: Text(
                      currency,
                      style: TextStyle(
                        color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveExpense() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final expense = Expense(
          id: _generateId(),
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text),
          category: _selectedCategory,
          date: _selectedDate,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          userId: 'demo_user',
          currency: _selectedCurrency,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        context.read<ExpenseBloc>().add(AddExpense(expense));

        if (mounted) {
          context.go(AppRoutes.expenses);
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Error', 'Failed to save expense. Please try again.');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Add Expense',
          style: TextStyle(
            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
          child: Icon(
            CupertinoIcons.back,
            color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isLoading ? null : _saveExpense,
          child: _isLoading
              ? const CupertinoActivityIndicator(color: CupertinoColors.activeBlue)
              : Text(
                  'Save',
                  style: TextStyle(
                    color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                Text(
                  'Title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                  ),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _titleController,
                  placeholder: 'Enter expense title',
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)).withOpacity(0.3),
                    ),
                  ),
                  style: TextStyle(
                    color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                  ),
                  placeholderStyle: TextStyle(
                    color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                  ),
                ),

                const SizedBox(height: 24),

                // Amount Field
                Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        controller: _amountController,
                        placeholder: '0.00',
                        keyboardType: TextInputType.number,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)).withOpacity(0.3),
                          ),
                        ),
                        style: TextStyle(
                          color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                        ),
                        placeholderStyle: TextStyle(
                          color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CupertinoButton(
                      onPressed: _showCurrencyPicker,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
                      borderRadius: BorderRadius.circular(12),
                      child: Text(
                        _selectedCurrency,
                        style: TextStyle(
                          color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Category Field
                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                  ),
                ),
                const SizedBox(height: 8),
                CupertinoButton(
                  onPressed: _showCategoryPicker,
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedCategory,
                          style: TextStyle(
                            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                          ),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_down,
                        color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Date Field
                Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                  ),
                ),
                const SizedBox(height: 8),
                CupertinoButton(
                  onPressed: _showDatePicker,
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: TextStyle(
                            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                          ),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.calendar,
                        color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Description Field
                Text(
                  'Description (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                  ),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _descriptionController,
                  placeholder: 'Add a description...',
                  maxLines: 3,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)).withOpacity(0.3),
                    ),
                  ),
                  style: TextStyle(
                    color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                  ),
                  placeholderStyle: TextStyle(
                    color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                  ),
                ),

                const SizedBox(height: 40),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    onPressed: _isLoading ? null : _saveExpense,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    borderRadius: BorderRadius.circular(12),
                    child: _isLoading
                        ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                        : Text(
                            'Save Expense',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
