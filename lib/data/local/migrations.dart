import 'package:sqflite/sqflite.dart';

class Migrations {
  static Future<void> createTables(Database db) async {
    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        userId TEXT NOT NULL,
        currency TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        name TEXT NOT NULL,
        photoUrl TEXT,
        defaultCurrency TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }
  
  static Future<void> upgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }
}
