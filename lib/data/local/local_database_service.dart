import 'dart:async';
import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/transaction_model.dart';

class LocalDatabaseService {
  static Database? _database;
  static const String _databaseName = 'expensebuddy.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _transactionsTable = 'transactions';
  static const String _syncLogTable = 'sync_log';

  // Singleton pattern
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
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
        updatedAt INTEGER NOT NULL,
        syncStatus TEXT NOT NULL DEFAULT 'pending',
        syncAttempts INTEGER NOT NULL DEFAULT 0,
        lastSyncAttempt INTEGER,
        syncError TEXT
      )
    ''');

    // Create sync log table
    await db.execute('''
      CREATE TABLE $_syncLogTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        tableName TEXT NOT NULL,
        recordId TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        status TEXT NOT NULL,
        error TEXT
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_transactions_userId ON $_transactionsTable(userId)');
    await db.execute('CREATE INDEX idx_transactions_syncStatus ON $_transactionsTable(syncStatus)');
    await db.execute('CREATE INDEX idx_transactions_date ON $_transactionsTable(date)');
    await db.execute('CREATE INDEX idx_sync_log_timestamp ON $_syncLogTable(timestamp)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Future upgrade logic
    }
  }

  // Transaction CRUD operations
  Future<void> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    
    final map = _transactionToMap(transaction);
    log('💾 [DB] Inserting transaction: ${transaction.title} (${transaction.id})');
    log('💾 [DB] Sync status: ${map['syncStatus']}');
    log('💾 [DB] User ID: ${map['userId']}');
    
    await db.insert(
      _transactionsTable,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    log('✅ [DB] Transaction inserted successfully');
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    await db.update(
      _transactionsTable,
      _transactionToMap(transaction),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      _transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<TransactionModel?> getTransaction(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return _mapToTransaction(maps.first);
    }
    return null;
  }

  Future<List<TransactionModel>> getAllTransactions(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _transactionsTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => _mapToTransaction(maps[i]));
  }

  Future<List<TransactionModel>> getUnsyncedTransactions(String userId) async {
    final db = await database;
    
    // Just get all transactions for the user
    final List<Map<String, dynamic>> maps = await db.query(
      _transactionsTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt ASC',
    );

    log('🔍 [DB] Found ${maps.length} transactions for user: $userId');
    
    return List.generate(maps.length, (i) => _mapToTransaction(maps[i]));
  }

  // Simple sync status methods
  Future<void> markTransactionAsSynced(String id) async {
    // Not needed for simple sync
  }

  Future<void> markTransactionAsPending(String id) async {
    // Not needed for simple sync
  }

  Future<void> markTransactionAsFailed(String id, String error) async {
    // Not needed for simple sync
  }

  // Simple sync log operations
  Future<void> logSyncOperation({
    required String operation,
    required String tableName,
    required String recordId,
    required String status,
    String? error,
  }) async {
    // Not needed for simple sync
  }

  Future<List<Map<String, dynamic>>> getSyncLog({
    int limit = 100,
    String? operation,
  }) async {
    return []; // Not needed for simple sync
  }

  // Utility methods
  Map<String, dynamic> _transactionToMap(TransactionModel transaction) {
    return {
      'id': transaction.id,
      'title': transaction.title,
      'amount': transaction.amount,
      'category': transaction.category,
      'date': transaction.date.millisecondsSinceEpoch,
      'description': transaction.description,
      'userId': transaction.userId,
      'currency': transaction.currency,
      'type': transaction.type.toString().split('.').last,
      'createdAt': transaction.createdAt.millisecondsSinceEpoch,
      'updatedAt': transaction.updatedAt.millisecondsSinceEpoch,
      'syncStatus': transaction.syncStatus.toString().split('.').last,
      'syncAttempts': transaction.syncAttempts,
      'lastSyncAttempt': transaction.lastSyncAttempt?.millisecondsSinceEpoch,
      'syncError': transaction.syncError,
    };
  }

  TransactionModel _mapToTransaction(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'],
      userId: map['userId'],
      currency: map['currency'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => TransactionType.expense,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['syncStatus'],
        orElse: () => SyncStatus.pending,
      ),
      syncAttempts: map['syncAttempts'],
      lastSyncAttempt: map['lastSyncAttempt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSyncAttempt'])
          : null,
      syncError: map['syncError'],
    );
  }

  // Database maintenance
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_transactionsTable);
    await db.delete(_syncLogTable);
  }

  // Clear data for a specific user (for sync purposes)
  Future<void> clearUserData(String userId) async {
    final db = await database;
    await db.delete(
      _transactionsTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    log('Cleared local data for user: $userId');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
