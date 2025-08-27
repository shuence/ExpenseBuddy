import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collections
  CollectionReference get budgetsCollection => _firestore.collection('budgets');
  CollectionReference get transactionsCollection => _firestore.collection('transactions');
  
  // Get budget summary for a user
  Future<BudgetSummary> getBudgetSummary(String userId) async {
    final budgets = await getAllBudgets(userId);
    
    if (budgets.isEmpty) {
      return BudgetSummary(
        totalBudget: 0.0,
        totalSpent: 0.0,
        spentPercentage: 0.0,
        budgets: [],
      );
    }
    
    final totalBudget = budgets.fold(0.0, (sum, budget) => sum + budget.allocatedAmount);
    final totalSpent = budgets.fold(0.0, (sum, budget) => sum + budget.spentAmount);
    final spentPercentage = totalBudget > 0 ? (totalSpent / totalBudget * 100).clamp(0.0, 100.0) : 0.0;

    return BudgetSummary(
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      spentPercentage: spentPercentage,
      budgets: budgets,
    );
  }

  // Get budget summary for a specific month
  Future<BudgetSummary> getBudgetSummaryForMonth(String userId, DateTime month) async {
    final budgets = await getBudgetsForMonth(userId, month);
    
    if (budgets.isEmpty) {
      return BudgetSummary(
        totalBudget: 0.0,
        totalSpent: 0.0,
        spentPercentage: 0.0,
        budgets: [],
      );
    }
    
    final totalBudget = budgets.fold(0.0, (sum, budget) => sum + budget.allocatedAmount);
    final totalSpent = budgets.fold(0.0, (sum, budget) => sum + budget.spentAmount);
    final spentPercentage = totalBudget > 0 ? (totalSpent / totalBudget * 100).clamp(0.0, 100.0) : 0.0;

    return BudgetSummary(
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      spentPercentage: spentPercentage,
      budgets: budgets,
    );
  }

  // Get all budgets for a user
  Future<List<BudgetModel>> getAllBudgets(String userId) async {
    try {
      final snapshot = await budgetsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: false)
          .get();
      
      List<BudgetModel> budgets = snapshot.docs
          .map((doc) => BudgetModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
      
      // Calculate spent amounts for each budget
      List<BudgetModel> updatedBudgets = [];
      for (BudgetModel budget in budgets) {
        final spentAmount = await _calculateSpentAmount(userId, budget);
        updatedBudgets.add(BudgetModel(
          id: budget.id,
          name: budget.name,
          icon: budget.icon,
          allocatedAmount: budget.allocatedAmount,
          spentAmount: spentAmount,
          periodType: budget.periodType,
          startDate: budget.startDate,
          endDate: budget.endDate,
          color: budget.color,
          userId: budget.userId,
          createdAt: budget.createdAt,
          updatedAt: budget.updatedAt,
        ));
      }
      budgets = updatedBudgets;
      
      return budgets;
    } catch (e) {
      print('Error getting budgets: $e');
      return [];
    }
  }

  // Stream all budgets for a user (real-time updates)
  Stream<List<BudgetModel>> getUserBudgetsStream(String userId) {
    return budgetsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BudgetModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
            .toList());
  }

  // Calculate spent amount for a budget based on transactions
  Future<double> _calculateSpentAmount(String userId, BudgetModel budget) async {
    try {
      final snapshot = await transactionsCollection
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: budget.name)
          .where('type', isEqualTo: 'expense')
          .where('date', isGreaterThanOrEqualTo: budget.startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: budget.endDate.toIso8601String())
          .get();

      return snapshot.docs.fold<double>(0.0, (double sum, QueryDocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + (data['amount'] as num).toDouble();
      });
    } catch (e) {
      print('Error calculating spent amount: $e');
      return 0.0;
    }
  }

  // Get budget by ID
  Future<BudgetModel?> getBudgetById(String id) async {
    try {
      final doc = await budgetsCollection.doc(id).get();
      if (doc.exists) {
        return BudgetModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error getting budget by ID: $e');
      return null;
    }
  }

  // Create new budget
  Future<void> createBudget(BudgetModel budget) async {
    try {
      await budgetsCollection.add(budget.toJson());
    } catch (e) {
      print('Error creating budget: $e');
      throw Exception('Failed to create budget');
    }
  }

  // Update existing budget
  Future<void> updateBudget(BudgetModel budget) async {
    try {
      await budgetsCollection.doc(budget.id).update(budget.toJson());
    } catch (e) {
      print('Error updating budget: $e');
      throw Exception('Failed to update budget');
    }
  }

  // Delete budget
  Future<void> deleteBudget(String id) async {
    try {
      await budgetsCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting budget: $e');
      throw Exception('Failed to delete budget');
    }
  }

  // Get budget by category name
  Future<BudgetModel?> getBudgetByCategory(String userId, String category) async {
    try {
      final snapshot = await budgetsCollection
          .where('userId', isEqualTo: userId)
          .where('name', isEqualTo: category)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return BudgetModel.fromJson({...snapshot.docs.first.data() as Map<String, dynamic>, 'id': snapshot.docs.first.id});
      }
      return null;
    } catch (e) {
      print('Error getting budget by category: $e');
      return null;
    }
  }

  // Get budgets by period (monthly, weekly, yearly)
  Future<List<BudgetModel>> getBudgetsByPeriod(String userId, String periodType) async {
    try {
      final snapshot = await budgetsCollection
          .where('userId', isEqualTo: userId)
          .where('periodType', isEqualTo: periodType)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => BudgetModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting budgets by period: $e');
      return [];
    }
  }

  // Get budgets for a specific month
  Future<List<BudgetModel>> getBudgetsForMonth(String userId, DateTime month) async {
    try {
      // Calculate month boundaries
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final snapshot = await budgetsCollection
          .where('userId', isEqualTo: userId)
          .where('startDate', isLessThanOrEqualTo: endOfMonth.toIso8601String())
          .where('endDate', isGreaterThanOrEqualTo: startOfMonth.toIso8601String())
          .orderBy('startDate')
          .orderBy('createdAt', descending: false)
          .get();

      List<BudgetModel> budgets = snapshot.docs
          .map((doc) => BudgetModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      // Calculate spent amounts for each budget for this specific month
      List<BudgetModel> updatedBudgets = [];
      for (BudgetModel budget in budgets) {
        final spentAmount = await _calculateSpentAmountForMonth(userId, budget, month);
        updatedBudgets.add(BudgetModel(
          id: budget.id,
          name: budget.name,
          icon: budget.icon,
          allocatedAmount: budget.allocatedAmount,
          spentAmount: spentAmount,
          periodType: budget.periodType,
          startDate: budget.startDate,
          endDate: budget.endDate,
          color: budget.color,
          userId: budget.userId,
          createdAt: budget.createdAt,
          updatedAt: budget.updatedAt,
        ));
      }

      return updatedBudgets;
    } catch (e) {
      print('Error getting budgets for month: $e');
      return [];
    }
  }

  // Calculate spent amount for a budget for a specific month
  Future<double> _calculateSpentAmountForMonth(String userId, BudgetModel budget, DateTime month) async {
    try {
      // Calculate month boundaries
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      // Use the intersection of budget period and selected month
      final queryStartDate = budget.startDate.isAfter(startOfMonth) ? budget.startDate : startOfMonth;
      final queryEndDate = budget.endDate.isBefore(endOfMonth) ? budget.endDate : endOfMonth;

      final snapshot = await transactionsCollection
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: budget.name)
          .where('type', isEqualTo: 'expense')
          .where('date', isGreaterThanOrEqualTo: queryStartDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: queryEndDate.toIso8601String())
          .get();

      return snapshot.docs.fold<double>(0.0, (double sum, QueryDocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + (data['amount'] as num).toDouble();
      });
    } catch (e) {
      print('Error calculating spent amount for month: $e');
      return 0.0;
    }
  }
}
