import 'package:expense_tracker/core/utils/result.dart';
import 'package:expense_tracker/db/repository/expense_repository.dart';
import 'package:expense_tracker/domain/model/category.dart';
import 'package:expense_tracker/domain/model/expense.dart';
import 'package:flutter/material.dart';

class ExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository repo;

  ExpenseViewModel({required this.repo});

  // ------------------ STATE ------------------
  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  List<Expense>? _filteredExpenses;
  List<Expense>? get filteredExpenses => _filteredExpenses;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  bool isLoading = false;
  String? errorMessage;

  // ------------------ TOTALS ------------------
  double totalAll = 0;
  double totalToday = 0;
  double totalMonth = 0;

  // ------------------ NAV ------------------
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // ------------------ FILTER CATEGORY ------------------
  // Used by the header dropdown to filter the list
  int? selectedCategoryId;

  // ------------------ FORM CATEGORY ------------------
  // Separate from filter — used only inside the add/edit form
  int? _formCategoryId;
  int? get formCategoryId => _formCategoryId;

  // Returns category name by id, falls back to 'Other'
  String categoryName(int id) {
    return _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => Category(name: 'Other'),
    ).name;
  }

  // ------------------ FORM ------------------
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime? selectedDate;
  Expense? editingExpense;

  // ------------------ INIT ------------------
  Future<void> init() async {
    await loadCategories();
    await loadExpenses();
    await loadDashboard();
  }

  // ------------------ CATEGORIES ------------------
  Future<void> loadCategories() async {
    final result = await repo.getCategories();
    if (result is Success<List<Category>>) {
      _categories = result.data;
      notifyListeners();
    }
  }

  // ------------------ EXPENSES ------------------
  Future<void> loadExpenses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await repo.getExpenses();

    if (result is Success<List<Expense>>) {
      _expenses = result.data;
      errorMessage = null;
    } else if (result is Failure<List<Expense>>) {
      errorMessage = result.message;
    }

    isLoading = false;
    notifyListeners();
  }

  // ------------------ SAVE (ADD / EDIT) ------------------
  Future<bool> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (selectedDate == null || _formCategoryId == null) return false;

    final expense = Expense(
      id: editingExpense?.id,
      amount: double.parse(amountController.text.trim()),
      description: descriptionController.text.trim(),
      categoryId: _formCategoryId!,
      date: selectedDate!,
    );

    isLoading = true;
    notifyListeners();

    Result result;
    if (editingExpense == null) {
      result = await repo.addExpense(expense);
    } else {
      result = await repo.updateExpense(expense);
    }

    if (result is Failure) {
      errorMessage = (result as Failure).message;
      isLoading = false;
      notifyListeners();
      return false;
    }

    await loadExpenses();
    await _refreshTotals();
    await _refreshFilter();
    clearForm();

    isLoading = false;
    notifyListeners();
    return true;
  }

  // ------------------ DELETE ------------------
  Future<bool> deleteExpense(int id) async {
    final result = await repo.deleteExpense(id);

    if (result is Failure) {
      errorMessage = (result as Failure).message;
      notifyListeners();
      return false;
    }

    _expenses.removeWhere((e) => e.id == id);
    _filteredExpenses?.removeWhere((e) => e.id == id);

    await _refreshTotals();
    notifyListeners();
    return true;
  }

  // ------------------ DASHBOARD ------------------
  Future<void> loadDashboard() async {
    await _refreshTotals();
  }

  Future<void> _refreshTotals() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);

    final all = await repo.getTotalExpenses(
      categoryId: selectedCategoryId,
    );
    final today = await repo.getTotalExpenses(
      start: todayStart,
      end: now,
      categoryId: selectedCategoryId,
    );
    final month = await repo.getTotalExpenses(
      start: monthStart,
      end: now,
      categoryId: selectedCategoryId,
    );

    if (all is Success<double>) totalAll = all.data;
    if (today is Success<double>) totalToday = today.data;
    if (month is Success<double>) totalMonth = month.data;

    notifyListeners();
  }

  // ------------------ FILTER ------------------
  Future<void> setCategory(int? id) async {
    selectedCategoryId = id;
    await _refreshFilter();
    await _refreshTotals();
  }

  Future<void> _refreshFilter() async {
    if (selectedCategoryId == null) {
      _filteredExpenses = null;
      notifyListeners();
      return;
    }

    final result = await repo.getAdvancedExpenses(
      categoryId: selectedCategoryId,
    );

    if (result is Success<List<Expense>>) {
      _filteredExpenses = result.data;
    } else {
      _filteredExpenses = [];
    }

    notifyListeners();
  }

  void clearFilter() {
    selectedCategoryId = null;
    _filteredExpenses = null;
    notifyListeners();
  }

  // ------------------ SEARCH ------------------
  Future<void> search(String q) async {
    if (q.trim().isEmpty) {
      _filteredExpenses = null;
      notifyListeners();
      return;
    }

    final result = await repo.searchExpenses(q.trim());

    if (result is Success<List<Expense>>) {
      _filteredExpenses = result.data;
    } else {
      _filteredExpenses = [];
    }

    notifyListeners();
  }

  // ------------------ FORM HELPERS ------------------

  /// Call this before opening the bottom sheet for editing
  void prepareEdit(Expense expense) {
    editingExpense = expense;
    amountController.text = expense.amount.toString();
    descriptionController.text = expense.description;
    selectedDate = expense.date;
    _formCategoryId = expense.categoryId;
    notifyListeners();
  }

  void setDate(DateTime d) {
    selectedDate = d;
    notifyListeners();
  }

  /// Only updates form category — does NOT affect the list filter
  void setFormCategory(int? id) {
    _formCategoryId = id;
    notifyListeners();
  }

  void clearForm() {
    amountController.clear();
    descriptionController.clear();
    selectedDate = null;
    editingExpense = null;
    _formCategoryId = null;
    // selectedCategoryId is intentionally NOT reset here — it controls the filter
    notifyListeners();
  }

  // ------------------ VISIBLE LIST ------------------
  List<Expense> get visibleExpenses => _filteredExpenses ?? _expenses;

  // ------------------ DISPOSE ------------------
  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}