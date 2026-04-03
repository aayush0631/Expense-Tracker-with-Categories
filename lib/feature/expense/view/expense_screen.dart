import 'package:expense_tracker/core/viewmodel/theme_viewmodel.dart';
import 'package:expense_tracker/core/widgets/app_bottom_bar.dart';
import 'package:expense_tracker/feature/expense/view/expense_form_view.dart';
import 'package:expense_tracker/feature/expense/viewmodel/expense_viewmodel.dart';
import 'package:expense_tracker/feature/expense/widgets/expense_operation_widget.dart';
import 'package:expense_tracker/feature/expense/widgets/header.dart';
import 'package:expense_tracker/feature/expense/widgets/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseViewModel>();
    final pages = [
      const ExpenseBody(),
      const Center(child: Text('comming soon'),),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        // Swap title for search field when on expense tab
        title: provider.currentIndex == 0
            ? SearchField(vm: provider)
            : const Text('Statistics'),
        actions: [
          // Theme toggle — always visible
          IconButton(
            onPressed: () => context.read<ThemeViewmodel>().toggleTheme(),
            icon: Icon(
              context.watch<ThemeViewmodel>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
        ],
      ),
      body: pages[provider.currentIndex],
      bottomNavigationBar: AppBottomBar(
        currentIndex: provider.currentIndex,
        onTap: (index) {
          // Clear search when switching tabs
          if (index != 0) provider.clearSearch();
          provider.updateCurrentIndex(index);
        },
      ),
    );
  }
}

class ExpenseBody extends StatelessWidget {
  const ExpenseBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final expenses = vm.visibleExpenses;
        return Column(
          children: [
            // Hide header when searching — no point showing filters
            if (!vm.isSearching) Header(vm: vm),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    vm.isSearching ? 'Search Results' : 'Transactions',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text('${expenses.length}'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: expenses.isEmpty
                  ? Center(
                      child: Text(
                        vm.isSearching
                            ? 'No expenses match "${vm.searchController.text}"'
                            : 'No expenses yet',
                      ),
                    )
                  : ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        return ExpenseTile(expense: expenses[index]);
                      },
                    ),
            ),
            if (!vm.isSearching)
              Padding(
                padding: const EdgeInsets.all(16),
                child: FloatingActionButton(
                  onPressed: () => _openForm(context, vm),
                  child: const Icon(Icons.add),
                ),
              ),
          ],
        );
      },
    );
  }

  void _openForm(BuildContext context, ExpenseViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: const ExpenseFormView(),
      ),
    );
  }
}
