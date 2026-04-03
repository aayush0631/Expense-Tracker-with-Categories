import 'package:expense_tracker/core/utils/error_handler.dart';
import 'package:expense_tracker/core/utils/result.dart';
import 'package:expense_tracker/db/database/database_helper.dart';
import 'package:expense_tracker/domain/model/category.dart';
import 'package:expense_tracker/domain/model/expense.dart';

class ExpenseRepository {
  final DatabaseHelper dbHelper;

  ExpenseRepository(this.dbHelper);

  // ---------------- CATEGORIES ----------------
  Future<Result<List<Category>>> getCategories() async {
    try {
      final data = await dbHelper.getCategories();
      return Success(data.map(Category.fromMap).toList());
    } catch (e) {
      return Failure(ErrorHandler.handle(e));
    }
  }

  // ---------------- EXPENSES ----------------
  Future<Result<List<Expense>>> getExpenses() async {
    try {
      final data = await dbHelper.getExpenses();
      return Success(data.map(Expense.fromMap).toList());
    } catch (e) {
      return Failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<int>> addExpense(Expense e) async {
    try {
      final id = await dbHelper.insertExpense(e.toMap());
      return Success(id);
    } catch (e) {
      return Failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<int>> updateExpense(Expense e) async {
    try {
      final rows = await dbHelper.updateExpense(e.id!, e.toMap());
      return Success(rows);
    } catch (e) {
      return Failure(ErrorHandler.handle(e));
    }
  }

  Future<Result<int>> deleteExpense(int id) async {
    try {
      final rows = await dbHelper.deleteExpense(id);
      return Success(rows);
    } catch (e) {
      return Failure(ErrorHandler.handle(e));
    }
  }

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

  Future<Result<List<Expense>>> searchExpenses(String q) async {
    try {
      final data = await dbHelper.searchExpense(q);
      return Success(data.map(Expense.fromMap).toList());
    } catch (e) {
      return Failure(ErrorHandler.handle(e));
    }
  }
}