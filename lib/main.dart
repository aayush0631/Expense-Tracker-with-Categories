import 'package:expense_tracker/core/local_storage/theme_preference.dart';
import 'package:expense_tracker/core/viewmodel/theme_viewmodel.dart';
import 'package:expense_tracker/db/database/database_helper.dart';
import 'package:expense_tracker/feature/expense/viewmodel/expense_viewmodel.dart';
import 'package:expense_tracker/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routing/routes.dart';
import 'db/repository/expense_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themePref = ThemePreference();
  await themePref.checkAndSetDefault();

  final dbHelper = DatabaseHelper();

  runApp(
    MultiProvider(providers: 
      [
        ChangeNotifierProvider(create:  (_) => ExpenseViewModel( expenseRepository: ExpenseRepository(dbHelper))
          ..loadExpenses()),
        ChangeNotifierProvider(create: (_) => ThemeViewmodel()),
      ],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter News App',
      theme: context.watch<ThemeViewmodel>().isDarkMode
          ? ThemeData.dark()
          : ThemeData.light(),
      initialRoute: Routes.home,
      onGenerateRoute: (settings) => AppRouter.generateRoute(settings),
    );
  }
}