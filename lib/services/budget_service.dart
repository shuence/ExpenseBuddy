import '../models/budget_model.dart';

class BudgetService {
  static final BudgetService _instance = BudgetService._internal();
  factory BudgetService() => _instance;
  BudgetService._internal();

  Future<BudgetSummary> getBudgetSummary() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final budgets = await getAllBudgets();
    final totalBudget = budgets.fold(0.0, (sum, budget) => sum + budget.allocatedAmount);
    final totalSpent = budgets.fold(0.0, (sum, budget) => sum + budget.spentAmount);
    final spentPercentage = (totalSpent / totalBudget * 100).clamp(0.0, 100.0);

    return BudgetSummary(
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      spentPercentage: spentPercentage,
      budgets: budgets,
    );
  }

  Future<List<BudgetModel>> getAllBudgets() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mock data matching the design
    return [
      BudgetModel(
        id: '1',
        name: 'Food & Dining',
        icon: '🍽️',
        allocatedAmount: 800,
        spentAmount: 600,
        periodType: 'monthly',
        startDate: DateTime(2023, 9, 1),
        endDate: DateTime(2023, 9, 30),
        color: '#2ECC71',
      ),
      BudgetModel(
        id: '2',
        name: 'Transportation',
        icon: '🚗',
        allocatedAmount: 400,
        spentAmount: 180,
        periodType: 'monthly',
        startDate: DateTime(2023, 9, 1),
        endDate: DateTime(2023, 9, 30),
        color: '#3498DB',
      ),
      BudgetModel(
        id: '3',
        name: 'Bills & Utilities',
        icon: '⚡',
        allocatedAmount: 1000,
        spentAmount: 900,
        periodType: 'monthly',
        startDate: DateTime(2023, 9, 1),
        endDate: DateTime(2023, 9, 30),
        color: '#E74C3C',
      ),
      BudgetModel(
        id: '4',
        name: 'Entertainment',
        icon: '💳',
        allocatedAmount: 500,
        spentAmount: 300,
        periodType: 'monthly',
        startDate: DateTime(2023, 9, 1),
        endDate: DateTime(2023, 9, 30),
        color: '#9B59B6',
      ),
    ];
  }

  Future<BudgetModel> getBudgetById(String id) async {
    final budgets = await getAllBudgets();
    return budgets.firstWhere((budget) => budget.id == id);
  }

  Future<void> updateBudget(BudgetModel budget) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    // In real app, update budget in database
  }

  Future<void> createBudget(BudgetModel budget) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    // In real app, create budget in database
  }

  Future<void> deleteBudget(String id) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    // In real app, delete budget from database
  }
}
