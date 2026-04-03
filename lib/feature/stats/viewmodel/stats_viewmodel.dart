import 'package:expense_tracker/db/repository/expense_repository.dart';
import 'package:expense_tracker/domain/model/category.dart';
import 'package:expense_tracker/domain/model/expense_model.dart';
import 'package:flutter/material.dart';

class StatsViewModel extends ChangeNotifier {
  final ExpenseRepository repo;

  StatsViewModel({required this.repo});

  final List<ExpenseStat> _stats = [];
  List<ExpenseStat> get stats => _stats;

  final List<Category> _categories = [];
  List<Category> get categories => _categories;

  int? selectedCategoryId;
  bool isLoading = false;
  String? errorMessage;

  double get totalAmount =>
      _stats.fold(0, (sum, s) => sum + s.amount);

  double get avgAmount =>
      _stats.isEmpty ? 0 : totalAmount / _stats.length;

  double get maxAmount =>
      _stats.isEmpty ? 0 : _stats.map((s) => s.amount).reduce((a, b) => a > b ? a : b);

  Map<String, double> get perCategory {
    final map = <String, double>{};
    for (final s in _stats) {
      map[s.categoryName] = (map[s.categoryName] ?? 0) + s.amount;
    }
    return map;
  }
}