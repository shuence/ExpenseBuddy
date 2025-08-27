import 'package:flutter/foundation.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService _budgetService = BudgetService();
  
  List<BudgetModel> _budgets = [];
  BudgetSummary? _budgetSummary;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<BudgetModel> get budgets => _budgets;
  BudgetSummary? get budgetSummary => _budgetSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load all budgets for a user
  Future<void> loadBudgets(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _budgets = await _budgetService.getAllBudgets(userId);
      _budgetSummary = await _budgetService.getBudgetSummary(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load budgets for a specific month
  Future<void> loadBudgetsForMonth(String userId, DateTime month) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _budgets = await _budgetService.getBudgetsForMonth(userId, month);
      _budgetSummary = await _budgetService.getBudgetSummaryForMonth(userId, month);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Add new budget
  Future<void> addBudget(BudgetModel budget) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _budgetService.createBudget(budget);
      // Reload budgets and summary to get updated spent amounts
      if (budget.userId != null) {
        await loadBudgets(budget.userId!);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Refresh budgets (useful when transactions change)
  Future<void> refreshBudgets(String userId) async {
    try {
      _budgets = await _budgetService.getAllBudgets(userId);
      _budgetSummary = await _budgetService.getBudgetSummary(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Refresh budgets for a specific month
  Future<void> refreshBudgetsForMonth(String userId, DateTime month) async {
    try {
      _budgets = await _budgetService.getBudgetsForMonth(userId, month);
      _budgetSummary = await _budgetService.getBudgetSummaryForMonth(userId, month);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Update existing budget
  Future<void> updateBudget(BudgetModel budget) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _budgetService.updateBudget(budget);
      
      // Update in local list
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index >= 0) {
        _budgets[index] = budget;
      }
      
      // Reload summary
      if (budget.userId != null) {
        _budgetSummary = await _budgetService.getBudgetSummary(budget.userId!);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Delete budget
  Future<void> deleteBudget(String budgetId, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _budgetService.deleteBudget(budgetId);
      
      // Remove from local list
      _budgets.removeWhere((b) => b.id == budgetId);
      
      // Reload summary
      _budgetSummary = await _budgetService.getBudgetSummary(userId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Get budget by category
  BudgetModel? getBudgetByCategory(String category) {
    try {
      return _budgets.firstWhere((budget) => budget.name == category);
    } catch (e) {
      return null;
    }
  }
  
  // Get budgets by period
  List<BudgetModel> getBudgetsByPeriod(String periodType) {
    return _budgets.where((budget) => budget.periodType == periodType).toList();
  }
  
  // Calculate total spent amount
  double get totalSpent {
    return _budgets.fold(0.0, (sum, budget) => sum + budget.spentAmount);
  }
  
  // Calculate total allocated amount
  double get totalAllocated {
    return _budgets.fold(0.0, (sum, budget) => sum + budget.allocatedAmount);
  }
  
  // Calculate remaining budget
  double get totalRemaining {
    return totalAllocated - totalSpent;
  }
  
  // Calculate spending percentage
  double get spendingPercentage {
    if (totalAllocated == 0) return 0.0;
    return (totalSpent / totalAllocated * 100).clamp(0.0, 100.0);
  }
  
  // Clear all data
  void clearData() {
    _budgets.clear();
    _budgetSummary = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
