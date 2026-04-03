import 'package:expense_tracker/core/viewmodel/theme_viewmodel.dart';
import 'package:expense_tracker/core/widgets/app_bottom_bar.dart';
import 'package:expense_tracker/domain/model/expense.dart';
import 'package:expense_tracker/feature/expense/view/expense_form_view.dart';
import 'package:expense_tracker/feature/expense/viewmodel/expense_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseViewModel>();
    final pages = [
      const ExpenseBody(),
      const Center(child: Text('Stats coming soon')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Colors.blueAccent,
        actions: [
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
        onTap: provider.updateCurrentIndex,
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
            _Header(vm: vm),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text('${expenses.length}'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: expenses.isEmpty
                  ? const Center(child: Text('No expenses yet'))
                  : ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        return _ExpenseTile(expense: expenses[index]);
                      },
                    ),
            ),
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

// ---- Header ----
class _Header extends StatelessWidget {
  final ExpenseViewModel vm;
  const _Header({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Total', vm.totalAll),
              _buildStat('Monthly', vm.totalMonth),
              _buildStat('Today', vm.totalToday),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButton<int?>(
            value: vm.selectedCategoryId,
            dropdownColor: Colors.blueAccent,
            style: const TextStyle(color: Colors.white),
            iconEnabledColor: Colors.white,
            hint: const Text(
              'All Categories',
              style: TextStyle(color: Colors.white70),
            ),
            underline: Container(height: 1, color: Colors.white38),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('All', style: TextStyle(color: Colors.white)),
              ),
              ...vm.categories.map(
                (cat) => DropdownMenuItem<int?>(
                  value: cat.id,
                  child: Text(
                    cat.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
            onChanged: (value) async => vm.setCategory(value),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String title, double value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        Text(
          'Rs ${value.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
            content: const Text('Are you sure you want to delete this expense?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
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
          backgroundColor: Colors.blueAccent.withOpacity(0.15),
          child: const Icon(Icons.receipt_long, color: Colors.blueAccent),
        ),
        title: Text(
          expense.description.isEmpty ? '(No description)' : expense.description,
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