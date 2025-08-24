import 'package:sqflite/sqflite.dart';
import '../../models/expense.dart';
import 'database.dart';

class ExpenseDao {
  static const String tableName = 'expenses';
  
  Future<void> insert(Expense expense) async {
    final db = await AppDatabase.database;
    await db.insert(
      tableName,
      expense.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<Expense>> getAllExpenses(String userId) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) => Expense.fromJson(maps[i]));
  }
  
  Future<Expense?> getExpenseById(String id) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Expense.fromJson(maps.first);
    }
    return null;
  }
  
  Future<void> update(Expense expense) async {
    final db = await AppDatabase.database;
    await db.update(
      tableName,
      expense.toJson(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }
  
  Future<void> delete(String id) async {
    final db = await AppDatabase.database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
