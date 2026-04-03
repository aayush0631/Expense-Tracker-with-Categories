import 'package:expense_tracker/feature/expense/viewmodel/expense_viewmodel.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final ExpenseViewModel vm;
  const SearchField({super.key,required this.vm});

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