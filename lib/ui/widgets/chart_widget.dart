import 'package:flutter/cupertino.dart';
import '../../models/expense.dart';
import '../../core/theme/app_theme.dart';

class ChartWidget extends StatelessWidget {
  final List<Expense> expenses;
  final String currency;
  
  const ChartWidget({
    super.key,
    required this.expenses,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    // Group expenses by category
    final Map<String, double> categoryTotals = {};
    
    for (final expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.systemGrey4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...categoryTotals.entries.map((entry) {
            final percentage = (entry.value / categoryTotals.values.reduce((a, b) => a + b)) * 100;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(entry.key),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildProgressBar(percentage / 100, context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '$currency ${entry.value.toStringAsFixed(2)}',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double value, BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey4,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
