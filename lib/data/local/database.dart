import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import 'migrations.dart';

class AppDatabase {
  static Database? _database;
  
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), AppConstants.databaseName);
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  static Future<void> _onCreate(Database db, int version) async {
    await Migrations.createTables(db);
  }
  
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await Migrations.upgrade(db, oldVersion, newVersion);
  }
  
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
