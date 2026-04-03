// import 'package:expense_tracker/core/utils/result.dart';
// import 'package:expense_tracker/db/repository/expense_repository.dart';
// import 'package:expense_tracker/domain/model/category.dart';
// import 'package:expense_tracker/domain/model/expense.dart';
// import 'package:flutter/material.dart';

// class ExpenseFormViewmodel extends ChangeNotifier {
//     final ExpenseRepository repo;
//     ExpenseFormViewmodel({required this.repo});

//   List<Category> _categories = [];
//   List<Category> get categories => _categories;
//   bool isLoading = false;
//   String? errorMessage;
//   List<Expense> _expenses = [];


//     //  FORM CATEGORY 
//   // Separate from filter — used only inside the add/edit form
//   int? _formCategoryId;
//   int? get formCategoryId => _formCategoryId;
//     //  FORM 
//   final formKey = GlobalKey<FormState>();
//   final amountController = TextEditingController();
//   final descriptionController = TextEditingController();

//   DateTime? selectedDate;
//   Expense? editingExpense;


//   Future<bool> save() async {
//     if (!(formKey.currentState?.validate() ?? false)) return false;
//     if (selectedDate == null || _formCategoryId == null) return false;

//     final expense = Expense(
//       id: editingExpense?.id,
//       amount: double.parse(amountController.text.trim()),
//       description: descriptionController.text.trim(),
//       categoryId: _formCategoryId!,
//       date: selectedDate!,
//     );

//     isLoading = true;
//     notifyListeners();

//     Result result;
//     if (editingExpense == null) {
//       result = await repo.addExpense(expense);
//     } else {
//       result = await repo.updateExpense(expense);
//     }

//     if (result is Failure) {
//       errorMessage = result.message;
//       isLoading = false;
//       notifyListeners();
//       return false;
//     }

//     await loadExpenses();
//     await _refreshTotals();
//     await _refreshFilter();
//     clearForm();

//     isLoading = false;
//     notifyListeners();
//     return true;
//   }
  

//   //  EXPENSES 
//   Future<void> loadExpenses() async {
//     isLoading = true;
//     errorMessage = null;
//     notifyListeners();

//     final result = await repo.getExpenses();

//     if (result is Success<List<Expense>>) {
//       _expenses = result.data;
//       errorMessage = null;
//     } else if (result is Failure<List<Expense>>) {
//       errorMessage = result.message;
//     }

//     isLoading = false;
//     notifyListeners();
//   }
//     //  FORM HELPERS 

//   /// Call this before opening the bottom sheet for editing
//   void prepareEdit(Expense expense) {
//     editingExpense = expense;
//     amountController.text = expense.amount.toString();
//     descriptionController.text = expense.description;
//     selectedDate = expense.date;
//     _formCategoryId = expense.categoryId;
//     notifyListeners();
//   }

//   void setDate(DateTime d) {
//     selectedDate = d;
//     notifyListeners();
//   }

//   /// Only updates form category — does NOT affect the list filter
//   void setFormCategory(int? id) {
//     _formCategoryId = id;
//     notifyListeners();
//   }

//   void clearForm() {
//     amountController.clear();
//     descriptionController.clear();
//     selectedDate = null;
//     editingExpense = null;
//     _formCategoryId = null;
//     // selectedCategoryId is intentionally NOT reset here — it controls the filter
//     notifyListeners();
//   }

//   //  DISPOSE 
//   @override
//   void dispose() {
//     amountController.dispose();
//     descriptionController.dispose();
//     super.dispose();
//   }
// }
