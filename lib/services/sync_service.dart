import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/local/local_database_service.dart';
import '../models/transaction_model.dart';
import 'connectivity_service.dart';

enum SyncOperation {
  create,
  update,
  delete,
}

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final LocalDatabaseService _localDb = LocalDatabaseService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final StreamController<bool> _syncStatusController = StreamController<bool>.broadcast();
  Stream<bool> get syncStatusStream => _syncStatusController.stream;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Timer? _syncTimer;
  static const Duration _syncInterval = Duration(minutes: 5);

  Future<void> initialize() async {
    await _connectivityService.initialize();
    
    // Listen to connectivity changes
    _connectivityService.connectionStatusStream.listen((status) {
      if (status == ConnectionStatus.connected) {
        _scheduleSync();
      }
    });

    // Start periodic sync
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (timer) {
      if (_connectivityService.isConnected) {
        _scheduleSync();
      }
    });
  }

  void _scheduleSync() {
    if (!_isSyncing) {
      _syncPendingTransactions();
    }
  }

  // Main sync method
  Future<void> _syncPendingTransactions() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _syncStatusController.add(true);

    try {
      if (!_connectivityService.isConnected) {
        log('Sync skipped: No internet connection');
        return;
      }

      // Get current user ID (you'll need to implement this based on your auth system)
      final userId = await _getCurrentUserId();
      if (userId == null) {
        log('Sync skipped: No user ID');
        return;
      }

      // Get unsynced transactions
      final unsyncedTransactions = await _localDb.getUnsyncedTransactions(userId);
      
      if (unsyncedTransactions.isEmpty) {
        log('No transactions to sync');
        return;
      }

      log('Starting sync for ${unsyncedTransactions.length} transactions');

      // Sync each transaction
      for (final transaction in unsyncedTransactions) {
        await _syncTransaction(transaction);
      }

      // Pull latest changes from Firebase
      await _pullLatestChanges(userId);

      log('Sync completed successfully');
    } catch (e) {
      log('Sync failed: $e');
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  Future<void> _syncTransaction(TransactionModel transaction) async {
    try {
      final docRef = _firestore
          .collection('transactions')
          .doc(transaction.id);

      // Check if document exists to determine operation type
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        // Update existing document
        await docRef.update(transaction.toJson());
        await _localDb.logSyncOperation(
          operation: 'update',
          tableName: 'transactions',
          recordId: transaction.id,
          status: 'success',
        );
      } else {
        // Create new document
        await docRef.set(transaction.toJson());
        await _localDb.logSyncOperation(
          operation: 'create',
          tableName: 'transactions',
          recordId: transaction.id,
          status: 'success',
        );
      }

      // Mark as synced
      await _localDb.markTransactionAsSynced(transaction.id);
      
      log('Synced transaction: ${transaction.id}');
    } catch (e) {
      log('Failed to sync transaction ${transaction.id}: $e');
      
      await _localDb.markTransactionAsFailed(transaction.id, e.toString());
      await _localDb.logSyncOperation(
        operation: 'create',
        tableName: 'transactions',
        recordId: transaction.id,
        status: 'failed',
        error: e.toString(),
      );
    }
  }

  Future<void> _pullLatestChanges(String userId) async {
    try {
      // Get the last sync timestamp from local storage
      final lastSyncTime = await _getLastSyncTime(userId);
      
      // Query Firebase for changes since last sync
      Query query = _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId);

      if (lastSyncTime != null) {
        query = query.where('updatedAt', isGreaterThan: lastSyncTime.toIso8601String());
      }

      final querySnapshot = await query.get();
      
      for (final doc in querySnapshot.docs) {
        final transactionData = doc.data();
        final transaction = TransactionModel.fromJson({
          ...transactionData as Map<String, dynamic>,
          'id': doc.id,
        });

        // Update local database
        await _localDb.insertTransaction(transaction);
      }

      // Update last sync time
      await _setLastSyncTime(userId, DateTime.now());
      
      log('Pulled ${querySnapshot.docs.length} changes from Firebase');
    } catch (e) {
      log('Failed to pull latest changes: $e');
    }
  }

  // Public methods for manual sync
  Future<void> syncNow() async {
    await _syncPendingTransactions();
  }

  Future<void> syncTransaction(TransactionModel transaction) async {
    await _syncTransaction(transaction);
  }

  // Transaction CRUD with offline support
  Future<void> addTransaction(TransactionModel transaction) async {
    // Always save to local first
    await _localDb.insertTransaction(transaction);

    // Try to sync immediately if online
    if (_connectivityService.isConnected) {
      await _syncTransaction(transaction);
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    // Always update local first
    await _localDb.updateTransaction(transaction);

    // Try to sync immediately if online
    if (_connectivityService.isConnected) {
      await _syncTransaction(transaction);
    }
  }

  Future<void> deleteTransaction(String id) async {
    // Mark for deletion in local database
    final transaction = await _localDb.getTransaction(id);
    if (transaction != null) {
      final deletedTransaction = transaction.copyWith(
        syncStatus: SyncStatus.pending,
        updatedAt: DateTime.now(),
      );
      await _localDb.updateTransaction(deletedTransaction);
    }

    // Try to delete from Firebase immediately if online
    if (_connectivityService.isConnected) {
      try {
        await _firestore.collection('transactions').doc(id).delete();
        await _localDb.deleteTransaction(id);
        await _localDb.logSyncOperation(
          operation: 'delete',
          tableName: 'transactions',
          recordId: id,
          status: 'success',
        );
      } catch (e) {
        log('Failed to delete transaction from Firebase: $e');
        await _localDb.logSyncOperation(
          operation: 'delete',
          tableName: 'transactions',
          recordId: id,
          status: 'failed',
          error: e.toString(),
        );
      }
    }
  }

  // Get transactions (prioritize local data)
  Future<List<TransactionModel>> getTransactions(String userId) async {
    return await _localDb.getAllTransactions(userId);
  }

  // Utility methods
  Future<String?> _getCurrentUserId() async {
    // Implement based on your authentication system
    // For now, return a placeholder
    return 'current_user_id';
  }

  Future<DateTime?> _getLastSyncTime(String userId) async {
    // Implement to get last sync time from SharedPreferences or local DB
    return null;
  }

  Future<void> _setLastSyncTime(String userId, DateTime time) async {
    // Implement to save last sync time to SharedPreferences or local DB
  }

  // Get sync statistics
  Future<Map<String, dynamic>> getSyncStats(String userId) async {
    final unsynced = await _localDb.getUnsyncedTransactions(userId);
    final syncLog = await _localDb.getSyncLog(limit: 50);

    return {
      'pendingTransactions': unsynced.length,
      'recentSyncLogs': syncLog,
      'isConnected': _connectivityService.isConnected,
      'isSyncing': _isSyncing,
    };
  }

  // Clear all data (for testing or logout)
  Future<void> clearAllData() async {
    await _localDb.clearAllData();
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
    _connectivityService.dispose();
  }
}
