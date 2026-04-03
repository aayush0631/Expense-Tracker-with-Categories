

import 'package:expense_tracker/feature/expense/viewmodel/expense_viewmodel.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final ExpenseViewModel vm;
  const Header({required this.vm});

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