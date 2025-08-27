import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../models/transaction_model.dart';
import 'loading_overlay.dart';
import 'transaction_loading_widget.dart';

class TransactionFormLoadingExample extends StatefulWidget {
  const TransactionFormLoadingExample({super.key});

  @override
  State<TransactionFormLoadingExample> createState() => _TransactionFormLoadingExampleState();
}

class _TransactionFormLoadingExampleState extends State<TransactionFormLoadingExample> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = 'Food';
  TransactionType _selectedType = TransactionType.expense;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        date: _selectedDate,
        description: _descriptionController.text.trim(),
        userId: 'current_user_id', // Replace with actual user ID
        currency: 'USD',
        type: _selectedType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final transactionProvider = context.read<TransactionProvider>();
      await transactionProvider.addTransaction(transaction);

      // Clear form on success
      _formKey.currentState!.reset();
      _titleController.clear();
      _amountController.clear();
      _descriptionController.clear();
      
      if (mounted) {
        _showSuccessAlert();
      }
    } catch (e) {
      if (mounted) {
        _showErrorAlert(e.toString());
      }
    }
  }

  void _showSuccessAlert() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: const Text('Transaction added successfully!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showErrorAlert(String error) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text('Failed to add transaction: $error'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        return LoadingOverlay(
          isLoading: transactionProvider.isAddingTransaction,
          message: 'Adding transaction...',
          child: CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text('Add Transaction'),
            ),
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Title field
                    CupertinoFormSection(
                      header: const Text('Transaction Details'),
                      children: [
                        CupertinoTextFormFieldRow(
                          controller: _titleController,
                          placeholder: 'Transaction title',
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
                    
                    // Amount field
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
                    
                    // Category and Type
                    CupertinoFormSection(
                      header: const Text('Category & Type'),
                      children: [
                        CupertinoSlidingSegmentedControl<String>(
                          groupValue: _selectedCategory,
                          children: const {
                            'Food': Text('Food'),
                            'Transport': Text('Transport'),
                            'Shopping': Text('Shopping'),
                            'Bills': Text('Bills'),
                            'Other': Text('Other'),
                          },
                          onValueChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedCategory = value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        CupertinoSlidingSegmentedControl<TransactionType>(
                          groupValue: _selectedType,
                          children: const {
                            TransactionType.expense: Text('Expense'),
                            TransactionType.income: Text('Income'),
                          },
                          onValueChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedType = value);
                            }
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description field
                    CupertinoFormSection(
                      header: const Text('Description (Optional)'),
                      children: [
                        CupertinoTextFormFieldRow(
                          controller: _descriptionController,
                          placeholder: 'Add a description...',
                          maxLines: 3,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        onPressed: transactionProvider.isAddingTransaction 
                            ? null 
                            : _submitTransaction,
                        child: transactionProvider.isAddingTransaction
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CupertinoActivityIndicator(color: CupertinoColors.white),
                                  SizedBox(width: 8),
                                  Text('Adding...'),
                                ],
                              )
                            : const Text('Add Transaction'),
                      ),
                    ),
                    
                    // Loading indicator at bottom
                    if (transactionProvider.isAddingTransaction) ...[
                      const SizedBox(height: 24),
                      const TransactionLoadingWidget(
                        message: 'Saving transaction to local database and syncing...',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
