import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  //singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static const String databaseName = 'expenses_tracker.db';
  static const String categoryTable = 'categories';
  static const String expenseTable = 'expenses';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnIcon = 'icon';
  static const String columnColor = 'color';
  static const String columnAmount = 'amount';
  static const String columnDescription = 'description';
  static const String columnCategoryId = 'category_id';
  static const String columnDate = 'date';
  static const int databaseVersion = 1;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase(databaseName);
    return _database!;
  }

  Future<Database> _initDatabase(String databaseName) async {
    var databasespath = await getDatabasesPath();
    String path = join(databasespath, databaseName);
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $categoryTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnIcon TEXT,
        $columnColor TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE $expenseTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnAmount REAL NOT NULL,
        $columnDescription TEXT,
        $columnCategoryId INTEGER,
        $columnDate TEXT NOT NULL,
        FOREIGN KEY ($columnCategoryId) REFERENCES $categoryTable($columnId)
      )
    ''');
  }

  Future close() async {
    var dbClient = await database;
    return dbClient.close();
  }

  Future deleteDatabase(String path) async {
    var databasespath = await getDatabasesPath();
    String path = join(databasespath, 'expense_tracker.db');
    await deleteDatabase(path);
  }

  Future<int> insertCategory(Map<String, dynamic> category) async {
    var dbClient = await database;
    return await dbClient.insert(
      categoryTable, 
      category,
      conflictAlgorithm: ConflictAlgorithm.replace,
    ); 
  }

  Future<int> insertExpense(Map<String, dynamic> expense) async {
    var dbClient = await database;
    return await dbClient.insert(
      expenseTable, 
      expense,
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future getCategories() async {
    var dbClient = await database;
    return await dbClient.query(categoryTable);
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final dbClient = await database;
    return await dbClient.query(expenseTable);
  }

  Future deleteCategory(int id) async {
    var dbClient = await database;
    return await dbClient.delete(
      categoryTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      expenseTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future updateExpense(int id, Map<String, dynamic> expense) async {
    final db = await database;
    return await db.update(
      expenseTable,
      expense,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getExpenseAdvance({
      DateTime? startDate,
      DateTime? endDate,
      int? categoryId,
      int? limit,
    }) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      expenseTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}
