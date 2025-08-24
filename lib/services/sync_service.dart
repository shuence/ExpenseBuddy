import '../data/repositories/expense_repository.dart';
import '../models/expense.dart';
import 'package:flutter/foundation.dart';

class SyncService {
  final ExpenseRepository _expenseRepository;
  
  SyncService(this._expenseRepository);
  
  Future<void> syncExpenses(String userId) async {
    try {
      // Sync local expenses with remote
      final localExpenses = await _expenseRepository.getExpenses(userId);
      
      // Here you would implement the sync logic
      // For now, just a placeholder
      debugPrint('Syncing ${localExpenses.length} expenses for user $userId');
    } catch (e) {
      throw Exception('Sync failed: $e');
    }
  }
  
  Future<void> syncExpense(Expense expense) async {
    try {
      await _expenseRepository.updateExpense(expense);
    } catch (e) {
      throw Exception('Expense sync failed: $e');
    }
  }
}
