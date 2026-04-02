import 'package:expense_tracker/feature/expense/viewmodel/expense_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/utils/validator.dart';
import 'package:expense_tracker/core/widgets/form_input_widget.dart';

class ExpenseFormView extends StatelessWidget {
  const ExpenseFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExpenseViewModel>();

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: vm.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vm.editingExpense == null ? 'Add Expense' : 'Edit Expense',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            FormInputField(
              controller: vm.amountController,
              label: 'Amount',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              validator: Validator.amount,
            ),

            const SizedBox(height: 16),

            FormInputField(
              controller: vm.descriptionController,
              label: 'Description',
              icon: Icons.description,
              validator: Validator.description,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              initialValue: vm.selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              items: vm.categories.entries
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) vm.setCategory(value);
              },
              validator: (value) =>
                  value == null ? 'Select category' : null,
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );

                if (picked != null) {
                  vm.setDate(picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(border: Border.all()),
                child: Text(
                  vm.selectedDate == null
                      ? 'Select Date'
                      : vm.selectedDate.toString(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (!vm.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fill all fields')),
                  );
                  return;
                }

                await vm.saveExpense();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(
                vm.editingExpense == null ? 'Add' : 'Update',
              ),
            ),
          ],
        ),
      ),
    );
  }
}