//import 'package:expense_tracker/widgets/category_screen/expense_form.dart';
import 'package:flutter/material.dart';
import '../widgets/category_screen/category_fetcher.dart';
import '../widgets/expense_form.dart';
//import '../constants/icons.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  static const name = '/category_screen'; //for routes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Categories')),
        body: const CategoryFetcher(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const ExpenseForm());
          },
          backgroundColor: const Color.fromARGB(255, 180, 139, 1),
          foregroundColor: Colors.black,
          child: const Icon(Icons.add),
        ));
  }
}
