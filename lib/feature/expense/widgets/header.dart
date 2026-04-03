import 'package:expense_tracker/feature/expense/viewmodel/expense_viewmodel.dart';
import 'package:flutter/material.dart';

/// Header widget displays the top summary section of the Expense screen.
///
/// It shows:
/// - Total expense
/// - Monthly expense
/// - Today's expense
/// - Category filter dropdown
///
/// This widget depends on [ExpenseViewModel] for data and actions.
class Header extends StatelessWidget {
  /// ViewModel that provides expense data and category filtering logic
  final ExpenseViewModel vm;

  /// Constructor requires ExpenseViewModel to render dynamic data
  const Header({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      /// Full width header
      width: double.infinity,

      /// Styled background for header section
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title section
          const Text(
            'Expense',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          /// Statistics row (Total / Monthly / Today)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Total', vm.totalAll),
              _buildStat('Monthly', vm.totalMonth),
              _buildStat('Today', vm.totalToday),
            ],
          ),

          const SizedBox(height: 16),

          /// Category filter dropdown
          DropdownButton<int?>(
            value: vm.selectedCategoryId,

            /// Dropdown styling
            dropdownColor: Colors.blueAccent,
            style: const TextStyle(color: Colors.white),
            iconEnabledColor: Colors.white,
            underline: Container(height: 1, color: Colors.white38),

            /// Dropdown items (All + categories from ViewModel)
            items: [
              /// "All categories" option
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('All', style: TextStyle(color: Colors.white)),
              ),

              /// Dynamic category list
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

            /// When user selects category
            onChanged: (value) async => vm.setCategory(value),
          ),
        ],
      ),
    );
  }

  /// Builds a single statistic column widget.
  ///
  /// [title] → label (Total / Monthly / Today)
  /// [value] → expense amount to display
  Widget _buildStat(String title, double value) {
    return Column(
      children: [
        /// Stat label
        Text(
          title,
          style: const TextStyle(color: Colors.white70),
        ),

        /// Stat value formatted in rupees
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