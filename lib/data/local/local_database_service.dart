import 'dart:async';
import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/transaction_model.dart';
import '../../models/budget_model.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static Database? _database;
  static const String _transactionsTable = 'transactions';
  static const String _budgetsTable = 'budgets';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'expensebuddy.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE $_transactionsTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date INTEGER NOT NULL,
        description TEXT,
        userId TEXT NOT NULL,
        currency TEXT NOT NULL,
        type TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_transactions_userId ON $_transactionsTable(userId)');
    await db.execute('CREATE INDEX idx_transactions_date ON $_transactionsTable(date)');
    await db.execute('CREATE INDEX idx_transactions_category ON $_transactionsTable(category)');
    await db.execute('CREATE INDEX idx_transactions_type ON $_transactionsTable(type)');

    // Create budgets table
    await db.execute('''
      CREATE TABLE $_budgetsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        allocatedAmount REAL NOT NULL,
        spentAmount REAL NOT NULL,
        periodType TEXT NOT NULL,
        startDate INTEGER NOT NULL,
        endDate INTEGER NOT NULL,
        color TEXT NOT NULL,
        userId TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create indexes for budgets
    await db.execute('CREATE INDEX idx_budgets_userId ON $_budgetsTable(userId)');
    await db.execute('CREATE INDEX idx_budgets_periodType ON $_budgetsTable(periodType)');
    await db.execute('CREATE INDEX idx_budgets_isSynced ON $_budgetsTable(isSynced)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 1) {
      // Future upgrade logic here
    }
    
    if (oldVersion < 2) {
      // Add budgets table for version 2
      await db.execute('''
        CREATE TABLE $_budgetsTable (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          icon TEXT NOT NULL,
          allocatedAmount REAL NOT NULL,
          spentAmount REAL NOT NULL,
          periodType TEXT NOT NULL,
          startDate INTEGER NOT NULL,
          endDate INTEGER NOT NULL,
          color TEXT NOT NULL,
          userId TEXT NOT NULL,
          createdAt INTEGER NOT NULL,
          updatedAt INTEGER NOT NULL,
          isSynced INTEGER NOT NULL DEFAULT 0
        )
      ''');
      
      // Create indexes for budgets
      await db.execute('CREATE INDEX idx_budgets_userId ON $_budgetsTable(userId)');
      await db.execute('CREATE INDEX idx_budgets_periodType ON $_budgetsTable(periodType)');
      await db.execute('CREATE INDEX idx_budgets_isSynced ON $_budgetsTable(isSynced)');
    }
  }

  // Insert transaction
  Future<void> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    final map = transaction.toJson();
    
    log('💾 [DB] Inserting transaction: ${transaction.title}');
    log('💾 [DB] User ID: ${map['userId']}');
    
    await db.insert(
      _transactionsTable,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    log('✅ [DB] Transaction inserted successfully');
  }

  // Update transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    final map = transaction.toJson();
    
    log('💾 [DB] Updating transaction: ${transaction.title}');
    
    await db.update(
      _transactionsTable,
      map,
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    log('✅ [DB] Transaction updated successfully');
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    final db = await database;
    
    log('🗑️ [DB] Deleting transaction: $id');
    
    await db.delete(
      _transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    log('✅ [DB] Transaction deleted successfully');
  }

  // Get transaction by ID
  Future<TransactionModel?> getTransaction(String id) async {
    final db = await database;
    
    final maps = await db.query(
      _transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TransactionModel.fromJson(maps.first);
    }
    return null;
  }

  // Get all transactions for a user
  Future<List<TransactionModel>> getAllTransactions(String userId) async {
    final db = await database;
    
    final maps = await db.query(
      _transactionsTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return maps.map((map) => TransactionModel.fromJson(map)).toList();
  }

  // Get transactions by type
  Future<List<TransactionModel>> getTransactionsByType(String userId, TransactionType type) async {
    final db = await database;
    
    final maps = await db.query(
      _transactionsTable,
      where: 'userId = ? AND type = ?',
      whereArgs: [userId, type.toString().split('.').last],
      orderBy: 'date DESC',
    );

    return maps.map((map) => TransactionModel.fromJson(map)).toList();
  }

  // Get transactions by category
  Future<List<TransactionModel>> getTransactionsByCategory(String userId, String category) async {
    final db = await database;
    
    final maps = await db.query(
      _transactionsTable,
      where: 'userId = ? AND category = ?',
      whereArgs: [userId, category],
      orderBy: 'date DESC',
    );

    return maps.map((map) => TransactionModel.fromJson(map)).toList();
  }

  // Get transactions by date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    String userId, 
    DateTime start, 
    DateTime end
  ) async {
    final db = await database;
    
    final startMillis = start.millisecondsSinceEpoch;
    final endMillis = end.millisecondsSinceEpoch;
    
    final maps = await db.query(
      _transactionsTable,
      where: 'userId = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, startMillis, endMillis],
      orderBy: 'date DESC',
    );

    return maps.map((map) => TransactionModel.fromJson(map)).toList();
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_transactionsTable);
  }

  // Clear data for a specific user
  Future<void> clearUserData(String userId) async {
    final db = await database;
    await db.delete(
      _transactionsTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // ===== BUDGET METHODS =====

  // Insert budget
  Future<void> insertBudget(BudgetModel budget) async {
    final db = await database;
    final map = budget.toJson();
    map['isSynced'] = 0; // Mark as not synced
    
    log('💾 [DB] Inserting budget: ${budget.name}');
    log('💾 [DB] User ID: ${map['userId']}');
    
    await db.insert(
      _budgetsTable,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    log('✅ [DB] Budget inserted successfully');
  }

  // Update budget
  Future<void> updateBudget(BudgetModel budget) async {
    final db = await database;
    final map = budget.toJson();
    map['isSynced'] = 0; // Mark as not synced
    
    log('💾 [DB] Updating budget: ${budget.name}');
    
    await db.update(
      _budgetsTable,
      map,
      where: 'id = ?',
      whereArgs: [budget.id],
    );
    log('✅ [DB] Budget updated successfully');
  }

  // Delete budget
  Future<void> deleteBudget(String id) async {
    final db = await database;
    
    log('🗑️ [DB] Deleting budget: $id');
    
    await db.delete(
      _budgetsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    log('✅ [DB] Budget deleted successfully');
  }

  // Get budget by ID
  Future<BudgetModel?> getBudget(String id) async {
    final db = await database;
    
    final maps = await db.query(
      _budgetsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BudgetModel.fromJson(maps.first);
    }
    return null;
  }

  // Get all budgets for a user
  Future<List<BudgetModel>> getAllBudgets(String userId) async {
    final db = await database;
    
    final maps = await db.query(
      _budgetsTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => BudgetModel.fromJson(map)).toList();
  }

  // Get budgets by period type
  Future<List<BudgetModel>> getBudgetsByPeriod(String userId, String periodType) async {
    final db = await database;
    
    final maps = await db.query(
      _budgetsTable,
      where: 'userId = ? AND periodType = ?',
      whereArgs: [userId, periodType],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => BudgetModel.fromJson(map)).toList();
  }

  // Get budgets for a specific month
  Future<List<BudgetModel>> getBudgetsForMonth(String userId, DateTime month) async {
    final db = await database;
    
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    final startMillis = startOfMonth.millisecondsSinceEpoch;
    final endMillis = endOfMonth.millisecondsSinceEpoch;
    
    final maps = await db.query(
      _budgetsTable,
      where: 'userId = ? AND startDate <= ? AND endDate >= ?',
      whereArgs: [userId, endMillis, startMillis],
      orderBy: 'startDate DESC',
    );

    return maps.map((map) => BudgetModel.fromJson(map)).toList();
  }

  // Get unsynced budgets
  Future<List<BudgetModel>> getUnsyncedBudgets(String userId) async {
    final db = await database;
    
    final maps = await db.query(
      _budgetsTable,
      where: 'userId = ? AND isSynced = ?',
      whereArgs: [userId, 0],
      orderBy: 'createdAt DESC',
    );

    return maps.map((map) => BudgetModel.fromJson(map)).toList();
  }

  // Mark budget as synced
  Future<void> markBudgetAsSynced(String id) async {
    final db = await database;
    
    await db.update(
      _budgetsTable,
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    
    log('✅ [DB] Budget marked as synced: $id');
  }

  // Clear all budget data
  Future<void> clearAllBudgetData() async {
    final db = await database;
    await db.delete(_budgetsTable);
  }

  // Clear budget data for a specific user
  Future<void> clearUserBudgetData(String userId) async {
    final db = await database;
    await db.delete(
      _budgetsTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}
