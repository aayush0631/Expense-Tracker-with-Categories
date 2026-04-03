import 'package:expense_tracker/core/widgets/conformation_dialogue_widget.dart';
import 'package:expense_tracker/domain/model/expense.dart';
import 'package:expense_tracker/feature/expense/view/expense_form_view.dart';
import 'package:expense_tracker/feature/expense/viewmodel/expense_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  const ExpenseTile({super.key, required this.expense});

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

      confirmDismiss: (_) => conformationDialog(
        context: context,
        title: 'Delete Expense',
        content: 'Are you sure you want to delete this expense?',
        confirmText: 'Delete',
      ),

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
          backgroundColor: Colors.blueAccent.withValues(alpha: 0.15),
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