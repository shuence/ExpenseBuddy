import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../data/remote/transactions_service.dart';
import '../services/sync_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionsService _transactionsService = TransactionsService();
  final SyncService _syncService = SyncService();
  
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load all transactions for a user
  Future<void> loadTransactions(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Load from local database first (offline support)
      _transactions = await _syncService.getTransactions(userId);
      
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
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Use sync service for offline support
      await _syncService.addTransaction(transaction);
      _transactions.add(transaction);
      _transactions.sort((a, b) => b.date.compareTo(a.date)); // Keep sorted
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Update existing transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Use sync service for offline support
      await _syncService.updateTransaction(transaction);
      
      // Update in local list
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index >= 0) {
        _transactions[index] = transaction;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Use sync service for offline support
      await _syncService.deleteTransaction(transactionId);
      
      // Remove from local list
      _transactions.removeWhere((t) => t.id == transactionId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Get expenses only
  List<TransactionModel> get expenses => 
      _transactions.where((t) => t.type == TransactionType.expense).toList();
  
  // Get income only
  List<TransactionModel> get income => 
      _transactions.where((t) => t.type == TransactionType.income).toList();
      
  // Get total income
  double getTotalIncome(String currency) {
    return income
        .where((t) => t.currency == currency)
        .fold(0, (sum, t) => sum + t.amount);
  }
  
  // Get total expenses
  double getTotalExpenses(String currency) {
    return expenses
        .where((t) => t.currency == currency)
        .fold(0, (sum, t) => sum + t.amount);
  }
  
  // Get balance
  double getBalance(String currency) {
    return getTotalIncome(currency) - getTotalExpenses(currency);
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

  // Sync-related methods
  Future<void> syncNow() async {
    await _syncService.syncNow();
  }

  Future<Map<String, dynamic>> getSyncStats(String userId) async {
    return await _syncService.getSyncStats(userId);
  }

  Stream<bool> get syncStatusStream => _syncService.syncStatusStream;

  bool get isSyncing => _syncService.isSyncing;

  // Get unsynced transactions
  List<TransactionModel> get unsyncedTransactions {
    return _transactions.where((t) => t.syncStatus != SyncStatus.synced).toList();
  }

  // Get failed transactions
  List<TransactionModel> get failedTransactions {
    return _transactions.where((t) => t.syncStatus == SyncStatus.failed).toList();
  }

  // Debug method to see sync status of all transactions
  void debugSyncStatus() {
    print('=== SYNC STATUS DEBUG ===');
    print('Total transactions: ${_transactions.length}');
    
    for (int i = 0; i < _transactions.length; i++) {
      final transaction = _transactions[i];
      print('Transaction ${i + 1}:');
      print('  ID: ${transaction.id}');
      print('  Title: ${transaction.title}');
      print('  Amount: ${transaction.amount}');
      print('  Sync Status: ${transaction.syncStatus}');
      print('  Sync Attempts: ${transaction.syncAttempts}');
      if (transaction.syncError != null) {
        print('  Sync Error: ${transaction.syncError}');
      }
      print('---');
    }
    
    print('Unsynced transactions: ${unsyncedTransactions.length}');
    print('Failed transactions: ${failedTransactions.length}');
    print('========================');
  }

  // Quick fix: Mark all pending transactions as synced (for existing data)
  Future<void> markAllAsSynced() async {
    for (final transaction in _transactions) {
      if (transaction.syncStatus == SyncStatus.pending) {
        final syncedTransaction = transaction.copyWith(
          syncStatus: SyncStatus.synced,
          syncAttempts: 0,
          syncError: null,
        );
        await _syncService.updateTransaction(syncedTransaction);
        
        // Update in local list
        final index = _transactions.indexWhere((t) => t.id == transaction.id);
        if (index >= 0) {
          _transactions[index] = syncedTransaction;
        }
      }
    }
    notifyListeners();
  }
}
