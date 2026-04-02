import 'package:expense_tracker/core/utils/error_handler.dart';
import 'package:expense_tracker/domain/model/expense.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/db/repository/expense_repository.dart';

class ExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository expenseRepository;

  ExpenseViewModel({required this.expenseRepository});

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  DateTime? selectedDate;
  int? selectedCategoryId;

  final Map<int, String> categories = {
    1: 'Food',
    2: 'Transport',
    3: 'Shopping',
    4: 'Bills',
    5: 'Other',
  };

  Expense? editingExpense;

  Future<void> loadExpenses() async {
    try {
      isLoading = true;
      errorMessage = null;

      _expenses = await expenseRepository.getExpenses();
    } catch (e) {
      errorMessage = ErrorHandler.getMessage(e);
      _expenses = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- EDIT EXPENSE ----------------
  void setEditingExpense(Expense? expense) {
    editingExpense = expense;

    if (expense != null) {
      amountController.text = expense.amount.toString();
      descriptionController.text = expense.description;
      selectedCategoryId = expense.categoryId;
      selectedDate = expense.date;
    }

    notifyListeners();
  }

  // ---------------- SETTERS ----------------
  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void setCategory(int id) {
    selectedCategoryId = id;
    notifyListeners();
  }

  // ---------------- VALIDATION ----------------
  bool validate() {
    return formKey.currentState!.validate() &&
        selectedDate != null &&
        selectedCategoryId != null;
  }

  // ---------------- BUILD MODEL ----------------
  Expense buildExpense() {
    return Expense(
      id: editingExpense?.id,
      amount: double.parse(amountController.text),
      description: descriptionController.text.trim(),
      categoryId: selectedCategoryId!,
      date: selectedDate!,
    );
  }

  // ---------------- SAVE EXPENSE ----------------
  Future<void> saveExpense() async {
    if (!validate()) return;

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final expense = buildExpense();

      if (editingExpense == null) {
        await expenseRepository.addExpense(expense);
      } else {
        await expenseRepository.updateExpense(expense);
      }

      await loadExpenses(); // 🔥 important: sync with DB (best practice)

    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- DISPOSE ----------------
  void disposeForm() {
    amountController.dispose();
    descriptionController.dispose();
  }
}