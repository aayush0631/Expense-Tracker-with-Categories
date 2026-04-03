import 'package:expense_tracker/core/utils/error_handler.dart';
import 'package:expense_tracker/core/utils/result.dart';
import 'package:expense_tracker/db/database/database_helper.dart';
import 'package:expense_tracker/domain/model/category.dart';
import 'package:expense_tracker/domain/model/expense.dart';
import 'package:expense_tracker/domain/model/expense_model.dart';

/// Repository layer that acts as a bridge between
/// the database (data source) and the domain/view models.
///
/// Responsibilities:
/// - Fetching data from SQLite via DatabaseHelper
/// - Converting raw maps into domain models
/// - Handling errors using Result (Success/Failure wrapper)
/// - Providing clean APIs for ViewModels
class ExpenseRepository {
  final DatabaseHelper dbHelper;

  /// Creates an instance of ExpenseRepository with required DatabaseHelper.
  ExpenseRepository(this.dbHelper);

  //  CATEGORIES 

  /// Fetches all categories from the database.
  ///
  /// Returns:
  /// - [Success] containing list of [Category] on success
  /// - [Failure] containing error details on failure
  Future<Result<List<Category>>> getCategories() async {
    try {
      final data = await dbHelper.getCategories();
      return Success(data.map(Category.fromMap).toList());
    } catch (e) {
      return Failure(ErrorHandler.handle(e));
    }
  }

  //  EXPENSES 

  /// Fetches all expenses from the database.
  ///
  /// Returns:
  /// - [Success] containing list of [Expense]
  /// - [Failure] if an error occurs
  Future<Result<List<Expense>>> getExpenses() async {
    try {
      final data = await dbHelper.getExpenses();
      return Success(data.map(Expense.fromMap).toList());
    } catch (e) {
      return Failure(ErrorHandler.handle(e));
    }
  }

  /// Inserts a new expense into the database.
  ///
  /// Returns:
  /// - [Success] containing inserted row ID
  /// - [Failure] if insertion fails
  Future<Result<int>> addExpense(Expense e) async {
    try {
      final id = await dbHelper.insertExpense(e.toMap());
      return Success(id);
    } catch (e) {
      return Failure(ErrorHandler.handle(e));
    }
  }

  /// Updates an existing expense in the database.
  ///
  /// Requires:
  /// - Expense must have a valid non-null ID
  ///
  /// Returns:
  /// - [Success] containing number of rows updated
  /// - [Failure] if update fails
  Future<Result<int>> updateExpense(Expense e) async {
    try {
      final rows = await dbHelper.updateExpense(e.id!, e.toMap());
      return Success(rows);
    } catch (e) {
      return Failure(ErrorHandler.handle(e));
    }
  }

  /// Deletes an expense by its ID.
  ///
  /// Returns:
  /// - [Success] containing number of rows deleted
  /// - [Failure] if deletion fails
  Future<Result<int>> deleteExpense(int id) async {
    try {
      final rows = await dbHelper.deleteExpense(id);
      return Success(rows);
    } catch (e) {
      return Failure(ErrorHandler.handle(e));
    }
  }

  //  FILTERING 

  /// Fetches expenses using advanced filters.
  ///
  /// Supports:
  /// - Date range filtering (start/end)
  /// - Category filtering
  ///
  /// Returns:
  /// - [Success] containing filtered list of [Expense]
  /// - [Failure] if query fails
  Future<Result<List<Expense>>> getAdvancedExpenses({
    DateTime? start,
    DateTime? end,
    int? categoryId,
  }) async {
    try {
      final data = await dbHelper.getExpenseAdvance(
        startDate: start,
        endDate: end,
        categoryId: categoryId,
      );
      return Success(data.map(Expense.fromMap).toList());
    } catch (e) {
      return Failure(ErrorHandler.handle(e));
    }
  }

  /// Calculates total expense amount with optional filters.
  ///
  /// Supports:
  /// - Date range
  /// - Category filtering
  ///
  /// Returns:
  /// - [Success] containing total sum as double
  /// - [Failure] if calculation fails
  Future<Result<double>> getTotalExpenses({
    DateTime? start,
    DateTime? end,
    int? categoryId,
  }) async {
    try {
      final total = await dbHelper.totalExpenses(
        startDate: start,
        endDate: end,
        categoryId: categoryId,
      );
      return Success(total);
    } catch (e) {
      return Failure(ErrorHandler.handle(e));
    }
  }

  //  SEARCH 

  /// Searches expenses by description keyword.
  ///
  /// Returns:
  /// - [Success] containing matching expenses
  /// - [Failure] if search fails
  Future<Result<List<Expense>>> searchExpenses(String q) async {
    try {
      final data = await dbHelper.searchExpense(q);
      return Success(data.map(Expense.fromMap).toList());
    } catch (e) {
      return Failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<List<ExpenseStat>>> getExpenseStats({int? categoryId}) async {
  try {
    final data = await dbHelper.getExpensesForStatWithCatageory(categoryId);
    return Success(data.map(ExpenseStat.fromMap).toList());
  } catch (e) {
    return Failure(ErrorHandler.handle(e));
  }
}
}