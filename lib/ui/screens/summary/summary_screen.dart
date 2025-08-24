import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/expense_provider.dart';
import '../../../models/expense.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/chart_widget.dart';
import '../../../router/routes.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  @override
  void initState() {
    super.initState();
    // Load expenses when screen initializes
    context.read<ExpenseBloc>().add(LoadExpenses('demo_user'));
  }

  double _calculateTotalExpenses(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> _calculateCategoryTotals(List<Expense> expenses) {
    final Map<String, double> categoryTotals = {};

    for (final expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return categoryTotals;
  }

  String _getCurrentMonthName() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[now.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        return CupertinoPageScaffold(
          backgroundColor: AppTheme.getBackgroundColor(CupertinoTheme.brightnessOf(context)),
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              'Financial Summary',
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
          ),
          child: SafeArea(
            child: state is ExpenseLoading
              ? const Center(
                  child: CupertinoActivityIndicator(),
                )
              : state is ExpenseLoaded
                ? _buildSummaryContent(state.expenses)
                : state is ExpenseError
                  ? _buildErrorState(state.message)
                  : _buildEmptyState(),
          ),
        );
      },
    );
  }

  Widget _buildSummaryContent(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return _buildEmptyState();
    }

    final totalExpenses = _calculateTotalExpenses(expenses);
    final categoryTotals = _calculateCategoryTotals(expenses);
    final currentMonth = _getCurrentMonthName();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            '$currentMonth Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your spending patterns',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
          const SizedBox(height: 24),

          // Total Expenses Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.money_dollar_circle_fill,
                      color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total Expenses',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '\$${totalExpenses.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${expenses.length} transactions this month',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Spending Chart
          Text(
            'Spending by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
          const SizedBox(height: 16),
          ChartWidget(
            expenses: expenses,
            currency: 'USD',
          ),

          const SizedBox(height: 24),

          // Category Breakdown
          Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
          const SizedBox(height: 16),
          ...categoryTotals.entries.map((entry) {
            final percentage = (entry.value / totalExpenses) * 100;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(CupertinoTheme.brightnessOf(context)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${percentage.toStringAsFixed(1)}% of total',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${entry.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.chart_bar,
            size: 80,
            color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
          ),
          const SizedBox(height: 16),
          Text(
            'No data to analyze',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some expenses to see your financial summary',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: () => context.go(AppRoutes.expenses),
            child: Text(
              'Go to Expenses',
              style: TextStyle(
                color: CupertinoColors.white,
              ),
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
            size: 60,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
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
}
