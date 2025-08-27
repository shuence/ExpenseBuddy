import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../data/local/local_database_service.dart';
import '../data/remote/transactions_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionsService _transactionsService = TransactionsService();
  final SyncService _syncService = SyncService();
  
  TransactionProvider() {
    _initializeSyncService();
  }
  
  Future<void> _initializeSyncService() async {
    debugPrint('🚨 [PROVIDER] TransactionProvider created, syncService: $_syncService');
    debugPrint('🚨 [PROVIDER] About to create SyncService...');
    final testSyncService = SyncService();
    debugPrint('🚨 [PROVIDER] Test SyncService created: $testSyncService');
    debugPrint('🚨 [PROVIDER] Test SyncService runtimeType: ${testSyncService.runtimeType}');
    
    // Test direct call to sync service
    debugPrint('🚨 [PROVIDER] Testing direct call to testSyncService.addTransaction...');
    try {
      final testTransaction = TransactionModel(
        id: 'test-123',
        title: 'Test Transaction',
        amount: 100,
        category: 'Test',
        date: DateTime.now(),
        description: 'Test description',
        userId: 'test-user',
        currency: 'USD',
        type: TransactionType.expense,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await testSyncService.addTransaction(testTransaction);
      debugPrint('🚨 [PROVIDER] Direct test call SUCCESSFUL!');
    } catch (e) {
      debugPrint('🚨 [PROVIDER] Direct test call FAILED: $e');
    }
  }
  
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
      
      // Use sync service for offline support
      debugPrint('🔄 Starting sync service transaction...');
      debugPrint('🚨 [PROVIDER] About to call _syncService.addTransaction');
      debugPrint('🚨 [PROVIDER] _syncService instance: $_syncService');
      debugPrint('🚨 [PROVIDER] _syncService runtimeType: ${_syncService.runtimeType}');
      debugPrint('🚨 [PROVIDER] _syncService is SyncService: ${_syncService is SyncService}');
      
      // Direct test call to see if sync service works
      debugPrint('🚨 [PROVIDER] Making direct test call to sync service...');
      try {
        final testTransaction = TransactionModel(
          id: 'direct-test-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Direct Test',
          amount: 999,
          category: 'Test',
          date: DateTime.now(),
          description: 'Direct test description',
          userId: transaction.userId,
          currency: 'USD',
          type: TransactionType.expense,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _syncService.addTransaction(testTransaction);
        debugPrint('🚨 [PROVIDER] Direct test call SUCCESSFUL!');
      } catch (e) {
        debugPrint('🚨 [PROVIDER] Direct test call FAILED: $e');
      }
      try {
        await _syncService.addTransaction(transaction);
        debugPrint('🚨 [PROVIDER] _syncService.addTransaction completed successfully');
        debugPrint('✅ Sync service transaction completed');
      } catch (e) {
        debugPrint('❌ [SYNC ERROR] Sync service failed: $e');
        debugPrint('❌ [SYNC ERROR] Stack trace: ${StackTrace.current}');
        rethrow;
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
      
      // Use sync service for offline support
      debugPrint('🔄 Starting sync service update...');
      await _syncService.updateTransaction(transaction);
      debugPrint('✅ Sync service update completed');
      
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
      
      // Use sync service for offline support
      debugPrint('🔄 Starting sync service deletion...');
      await _syncService.deleteTransaction(transactionId);
      debugPrint('✅ Sync service deletion completed');
      
      // Remove from local list
      final initialCount = _transactions.length;
      _transactions.removeWhere((t) => t.id == transactionId);
      final finalCount = _transactions.length;
      debugPrint('📱 Transaction removed from local list. Count: $initialCount → $finalCount');
      
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

  Future<void> fullSync() async {
    await _syncService.fullSync();
  }

  Future<void> fetchFirebaseData() async {
    await _syncService.fetchFirebaseData();
  }

  Future<void> retryFailedSyncs() async {
    await _syncService.retryFailedSyncs();
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
    debugPrint('=== SYNC STATUS DEBUG ===');
    debugPrint('Total transactions: ${_transactions.length}');
    
    for (int i = 0; i < _transactions.length; i++) {
      final transaction = _transactions[i];
      debugPrint('Transaction ${i + 1}:');
      debugPrint('  ID: ${transaction.id}');
      debugPrint('  Title: ${transaction.title}');
      debugPrint('  Amount: ${transaction.amount}');
      debugPrint('  Sync Status: ${transaction.syncStatus}');
      debugPrint('  Sync Attempts: ${transaction.syncAttempts}');
      if (transaction.syncError != null) {
        debugPrint('  Sync Error: ${transaction.syncError}');
      }
      debugPrint('---');
    }
    
    debugPrint('Unsynced transactions: ${unsyncedTransactions.length}');
    debugPrint('Failed transactions: ${failedTransactions.length}');
    debugPrint('========================');
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
  
  // Force sync all pending transactions
  Future<void> forceSyncAllPending() async {
    await _syncService.forceSyncAllPending();
    // Reload transactions after sync
    await loadTransactions(_transactions.isNotEmpty ? _transactions.first.userId : '');
  }
}
