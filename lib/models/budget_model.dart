class BudgetModel {
  final String id;
  final String name;
  final String icon;
  final double allocatedAmount;
  final double spentAmount;
  final String periodType; // monthly, weekly, yearly
  final DateTime startDate;
  final DateTime endDate;
  final String color;

  BudgetModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.color,
  });

  double get remainingAmount => allocatedAmount - spentAmount;
  double get spentPercentage => (spentAmount / allocatedAmount * 100).clamp(0, 100);
  
  String get status {
    final percentage = spentPercentage;
    if (percentage >= 90) return 'Near limit';
    if (percentage >= 75) return 'Warning';
    return 'On track';
  }

  String get changePercentage {
    // Mock percentage change (in real app, calculate based on previous period)
    return ['5%', '-10%', '0%', '15%', '-5%'][(name.hashCode % 5)];
  }

  bool get isPositiveChange => !changePercentage.startsWith('-');

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      allocatedAmount: json['allocatedAmount'].toDouble(),
      spentAmount: json['spentAmount'].toDouble(),
      periodType: json['periodType'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'allocatedAmount': allocatedAmount,
      'spentAmount': spentAmount,
      'periodType': periodType,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'color': color,
    };
  }
}

class BudgetSummary {
  final double totalBudget;
  final double totalSpent;
  final double spentPercentage;
  final List<BudgetModel> budgets;

  BudgetSummary({
    required this.totalBudget,
    required this.totalSpent,
    required this.spentPercentage,
    required this.budgets,
  });

  double get remainingBudget => totalBudget - totalSpent;
}
