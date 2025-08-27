import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';
import '../data/local/local_database_service.dart';
import '../services/connectivity_service.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService _budgetService = BudgetService();
  final LocalDatabaseService _localDb = LocalDatabaseService();
  final ConnectivityService _connectivityService = ConnectivityService();
  
  List<BudgetModel> _budgets = [];
  BudgetSummary? _budgetSummary;
  bool _isLoading = false;
  String? _error;
  
  // Connectivity monitoring
  StreamSubscription<ConnectionStatus>? _connectivitySubscription;
  
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
      // Load from local database first
      debugPrint('💾 [BUDGET] Loading budgets from local database...');
      _budgets = await _localDb.getAllBudgets(userId);
      debugPrint('✅ [BUDGET] Loaded ${_budgets.length} budgets from local database');
      
      // Try to load from Firebase if online
      if (_connectivityService.isConnected) {
        try {
          debugPrint('🔥 [BUDGET] Network available, loading from Firebase...');
          final firebaseBudgets = await _budgetService.getAllBudgets(userId);
          final firebaseSummary = await _budgetService.getBudgetSummary(userId);
          
          // Update local database with Firebase data
          for (final budget in firebaseBudgets) {
            await _localDb.insertBudget(budget);
          }
          
          _budgets = firebaseBudgets;
          _budgetSummary = firebaseSummary;
          debugPrint('✅ [BUDGET] Loaded ${_budgets.length} budgets from Firebase');
        } catch (e) {
          debugPrint('⚠️ [BUDGET] Firebase load failed: $e, using local data');
          // Use local data if Firebase fails
          _budgetSummary = await _calculateLocalBudgetSummary(userId);
        }
      } else {
        debugPrint('📡 [BUDGET] No network connection, using local data');
        _budgetSummary = await _calculateLocalBudgetSummary(userId);
      }
      
      _isLoading = false;
      notifyListeners();
      
      // Start connectivity monitoring for auto-sync
      _startConnectivityMonitoring();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint('❌ [BUDGET] Error loading budgets: $e');
      notifyListeners();
    }
  }

  // Calculate budget summary from local data
  Future<BudgetSummary> _calculateLocalBudgetSummary(String userId) async {
    try {
      final localBudgets = await _localDb.getAllBudgets(userId);
      
      if (localBudgets.isEmpty) {
        return BudgetSummary(
          totalBudget: 0.0,
          totalSpent: 0.0,
          spentPercentage: 0.0,
          budgets: [],
        );
      }
      
      final totalBudget = localBudgets.fold(0.0, (sum, budget) => sum + budget.allocatedAmount);
      final totalSpent = localBudgets.fold(0.0, (sum, budget) => sum + budget.spentAmount);
      final spentPercentage = totalBudget > 0 ? (totalSpent / totalBudget * 100).clamp(0.0, 100.0) : 0.0;

      return BudgetSummary(
        totalBudget: totalBudget,
        totalSpent: totalSpent,
        spentPercentage: spentPercentage,
        budgets: localBudgets,
      );
    } catch (e) {
      debugPrint('❌ [BUDGET] Error calculating local summary: $e');
      return BudgetSummary(
        totalBudget: 0.0,
        totalSpent: 0.0,
        spentPercentage: 0.0,
        budgets: [],
      );
    }
  }

  // Start connectivity monitoring for auto-sync
  void _startConnectivityMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivityService.connectionStatusStream.listen((status) {
      if (status == ConnectionStatus.connected) {
        debugPrint('🌐 [BUDGET] Network restored, auto-syncing budgets...');
        _autoSyncWhenOnline();
      }
    });
  }

  // Auto-sync when online
  Future<void> _autoSyncWhenOnline() async {
    try {
      // Get current user ID from budgets
      if (_budgets.isNotEmpty && _budgets.first.userId != null) {
        await retryAllFirebaseSyncs(_budgets.first.userId!);
      }
    } catch (e) {
      debugPrint('❌ [BUDGET] Auto-sync failed: $e');
    }
  }

  // Retry Firebase sync for a single budget
  Future<Map<String, dynamic>> retryFirebaseSync(BudgetModel budget) async {
    try {
      debugPrint('🔄 [BUDGET] Retrying Firebase sync for budget: ${budget.name}');
      
      // Check connectivity first
      if (!_connectivityService.isConnected) {
        debugPrint('📡 [BUDGET] No network connection, skipping Firebase sync');
        return {
          'success': false,
          'firebaseSuccess': false,
          'firebaseError': 'No network connection',
        };
      }
      
      try {
        // Try to sync to Firebase
        await _budgetService.createBudget(budget);
        
        // Mark as synced in local database
        await _localDb.markBudgetAsSynced(budget.id);
        
        debugPrint('✅ [BUDGET] Successfully synced budget: ${budget.name}');
        
        return {
          'success': true,
          'firebaseSuccess': true,
          'firebaseError': null,
        };
      } catch (e) {
        debugPrint('❌ [BUDGET] Failed to sync budget ${budget.name}: $e');
        
        return {
          'success': false,
          'firebaseSuccess': false,
          'firebaseError': e.toString(),
        };
      }
    } catch (e) {
      debugPrint('❌ [BUDGET] Error during Firebase sync: $e');
      
      return {
        'success': false,
        'firebaseSuccess': false,
        'firebaseError': e.toString(),
      };
    }
  }

  // Retry Firebase sync for all unsynced budgets
  Future<void> retryAllFirebaseSyncs(String userId) async {
    try {
      debugPrint('🔄 [BUDGET] Starting Firebase sync for all unsynced budgets...');
      
      // Check connectivity first
      if (!_connectivityService.isConnected) {
        debugPrint('📡 [BUDGET] No network connection, skipping Firebase sync');
        return;
      }
      
      final unsyncedBudgets = await _localDb.getUnsyncedBudgets(userId);
      debugPrint('📱 [BUDGET] Found ${unsyncedBudgets.length} unsynced budgets');
      
      if (unsyncedBudgets.isEmpty) {
        debugPrint('✅ [BUDGET] All budgets are already synced');
        return;
      }
      
      int successCount = 0;
      int failureCount = 0;
      
      for (final budget in unsyncedBudgets) {
        try {
          // Try to sync to Firebase
          await _budgetService.createBudget(budget);
          
          // Mark as synced in local database
          await _localDb.markBudgetAsSynced(budget.id);
          successCount++;
          
          debugPrint('✅ [BUDGET] Successfully synced budget: ${budget.name}');
        } catch (e) {
          failureCount++;
          debugPrint('❌ [BUDGET] Failed to sync budget ${budget.name}: $e');
        }
      }
      
      debugPrint('🎯 [BUDGET] Firebase sync completed. Success: $successCount, Failed: $failureCount');
      
      // Reload budgets to reflect sync status
      if (successCount > 0) {
        await loadBudgets(userId);
      }
    } catch (e) {
      debugPrint('❌ [BUDGET] Error during Firebase sync: $e');
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
  Future<Map<String, dynamic>> addBudget(BudgetModel budget) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Save to local database first
      debugPrint('💾 [BUDGET] Saving budget to local database...');
      await _localDb.insertBudget(budget);
      debugPrint('✅ [BUDGET] Saved to local database successfully');
      
      // Add to local list immediately
      _budgets.add(budget);
      notifyListeners();
      
      // Check connectivity before attempting Firebase
      bool firebaseSuccess = false;
      String? firebaseError;
      
      if (_connectivityService.isConnected) {
        debugPrint('🔥 [BUDGET] Network available, trying to save to Firebase...');
        try {
          await _budgetService.createBudget(budget);
          debugPrint('✅ [BUDGET] Saved to Firebase successfully');
          firebaseSuccess = true;
          
          // Mark as synced in local database
          await _localDb.markBudgetAsSynced(budget.id);
        } catch (e) {
          firebaseError = e.toString();
          debugPrint('⚠️ [BUDGET] Failed to save to Firebase: $e (but saved locally)');
        }
      } else {
        debugPrint('📡 [BUDGET] No network connection, skipping Firebase save');
        firebaseError = 'No network connection';
      }
      
      // Reload budgets and summary to get updated spent amounts
      if (budget.userId != null) {
        await loadBudgets(budget.userId!);
      }
      
      _isLoading = false;
      notifyListeners();
      
      return {
        'success': true,
        'firebaseSuccess': firebaseSuccess,
        'firebaseError': firebaseError,
      };
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint('❌ [BUDGET] Error adding budget: $e');
      notifyListeners();
      
      return {
        'success': false,
        'firebaseSuccess': false,
        'firebaseError': e.toString(),
      };
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
  Future<Map<String, dynamic>> updateBudget(BudgetModel budget) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Save to local database first
      debugPrint('💾 [BUDGET] Updating budget in local database...');
      await _localDb.updateBudget(budget);
      debugPrint('✅ [BUDGET] Updated in local database successfully');
      
      // Update in local list
      final index = _budgets.indexWhere((b) => b.id == budget.id);
      if (index >= 0) {
        _budgets[index] = budget;
      }
      
      // Check connectivity before attempting Firebase
      bool firebaseSuccess = false;
      String? firebaseError;
      
      if (_connectivityService.isConnected) {
        debugPrint('🔥 [BUDGET] Network available, trying to update in Firebase...');
        try {
          await _budgetService.updateBudget(budget);
          debugPrint('✅ [BUDGET] Updated in Firebase successfully');
          firebaseSuccess = true;
          
          // Mark as synced in local database
          await _localDb.markBudgetAsSynced(budget.id);
        } catch (e) {
          firebaseError = e.toString();
          debugPrint('⚠️ [BUDGET] Failed to update in Firebase: $e (but updated locally)');
        }
      } else {
        debugPrint('📡 [BUDGET] No network connection, skipping Firebase update');
        firebaseError = 'No network connection';
      }
      
      // Reload summary
      if (budget.userId != null) {
        _budgetSummary = await _budgetService.getBudgetSummary(budget.userId!);
      }
      
      _isLoading = false;
      notifyListeners();
      
      return {
        'success': true,
        'firebaseSuccess': firebaseSuccess,
        'firebaseError': firebaseError,
      };
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint('❌ [BUDGET] Error updating budget: $e');
      notifyListeners();
      
      return {
        'success': false,
        'firebaseSuccess': false,
        'firebaseError': e.toString(),
      };
    }
  }
  
  // Delete budget
  Future<Map<String, dynamic>> deleteBudget(String budgetId, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Delete from local database first
      debugPrint('🗑️ [BUDGET] Deleting budget from local database...');
      await _localDb.deleteBudget(budgetId);
      debugPrint('✅ [BUDGET] Deleted from local database successfully');
      
      // Remove from local list
      _budgets.removeWhere((b) => b.id == budgetId);
      
      // Check connectivity before attempting Firebase
      bool firebaseSuccess = false;
      String? firebaseError;
      
      if (_connectivityService.isConnected) {
        debugPrint('🔥 [BUDGET] Network available, trying to delete from Firebase...');
        try {
          await _budgetService.deleteBudget(budgetId);
          debugPrint('✅ [BUDGET] Deleted from Firebase successfully');
          firebaseSuccess = true;
        } catch (e) {
          firebaseError = e.toString();
          debugPrint('⚠️ [BUDGET] Failed to delete from Firebase: $e (but deleted locally)');
        }
      } else {
        debugPrint('📡 [BUDGET] No network connection, skipping Firebase delete');
        firebaseError = 'No network connection';
      }
      
      // Reload summary
      _budgetSummary = await _budgetService.getBudgetSummary(userId);
      
      _isLoading = false;
      notifyListeners();
      
      return {
        'success': true,
        'firebaseSuccess': firebaseSuccess,
        'firebaseError': firebaseError,
      };
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint('❌ [BUDGET] Error deleting budget: $e');
      notifyListeners();
      
      return {
        'success': false,
        'firebaseSuccess': false,
        'firebaseError': e.toString(),
      };
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

  // Clear local budget data for a user
  Future<void> clearLocalBudgetData(String userId) async {
    try {
      await _localDb.clearUserBudgetData(userId);
      debugPrint('🧹 [BUDGET] Cleared local budget data for user: $userId');
    } catch (e) {
      debugPrint('❌ [BUDGET] Error clearing local budget data: $e');
    }
  }

  // Dispose resources
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
