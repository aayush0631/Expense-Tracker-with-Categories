import 'package:expense_tracker/core/viewmodel/theme_viewmodel.dart';
import 'package:expense_tracker/db/database/database_helper.dart';
import 'package:expense_tracker/db/repository/expense_repository.dart';
import 'package:expense_tracker/feature/expense/viewmodel/expense_viewmodel.dart';
import 'package:expense_tracker/routing/router.dart';
import 'package:expense_tracker/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  final repo = ExpenseRepository(dbHelper);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExpenseViewModel(repo: repo)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeViewmodel()..loadTheme(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: context.watch<ThemeViewmodel>().isDarkMode
          ? ThemeData.dark()
          : ThemeData.light(),
      initialRoute: Routes.home,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}