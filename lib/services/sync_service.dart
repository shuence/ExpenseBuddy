import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/local/local_database_service.dart';
import '../models/transaction_model.dart';
import 'connectivity_service.dart';
import '../data/remote/auth_service.dart';

enum SyncOperation {
  create,
  update,
  delete,
}

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() {
    log('🚨 [SYNC] SyncService factory called - creating/returning instance');
    return _instance;
  }
  SyncService._internal() {
    log('🚨 [SYNC] SyncService constructor called');
  }

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
    log('🔄 [SYNC] Initializing SyncService...');
    
    await _connectivityService.initialize();
    log('✅ [SYNC] ConnectivityService initialized');
    
    // Listen to connectivity changes - sync when network comes back
    _connectivityService.connectionStatusStream.listen((status) {
      log('🌐 [SYNC] Connectivity changed to: $status');
      if (status == ConnectionStatus.connected) {
        log('🌐 [SYNC] Network restored - syncing pending transactions');
        _scheduleSync();
      }
    });

    // Start periodic sync
    _startPeriodicSync();
    log('✅ [SYNC] SyncService initialization completed');
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

  void _scheduleImmediateSync() {
    if (!_isSyncing) {
      // Immediate sync when connectivity returns
      _fullSyncWithFirebase();
    }
  }

  // Main sync method - SIMPLE VERSION
  Future<void> _syncPendingTransactions() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _syncStatusController.add(true);

    try {
      log('🔄 [SYNC] Starting sync of pending transactions...');
      
      if (!_connectivityService.isConnected) {
        log('❌ [SYNC] No internet - skipping sync');
        return;
      }

      final userId = await _getCurrentUserId();
      if (userId == null) {
        log('❌ [SYNC] No user ID - skipping sync');
        return;
      }

      // Get all transactions that need syncing
      final allTransactions = await _localDb.getAllTransactions(userId);
      log('📱 [SYNC] Found ${allTransactions.length} total transactions');
      
      // Sync each transaction to Firebase
      for (final transaction in allTransactions) {
        log('🔄 [SYNC] Syncing: ${transaction.title}');
        await _syncTransaction(transaction);
      }

      log('✅ [SYNC] All transactions synced successfully');
    } catch (e) {
      log('❌ [SYNC] Sync failed: $e');
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  // Simple full sync - just sync pending transactions
  Future<void> _fullSyncWithFirebase() async {
    log('🔄 [SYNC] Starting full sync...');
    await _syncPendingTransactions();
    log('✅ [SYNC] Full sync completed');
  }

  Future<void> _syncTransaction(TransactionModel transaction) async {
    try {
      log('🔄 [SYNC] Starting _syncTransaction for: ${transaction.title}');
      log('📱 [SYNC] Transaction ID: ${transaction.id}');
      log('👤 [SYNC] User ID: ${transaction.userId}');
      
      // Simple Firebase push
      final docRef = _firestore
          .collection('users')
          .doc(transaction.userId)
          .collection('transactions')
          .doc(transaction.id);
      
      log('🔥 [SYNC] Firebase path: users/${transaction.userId}/transactions/${transaction.id}');
      
      // Just set the document (create or update)
      log('📝 [SYNC] Setting document in Firebase...');
      await docRef.set(transaction.toJson());
      log('✅ [SYNC] Transaction synced to Firebase: ${transaction.title}');
      
    } catch (e) {
      log('❌ [SYNC] Failed to sync: ${transaction.title} - $e');
      log('❌ [SYNC] Error details: $e');
      // Don't mark as failed, just log the error
      rethrow; // Re-throw to see the error in addTransaction
    }
  }

  // Public methods for manual sync
  Future<void> syncNow() async {
    log('🔄 [SYNC] Manual sync requested');
    await _syncPendingTransactions();
  }
  
  // Simple debug method
  Future<void> debugSyncStatus() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;
      
      final allTransactions = await _localDb.getAllTransactions(userId);
      log('📱 [DEBUG] Total transactions: ${allTransactions.length}');
      
      for (final transaction in allTransactions) {
        log('📱 [DEBUG] ${transaction.title}: ${transaction.syncStatus}');
      }
    } catch (e) {
      log('❌ [DEBUG] Debug failed: $e');
    }
  }

  Future<void> syncTransaction(TransactionModel transaction) async {
    await _syncTransaction(transaction);
  }

  // Public method for full sync
  Future<void> fullSync() async {
    await _fullSyncWithFirebase();
  }

  // Simple fetch - just sync pending transactions
  Future<void> fetchFirebaseData() async {
    await _syncPendingTransactions();
  }

  // Simple retry method
  Future<void> retryFailedSyncs() async {
    log('🔄 [SYNC] Retrying failed syncs...');
    await _syncPendingTransactions();
  }
  
  // Force sync all transactions
  Future<void> forceSyncAllPending() async {
    log('🔄 [FORCE] Force syncing all transactions...');
    await _syncPendingTransactions();
  }

  // Transaction CRUD with offline support - SIMPLE VERSION
  Future<void> addTransaction(TransactionModel transaction) async {
    log('🚨 [SYNC] ===== SYNC SERVICE addTransaction CALLED =====');
    try {
      log('🔄 [SYNC] Starting addTransaction for: ${transaction.title}');
      
      // 1. ALWAYS save to local DB first
      log('💾 [SYNC] Saving to local database...');
      await _localDb.insertTransaction(transaction);
      log('✅ [SYNC] Saved to local database successfully');

      // 2. Check connectivity and try Firebase immediately if online
      log('🌐 [SYNC] Checking connectivity...');
      final isConnected = _connectivityService.isConnected;
      log('🌐 [SYNC] Connectivity status: ${isConnected ? "ONLINE" : "OFFLINE"}');
      
      if (isConnected) {
        log('🌐 [SYNC] Online - syncing to Firebase now...');
        try {
          await _syncTransaction(transaction);
          log('✅ [SYNC] Firebase sync completed successfully');
        } catch (syncError) {
          log('❌ [SYNC] Firebase sync failed: $syncError');
          // Don't rethrow - transaction is still saved locally
        }
      } else {
        log('📱 [SYNC] Offline - will sync to Firebase when network returns');
      }
      
      log('🎉 [SYNC] addTransaction completed successfully');
    } catch (e) {
      log('❌ [SYNC] Failed to add transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      log('🔄 [SYNC] Starting updateTransaction for: ${transaction.title}');
      
      // 1. ALWAYS update local DB first
      log('💾 [SYNC] Updating local database...');
      await _localDb.updateTransaction(transaction);
      log('✅ [SYNC] Local database updated successfully');

      // 2. Try Firebase immediately if online
      if (_connectivityService.isConnected) {
        log('🌐 [SYNC] Online - syncing to Firebase now...');
        await _syncTransaction(transaction);
        log('✅ [SYNC] Firebase sync completed');
      } else {
        log('📱 [SYNC] Offline - will sync to Firebase when network returns');
      }
      
      log('🎉 [SYNC] updateTransaction completed successfully');
    } catch (e) {
      log('❌ [SYNC] Failed to update transaction: $e');
      rethrow;
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
        // Get the transaction to get userId for proper Firebase path
        final transaction = await _localDb.getTransaction(id);
        if (transaction != null) {
          await _firestore
              .collection('users')
              .doc(transaction.userId)
              .collection('transactions')
              .doc(id)
              .delete();
          
          await _localDb.deleteTransaction(id);
          await _localDb.logSyncOperation(
            operation: 'delete',
            tableName: 'transactions',
            recordId: id,
            status: 'success',
          );
        }
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
    try {
      // Get current user from AuthService
      final authService = AuthService();
      final user = authService.currentUser;
      return user?.uid;
    } catch (e) {
      log('Failed to get current user ID: $e');
      return null;
    }
  }

  // Simple time tracking
  Future<DateTime?> _getLastSyncTime(String userId) async {
    return null; // Not needed for simple sync
  }

  Future<void> _setLastSyncTime(String userId, DateTime time) async {
    // Not needed for simple sync
  }

  // Simple sync stats
  Future<Map<String, dynamic>> getSyncStats(String userId) async {
    try {
      final allTransactions = await _localDb.getAllTransactions(userId);
      return {
        'pendingTransactions': allTransactions.length,
        'isConnected': _connectivityService.isConnected,
        'isSyncing': _isSyncing,
        'totalLocalTransactions': allTransactions.length,
      };
    } catch (e) {
      return {
        'pendingTransactions': 0,
        'isConnected': false,
        'isSyncing': false,
        'error': e.toString(),
      };
    }
  }

  // Simple validation

  // Simple clear data
  Future<void> clearAllData() async {
    // Not needed for simple sync
  }

  void dispose() {
    _syncTimer?.cancel();
    _syncStatusController.close();
    _connectivityService.dispose();
  }
}
