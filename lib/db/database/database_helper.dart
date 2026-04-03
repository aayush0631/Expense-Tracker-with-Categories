import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const String dbName = 'expenses_tracker.db';
  static const int dbVersion = 1;

  static const String categoryTable = 'categories';
  static const String expenseTable = 'expenses';

  static const String colId = 'id';
  static const String colName = 'name';
  static const String colIcon = 'icon';
  static const String colColor = 'color';

  static const String colAmount = 'amount';
  static const String colDescription = 'description';
  static const String colCategoryId = 'category_id';
  static const String colDate = 'date';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return openDatabase(
      path,
      version: dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $categoryTable (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colName TEXT NOT NULL,
        $colIcon TEXT,
        $colColor TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $expenseTable (
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colAmount REAL NOT NULL,
        $colDescription TEXT,
        $colCategoryId INTEGER,
        $colDate TEXT NOT NULL,
        FOREIGN KEY ($colCategoryId)
          REFERENCES $categoryTable($colId)
          ON DELETE SET NULL
      )
    ''');

    // Seed default categories
    final defaultCategories = [
      {'name': 'Food', 'icon': 'food', 'color': '#FF5722'},
      {'name': 'Transport', 'icon': 'transport', 'color': '#2196F3'},
      {'name': 'Shopping', 'icon': 'shopping', 'color': '#9C27B0'},
      {'name': 'Bills', 'icon': 'bills', 'color': '#F44336'},
      {'name': 'Other', 'icon': 'other', 'color': '#607D8B'},
    ];
    for (final cat in defaultCategories) {
      await db.insert(categoryTable, cat);
    }
  }

  // ---------------- CATEGORY ----------------
  Future<int> insertCategory(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(categoryTable, data);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return db.query(categoryTable);
  }

  // ---------------- EXPENSE CRUD ----------------
  Future<int> insertExpense(Map<String, dynamic> data) async {
    final db = await database;
    // Remove id so AUTOINCREMENT works correctly
    final insertData = Map<String, dynamic>.from(data)..remove('id');
    return db.insert(expenseTable, insertData);
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final db = await database;
    return db.query(expenseTable, orderBy: '$colDate DESC');
  }

  Future<int> updateExpense(int id, Map<String, dynamic> data) async {
    final db = await database;
    final updateData = Map<String, dynamic>.from(data)..remove('id');
    return db.update(
      expenseTable,
      updateData,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return db.delete(
      expenseTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  // ---------------- FILTER ----------------
  Future<List<Map<String, dynamic>>> getExpenseAdvance({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    int? limit,
  }) async {
    final db = await database;

    List<String> whereParts = [];
    List<dynamic> args = [];

    if (startDate != null && endDate != null) {
      whereParts.add('$colDate BETWEEN ? AND ?');
      args.addAll([
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ]);
    } else if (startDate != null) {
      whereParts.add('$colDate >= ?');
      args.add(startDate.toIso8601String());
    } else if (endDate != null) {
      whereParts.add('$colDate <= ?');
      args.add(endDate.toIso8601String());
    }

    if (categoryId != null) {
      whereParts.add('$colCategoryId = ?');
      args.add(categoryId);
    }

    final where = whereParts.isEmpty ? null : whereParts.join(' AND ');

    return db.query(
      expenseTable,
      where: where,
      whereArgs: args.isEmpty ? null : args,
      limit: limit,
      orderBy: '$colDate DESC',
    );
  }

  // ---------------- TOTAL ----------------
  Future<double> totalExpenses({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
  }) async {
    final db = await database;

    List<String> whereParts = [];
    List<dynamic> args = [];

    if (startDate != null && endDate != null) {
      whereParts.add('$colDate BETWEEN ? AND ?');
      args.addAll([
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ]);
    } else if (startDate != null) {
      whereParts.add('$colDate >= ?');
      args.add(startDate.toIso8601String());
    } else if (endDate != null) {
      whereParts.add('$colDate <= ?');
      args.add(endDate.toIso8601String());
    }

    if (categoryId != null) {
      whereParts.add('$colCategoryId = ?');
      args.add(categoryId);
    }

    final where = whereParts.isEmpty ? null : whereParts.join(' AND ');

    final res = await db.query(
      expenseTable,
      columns: ['SUM($colAmount) as total'],
      where: where,
      whereArgs: args.isEmpty ? null : args,
    );

    return (res.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // ---------------- SEARCH ----------------
  Future<List<Map<String, dynamic>>> searchExpense(String q) async {
    final db = await database;
    return db.query(
      expenseTable,
      where: '$colDescription LIKE ?',
      whereArgs: ['%$q%'],
      orderBy: '$colDate DESC',
    );
  }

  // ---------------- JOIN QUERY ----------------
  Future<List<Map<String, dynamic>>> getExpensesWithCategory() async {
    final db = await database;
    return db.rawQuery('''
      SELECT e.*, c.$colName as category_name, c.$colColor as category_color,
             c.$colIcon as category_icon
      FROM $expenseTable e
      LEFT JOIN $categoryTable c ON e.$colCategoryId = c.$colId
      ORDER BY e.$colDate DESC
    ''');
  }

  // ---------------- DEBUG ----------------
  Future<void> clearAllExpenses() async {
    final db = await database;
    await db.delete(expenseTable);
  }

  Future<void> deleteDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);
    await deleteDatabase(path);
    _database = null;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}