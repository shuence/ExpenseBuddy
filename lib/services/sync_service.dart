import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/local/local_database_service.dart';
import '../models/transaction_model.dart';
import '../data/remote/transactions_service.dart';
import '../data/remote/auth_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final LocalDatabaseService _localDb = LocalDatabaseService();
  final TransactionsService _transactionsService = TransactionsService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  // Stream to notify UI about sync status
  final StreamController<bool> _syncStatusController = StreamController<bool>.broadcast();
  Stream<bool> get syncStatusStream => _syncStatusController.stream;

  /// Initialize sync service and perform initial sync
  Future<void> initialize() async {
    log('🔄 [SYNC] Initializing SyncService...');
    
    try {
      // Wait a bit for Firebase to be ready
      await Future.delayed(const Duration(seconds: 2));
      
      log('🔄 [SYNC] Starting initial sync...');
      await performFullSync();
      
      log('✅ [SYNC] SyncService initialization completed successfully');
    } catch (e) {
      log('❌ [SYNC] Failed to initialize SyncService: $e');
    }
  }

  /// Perform full sync: Firebase → Local and Local → Firebase
  Future<void> performFullSync() async {
    if (_isSyncing) {
      log('⚠️ [SYNC] Sync already in progress, skipping...');
      return;
    }

    _isSyncing = true;
    _syncStatusController.add(true);
    
    try {
      log('🔄 [SYNC] ===== STARTING FULL SYNC =====');
      
      final userId = await _getCurrentUserId();
      if (userId == null) {
        log('❌ [SYNC] No user ID found, cannot sync');
        return;
      }
      
      log('👤 [SYNC] Syncing for user: $userId');
      
      // Step 1: Pull Firebase data to Local
      log('📥 [SYNC] Step 1: Pulling Firebase data to Local...');
      await _pullFirebaseToLocal(userId);
      
      // Step 2: Push Local data to Firebase
      log('📤 [SYNC] Step 2: Pushing Local data to Firebase...');
      await _pushLocalToFirebase(userId);
      
      log('✅ [SYNC] ===== FULL SYNC COMPLETED SUCCESSFULLY =====');
      
    } catch (e) {
      log('❌ [SYNC] Full sync failed: $e');
      log('❌ [SYNC] Stack trace: ${StackTrace.current}');
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  /// Pull all Firebase data to Local database
  Future<void> _pullFirebaseToLocal(String userId) async {
    try {
      log('📥 [SYNC] Fetching transactions from Firebase...');
      
      // Get all transactions from Firebase
      final firebaseTransactions = await _transactionsService.getAllTransactions(userId);
      log('📥 [SYNC] Found ${firebaseTransactions.length} transactions in Firebase');
      
      if (firebaseTransactions.isEmpty) {
        log('📥 [SYNC] No Firebase transactions to pull');
        return;
      }
      
      // Get existing local transactions
      final localTransactions = await _localDb.getAllTransactions(userId);
      log('📥 [SYNC] Found ${localTransactions.length} transactions in Local DB');
      
      // Create a map of local transactions by ID for quick lookup
      final localTransactionMap = <String, TransactionModel>{};
      for (final transaction in localTransactions) {
        localTransactionMap[transaction.id] = transaction;
      }
      
      int newTransactions = 0;
      int updatedTransactions = 0;
      int skippedTransactions = 0;
      
      // Process each Firebase transaction
      for (final firebaseTransaction in firebaseTransactions) {
        final localTransaction = localTransactionMap[firebaseTransaction.id];
        
        if (localTransaction == null) {
          // New transaction - add to local
          log('📥 [SYNC] Adding new transaction to local: ${firebaseTransaction.title}');
          await _localDb.insertTransaction(firebaseTransaction);
          newTransactions++;
        } else {
          // Check if Firebase is newer
          if (firebaseTransaction.updatedAt.isAfter(localTransaction.updatedAt)) {
            log('📥 [SYNC] Updating local transaction: ${firebaseTransaction.title}');
            await _localDb.updateTransaction(firebaseTransaction);
            updatedTransactions++;
          } else {
            log('📥 [SYNC] Skipping transaction (local is newer): ${firebaseTransaction.title}');
            skippedTransactions++;
          }
        }
      }
      
      log('📥 [SYNC] Pull completed: $newTransactions new, $updatedTransactions updated, $skippedTransactions skipped');
      
    } catch (e) {
      log('❌ [SYNC] Failed to pull Firebase data: $e');
      rethrow;
    }
  }

  /// Push all Local data to Firebase
  Future<void> _pushLocalToFirebase(String userId) async {
    try {
      log('📤 [SYNC] Fetching transactions from Local DB...');
      
      // Get all local transactions
      final localTransactions = await _localDb.getAllTransactions(userId);
      log('📤 [SYNC] Found ${localTransactions.length} transactions in Local DB');
      
      if (localTransactions.isEmpty) {
        log('📤 [SYNC] No local transactions to push');
        return;
      }
      
      // Get existing Firebase transactions for comparison
      final firebaseTransactions = await _transactionsService.getAllTransactions(userId);
      log('📤 [SYNC] Found ${firebaseTransactions.length} transactions in Firebase');
      
      // Create a map of Firebase transactions by ID for quick lookup
      final firebaseTransactionMap = <String, TransactionModel>{};
      for (final transaction in firebaseTransactions) {
        firebaseTransactionMap[transaction.id] = transaction;
      }
      
      int newTransactions = 0;
      int updatedTransactions = 0;
      int skippedTransactions = 0;
      int failedTransactions = 0;
      
      // Process each local transaction
      for (final localTransaction in localTransactions) {
        try {
          final firebaseTransaction = firebaseTransactionMap[localTransaction.id];
          
          if (firebaseTransaction == null) {
            // New transaction - add to Firebase
            log('📤 [SYNC] Adding new transaction to Firebase: ${localTransaction.title}');
            await _transactionsService.addTransaction(localTransaction);
            newTransactions++;
          } else {
            // Check if local is newer
            if (localTransaction.updatedAt.isAfter(firebaseTransaction.updatedAt)) {
              log('📤 [SYNC] Updating Firebase transaction: ${localTransaction.title}');
              await _transactionsService.updateTransaction(localTransaction);
              updatedTransactions++;
            } else {
              log('📤 [SYNC] Skipping transaction (Firebase is newer): ${localTransaction.title}');
              skippedTransactions++;
            }
          }
        } catch (e) {
          log('❌ [SYNC] Failed to sync transaction ${localTransaction.title}: $e');
          failedTransactions++;
        }
      }
      
      log('📤 [SYNC] Push completed: $newTransactions new, $updatedTransactions updated, $skippedTransactions skipped, $failedTransactions failed');
      
    } catch (e) {
      log('❌ [SYNC] Failed to push local data: $e');
      rethrow;
    }
  }

  /// Get current user ID
  Future<String?> _getCurrentUserId() async {
    try {
      final user = _authService.currentUser;
      return user?.uid;
    } catch (e) {
      log('❌ [SYNC] Failed to get current user ID: $e');
      return null;
    }
  }

  /// Manual sync trigger
  Future<void> syncNow() async {
    log('🔄 [SYNC] Manual sync requested');
    await performFullSync();
  }

  /// Get sync status
  Map<String, dynamic> getSyncStatus() {
    return {
      'isSyncing': _isSyncing,
      'lastSyncTime': DateTime.now().toIso8601String(),
    };
  }

  /// Dispose resources
  void dispose() {
    _syncStatusController.close();
  }
}
