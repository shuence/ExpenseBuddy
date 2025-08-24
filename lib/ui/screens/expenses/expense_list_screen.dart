import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/expense_provider.dart';
import '../../../models/expense.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/responsive_constants.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/currency_toggle.dart';
import '../../widgets/theme_toggle.dart';
import '../../dialogs/confirm_delete_dialog.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String _selectedCurrency = 'USD';
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD'];

  @override
  void initState() {
    super.initState();
    // Load expenses when screen initializes
    context.read<ExpenseBloc>().add(LoadExpenses('demo_user'));
  }

  void _onCurrencyChanged(String currency) {
    setState(() {
      _selectedCurrency = currency;
    });
  }

  void _addExpense() {
    context.push('/add-expense');
  }

  void _editExpense(Expense expense) {
    context.push('/edit-expense', extra: expense);
  }

  void _deleteExpense(Expense expense) {
    showCupertinoDialog(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        title: 'Delete Expense',
        message: 'Are you sure you want to delete "${expense.title}"?',
        onConfirm: () {
          context.read<ExpenseBloc>().add(DeleteExpense(expense.id));
          Navigator.of(context).pop();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _viewSummary() {
    context.push('/summary');
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        return CupertinoPageScaffold(
          backgroundColor: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              'My Expenses',
              style: TextStyle(
                color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ThemeToggle(),
                                 SizedBox(width: ResponsiveConstants.spacing8),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _viewSummary,
                  child: Icon(
                    CupertinoIcons.chart_bar,
                    color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                  ),
                ),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Currency Toggle
                CurrencyToggle(
                  selectedCurrency: _selectedCurrency,
                  currencies: _currencies,
                  onCurrencyChanged: _onCurrencyChanged,
                ),

                // Expense List
                Expanded(
                  child: state is ExpenseLoading
                    ? const Center(
                        child: CupertinoActivityIndicator(),
                      )
                    : state is ExpenseLoaded
                      ? state.expenses.isEmpty
                        ? _buildEmptyState()
                        : _buildExpenseList(state.expenses)
                      : state is ExpenseError
                        ? _buildErrorState(state.message)
                        : _buildEmptyState(),
                ),

                // Add Expense Button
                Container(
                                     padding: EdgeInsets.all(ResponsiveConstants.spacing16),
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)).withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: _addExpense,
                                             padding: EdgeInsets.symmetric(vertical: ResponsiveConstants.spacing16),
                       borderRadius: BorderRadius.circular(ResponsiveConstants.radius12),
                       child: Text(
                         'Add New Expense',
                         style: TextStyle(
                           fontSize: ResponsiveConstants.fontSize16,
                           fontWeight: FontWeight.w600,
                           color: CupertinoColors.white,
                         ),
                       ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.money_dollar_circle,
            size: ResponsiveConstants.iconSize80,
            color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
          ),
          SizedBox(height: ResponsiveConstants.spacing16),
          Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize20,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
          SizedBox(height: ResponsiveConstants.spacing8),
          Text(
            'Tap "Add New Expense" to get started',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: ResponsiveConstants.iconSize64,
            color: AppTheme.errorColor,
          ),
          SizedBox(height: ResponsiveConstants.spacing16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: ResponsiveConstants.fontSize18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
          SizedBox(height: ResponsiveConstants.spacing8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveConstants.spacing24),
          CupertinoButton.filled(
            onPressed: () {
              context.read<ExpenseBloc>().add(LoadExpenses('demo_user'));
            },
            child: Text(
              'Try Again',
              style: TextStyle(
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(List<Expense> expenses) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: ResponsiveConstants.spacing16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return ExpenseCard(
          expense: expense,
          onTap: () => _editExpense(expense),
          onDelete: () => _deleteExpense(expense),
        );
      },
    );
  }
}
