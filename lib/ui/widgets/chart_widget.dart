import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../utils/currency_utils.dart';

class ChartWidget extends StatelessWidget {
  final String currency;
  final List<TransactionModel> transactions;
  final ChartType chartType;
  
  const ChartWidget({
    super.key,
    required this.currency,
    required this.transactions,
    this.chartType = ChartType.pie,
  });

  @override
  Widget build(BuildContext context) {
    if (chartType == ChartType.bar) {
      return _buildBarChart(context);
    }
    
    final categoryTotals = _calculateCategoryTotals();
    final totalExpenses = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    
    if (categoryTotals.isEmpty) {
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
            Text(
              'Expense Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.chart_pie,
                    size: 48,
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No expenses yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add some expenses to see your spending breakdown',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expense Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                ),
              ),
              Text(
                'Total: ${CurrencyUtils.formatCurrency(totalExpenses, currency)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (chartType == ChartType.pie) ...[
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(categoryTotals, totalExpenses),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...categoryTotals.entries.map((entry) {
            final percentage = totalExpenses > 0 ? (entry.value / totalExpenses) * 100 : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildProgressBar(percentage / 100, context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Text(
                      CurrencyUtils.formatCurrency(entry.value, currency),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                        fontSize: 14,
                      ),
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

  Widget _buildBarChart(BuildContext context) {
    final weeklyData = _calculateWeeklyData();
    
    if (weeklyData.isEmpty) {
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
            Text(
              'Weekly Spending',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.chart_bar,
                    size: 48,
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No expenses yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add some expenses to see your weekly spending',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final maxAmount = weeklyData.values.fold(0.0, (max, amount) => amount > max ? amount : max);
    final totalWeekly = weeklyData.values.fold(0.0, (sum, amount) => sum + amount);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Spending',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                ),
              ),
              Text(
                'Total: ${CurrencyUtils.formatCurrency(totalWeekly, currency)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxAmount * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${CurrencyUtils.formatCurrency(rod.toY, currency)}',
                        TextStyle(
                          color: AppTheme.getTextPrimaryColor(CupertinoTheme.brightnessOf(context)),
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value >= 0 && value < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[value.toInt()],
                              style: TextStyle(
                                color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          CurrencyUtils.formatCurrency(value, currency),
                          style: TextStyle(
                            color: AppTheme.getTextSecondaryColor(CupertinoTheme.brightnessOf(context)),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: weeklyData.entries.map((entry) {
                  final index = entry.key;
                  final amount = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: amount,
                        color: AppTheme.getPrimaryColor(CupertinoTheme.brightnessOf(context)),
                        width: 20,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: maxAmount > 0 ? maxAmount / 4 : 1.0,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: CupertinoColors.systemGrey5,
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<int, double> _calculateWeeklyData() {
    final Map<int, double> weeklyData = {};
    
    // Initialize all days with 0
    for (int i = 0; i < 7; i++) {
      weeklyData[i] = 0.0;
    }
    
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        final daysDiff = transaction.date.difference(startOfWeek).inDays;
        if (daysDiff >= 0 && daysDiff < 7) {
          weeklyData[daysDiff] = (weeklyData[daysDiff] ?? 0.0) + transaction.amount;
        }
      }
    }
    
    return weeklyData;
  }

  Map<String, double> _calculateCategoryTotals() {
    final Map<String, double> categoryTotals = {};
    
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        final category = transaction.category;
        categoryTotals[category] = (categoryTotals[category] ?? 0.0) + transaction.amount;
      }
    }
    
    // Sort by amount (highest first)
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries);
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> categoryTotals, double total) {
    final colors = [
      const Color(0xFF2ECC71), // Green
      const Color(0xFF3498DB), // Blue
      const Color(0xFFE74C3C), // Red
      const Color(0xFFF39C12), // Orange
      const Color(0xFF9B59B6), // Purple
      const Color(0xFF1ABC9C), // Teal
      const Color(0xFFE67E22), // Dark Orange
      const Color(0xFF34495E), // Dark Blue
      const Color(0xFF95A5A6), // Gray
      const Color(0xFFF1C40F), // Yellow
    ];

    return categoryTotals.entries.map((entry) {
      final index = entry.key.hashCode % colors.length;
      final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;
      
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.white,
        ),
      );
    }).toList();
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

enum ChartType {
  pie,
  bar,
  line,
}
