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
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.userId,
    this.createdAt,
    this.updatedAt,
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '📝',
      allocatedAmount: (json['allocatedAmount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
      periodType: json['periodType'] ?? 'monthly',
      startDate: _parseDateTime(json['startDate']) ?? DateTime.now(),
      endDate: _parseDateTime(json['endDate']) ?? DateTime.now().add(const Duration(days: 30)),
      color: json['color'] ?? '#2ECC71',
      userId: json['userId'],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'allocatedAmount': allocatedAmount,
      'spentAmount': spentAmount,
      'periodType': periodType,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'color': color,
      'userId': userId,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
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
