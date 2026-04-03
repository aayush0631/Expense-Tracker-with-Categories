import 'package:expense_tracker/core/viewmodel/theme_viewmodel.dart';
import 'package:expense_tracker/core/widgets/app_bottom_bar.dart';
import 'package:expense_tracker/domain/model/expense.dart';
import 'package:expense_tracker/feature/expense/view/expense_form_view.dart';
import 'package:expense_tracker/feature/expense/viewmodel/expense_viewmodel.dart';
import 'package:expense_tracker/feature/expense/widgets/header.dart';
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
            ? _SearchField(vm: provider)
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

// ---- Inline Search Field ----
class _SearchField extends StatelessWidget {
  final ExpenseViewModel vm;
  const _SearchField({required this.vm});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: vm.searchController,
      onChanged: vm.searchExpenses,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        hintText: 'Search expenses...',
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 20),
        suffixIcon: vm.isSearching
            ? IconButton(
                onPressed: vm.clearSearch,
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
              )
            : null,
      ),
    );
  }
}

// ---- ExpenseBody (unchanged from before) ----
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
                        return _ExpenseTile(expense: expenses[index]);
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

// ---- Expense Tile with swipe-to-delete and edit tap ----
class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  const _ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ExpenseViewModel>();

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Expense'),
            content: const Text(
              'Are you sure you want to delete this expense?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        final success = await vm.deleteExpense(expense.id!);
        if (!success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(vm.errorMessage ?? 'Delete failed')),
          );
        }
      },
      child: ListTile(
        onTap: () {
          vm.prepareEdit(expense);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => ChangeNotifierProvider.value(
              value: vm,
              child: const ExpenseFormView(),
            ),
          );
        },
        leading: CircleAvatar(
          // ignore: deprecated_member_use
          backgroundColor: Colors.blueAccent.withOpacity(0.15),
          child: const Icon(Icons.receipt_long, color: Colors.blueAccent),
        ),
        title: Text(
          expense.description.isEmpty
              ? '(No description)'
              : expense.description,
        ),
        subtitle: Text(
          '${vm.categoryName(expense.categoryId)}  •  '
          '${expense.date.day}/${expense.date.month}/${expense.date.year}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          'Rs ${expense.amount.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
