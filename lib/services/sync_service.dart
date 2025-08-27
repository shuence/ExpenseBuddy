import '../data/remote/firestore_service.dart';
import '../models/expense.dart';
import 'package:flutter/foundation.dart';

class SyncService {
  final FirestoreService _firestoreService = FirestoreService();
  
  Future<void> syncExpenses(String userId) async {
    try {
      // Sync local expenses with remote
      final localExpenses = await _firestoreService.getUserExpenses(userId).first;
      
      // Here you would implement the sync logic
      // For now, just a placeholder
      debugPrint('Syncing ${localExpenses.length} expenses for user $userId');
    } catch (e) {
      throw Exception('Sync failed: $e');
    }
  }
  
  Future<void> syncExpense(Expense expense) async {
    try {
      await _firestoreService.updateExpense(expense);
    } catch (e) {
      throw Exception('Expense sync failed: $e');
    }
  }
}
