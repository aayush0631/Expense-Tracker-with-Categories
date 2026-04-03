import 'package:expense_tracker/feature/expense/viewmodel/expense_viewmodel.dart';
import 'package:expense_tracker/feature/expense/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class StatsScreen extends StatelessWidget{

  const StatsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Header(vm: vm),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'statistics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                    
                ]
              )
            )
          ]
        );
      }
    );
  }
}