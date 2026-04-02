import 'package:expense_tracker/core/error/error.dart';
import 'package:expense_tracker/db/database/database_helper.dart';
import 'package:expense_tracker/domain/model/expense.dart';

class ExpenseRepository {
  final DatabaseHelper dbHelper;

  ExpenseRepository(this.dbHelper);

  Future<int> addExpense(Expense expense) async {
    try {
      final result = await dbHelper.insertExpense(expense.toMap());
      return result;
    } catch (e) {
      throw DatabaseException("Failed to add expense: $e");
    }
  }

  Future<List<Expense>> getExpenses() async {
    try {
      final data = await dbHelper.getExpenses();

      return data.map((e) => Expense.fromMap(e)).toList();
    } catch (e) {
      throw DatabaseException("Failed to fetch expenses");
    }
  }

  Future<int> updateExpense(Expense expense) async {
    try {
      return await dbHelper.updateExpense(expense.id!, expense.toMap());
    } catch (e) {
      throw DatabaseException("Failed to update expense: $e");
    }
  }

  Future<int> deleteExpense(int id) async {
    try {
      return await dbHelper.deleteExpense(id);
    } catch (e) {
      throw DatabaseException("Failed to delete expense: $e");
    }
  }
}
