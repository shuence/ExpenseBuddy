import 'dart:async';
import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/transaction_model.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static Database? _database;
  static const String _transactionsTable = 'transactions';

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
      version: 1,
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
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 1) {
      // Future upgrade logic here
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
}
