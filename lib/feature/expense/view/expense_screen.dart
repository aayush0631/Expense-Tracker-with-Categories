import 'package:expense_tracker/core/viewmodel/theme_viewmodel.dart';
import 'package:expense_tracker/feature/expense/view/expense_form_view.dart';
import 'package:expense_tracker/feature/expense/viewmodel/expense_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final SearchController _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseViewModel>().loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            onPressed: () {
              context.read<ThemeViewmodel>().toggleTheme();
            },
            icon: Icon(
              context.watch<ThemeViewmodel>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),

          // Search
          // SearchAnchor(
          //   searchController: _searchController,
          //   builder: (context, controller) => IconButton(
          //     onPressed: controller.openView,
          //     icon: const Icon(Icons.search),
          //   ),
          //   suggestionsBuilder: (context, controller) {
          //     final query = controller.value.text.toLowerCase();

          //     final suggestions = context.read<ExpenseViewModel>()
          //         .getFilteredExpenses(query)
          //         .map(
          //           (expense) =>
          //               ListTile(title: Text(expense.description), onTap: () {}),
          //         )
          //         .toList();

          //     return suggestions.isEmpty
          //         ? const [ListTile(title: Text('No results found'))]
          //         : suggestions;
          //   },
          // ),
        ],
      ),

      body: Consumer<ExpenseViewModel>(
        builder: (context, viewModel, child) {
          // ---------------- LOADING ----------------
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ---------------- ERROR ----------------
          if (viewModel.errorMessage != null) {
            return Center(
              child: Text(
                viewModel.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final expenses = viewModel.expenses;

          // ---------------- EMPTY STATE ----------------
          if (expenses.isEmpty) {
            return const Center(child: Text("No expenses yet"));
          }

          // ---------------- LIST ----------------
          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];

              return ListTile(
                title: Text(expense.description),
                subtitle: Text("Rs. ${expense.amount}"),
              );
            },
          );
        },
      ),

      /// FLOATING ACTION BUTTON (BOTTOM RIGHT)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return ChangeNotifierProvider.value(
                value: context.read<ExpenseViewModel>(),
                child: const ExpenseFormView(),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
