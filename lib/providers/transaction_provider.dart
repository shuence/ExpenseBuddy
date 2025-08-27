import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../data/remote/transactions_service.dart';
import '../data/local/local_database_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionsService _transactionsService = TransactionsService();
  final LocalDatabaseService _localDb = LocalDatabaseService();
  
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;
  
  // Detailed loading states
  bool _isAddingTransaction = false;
  bool _isUpdatingTransaction = false;
  bool _isDeletingTransaction = false;
  
  // Getters
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAddingTransaction => _isAddingTransaction;
  bool get isUpdatingTransaction => _isUpdatingTransaction;
  bool get isDeletingTransaction => _isDeletingTransaction;
  
  // Load all transactions for a user
  Future<void> loadTransactions(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Load from local database first
      _transactions = await _localDb.getAllTransactions(userId);
      
      // If no local data, try to load from remote
      if (_transactions.isEmpty) {
        _transactions = await _transactionsService.getAllTransactions(userId);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Add new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    _isAddingTransaction = true;
    _error = null;
    notifyListeners();
    
    try {
      debugPrint('🔄 Adding transaction: ${transaction.title} (${transaction.amount})');
      debugPrint('📱 Transaction ID: ${transaction.id}');
      debugPrint('👤 User ID: ${transaction.userId}');
      debugPrint('📅 Date: ${transaction.date}');
      debugPrint('🏷️ Category: ${transaction.category}');
      debugPrint('💰 Type: ${transaction.type}');
      
      // Save to local database first
      debugPrint('💾 Saving to local database...');
      await _localDb.insertTransaction(transaction);
      debugPrint('✅ Saved to local database successfully');
      
      // Try to save to Firebase
      debugPrint('🔥 Trying to save to Firebase...');
      try {
        await _transactionsService.addTransaction(transaction);
        debugPrint('✅ Saved to Firebase successfully');
      } catch (e) {
        debugPrint('⚠️ Failed to save to Firebase: $e (but saved locally)');
      }
      
      // Add to local list
      _transactions.add(transaction);
      _transactions.sort((a, b) => b.date.compareTo(a.date)); // Keep sorted
      debugPrint('📱 Transaction added to local list. Total: ${_transactions.length}');
      
      _isAddingTransaction = false;
      _error = null;
      notifyListeners();
      debugPrint('🎉 Transaction added successfully!');
    } catch (e) {
      debugPrint('❌ Failed to add transaction: $e');
      _isAddingTransaction = false;
      _error = e.toString();
      notifyListeners();
      rethrow; // Re-throw to let UI handle the error
    }
  }
  
  // Update existing transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    _isUpdatingTransaction = true;
    _error = null;
    notifyListeners();
    
    try {
      debugPrint('🔄 Updating transaction: ${transaction.title} (${transaction.id})');
      
      // Update local database first
      debugPrint('💾 Updating local database...');
      await _localDb.updateTransaction(transaction);
      debugPrint('✅ Local database updated successfully');
      
      // Try to update Firebase
      debugPrint('🔥 Trying to update Firebase...');
      try {
        await _transactionsService.updateTransaction(transaction);
        debugPrint('✅ Firebase updated successfully');
      } catch (e) {
        debugPrint('⚠️ Failed to update Firebase: $e (but updated locally)');
      }
      
      // Update in local list
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index >= 0) {
        _transactions[index] = transaction;
        debugPrint('📱 Transaction updated in local list at index: $index');
      } else {
        debugPrint('⚠️ Transaction not found in local list for update');
      }
      
      _isUpdatingTransaction = false;
      _error = null;
      notifyListeners();
      debugPrint('🎉 Transaction updated successfully!');
    } catch (e) {
      debugPrint('❌ Failed to update transaction: $e');
      _isUpdatingTransaction = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    _isDeletingTransaction = true;
    _error = null;
    notifyListeners();
    
    try {
      debugPrint('🗑️ Deleting transaction: $transactionId');
      
      // Find transaction before deletion for logging
      final transaction = _transactions.firstWhere(
        (t) => t.id == transactionId,
        orElse: () => TransactionModel(
          id: '',
          title: '',
          amount: 0,
          category: '',
          date: DateTime.now(),
          description: '',
          userId: '',
          currency: '',
          type: TransactionType.expense,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      
      if (transaction.id.isNotEmpty) {
        debugPrint('📱 Found transaction: ${transaction.title} (${transaction.amount})');
      }
      
      // Delete from local database first
      debugPrint('💾 Deleting from local database...');
      await _localDb.deleteTransaction(transactionId);
      debugPrint('✅ Deleted from local database successfully');
      
      // Try to delete from Firebase
      debugPrint('🔥 Trying to delete from Firebase...');
      try {
        await _transactionsService.deleteTransaction(transactionId);
        debugPrint('✅ Deleted from Firebase successfully');
      } catch (e) {
        debugPrint('⚠️ Failed to delete from Firebase: $e (but deleted locally)');
      }
      
      // Remove from local list
      _transactions.removeWhere((t) => t.id == transactionId);
      debugPrint('📱 Transaction removed from local list. Total: ${_transactions.length}');
      
      _isDeletingTransaction = false;
      _error = null;
      notifyListeners();
      debugPrint('🎉 Transaction deleted successfully!');
    } catch (e) {
      debugPrint('❌ Failed to delete transaction: $e');
      _isDeletingTransaction = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  // Get transaction by ID
  TransactionModel? getTransaction(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get transactions by type
  List<TransactionModel> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }
  
  // Get transactions by category
  List<TransactionModel> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }
  
  // Get transactions by date range
  List<TransactionModel> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList();
  }
  
  // Get total amount by type
  double getTotalAmountByType(TransactionType type) {
    return _transactions
        .where((t) => t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
  
  // Get total amount by category
  double getTotalAmountByCategory(String category) {
    return _transactions
        .where((t) => t.category == category)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
  
  // Get total amount by date range
  double getTotalAmountByDateRange(DateTime start, DateTime end) {
    return getTransactionsByDateRange(start, end)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
  
  // Clear all transactions
  void clearTransactions() {
    _transactions.clear();
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
