
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/database_provider.dart';
import 'package:provider/provider.dart';
//import '../../models/database_provider.dart';


class ExpenseSearch extends StatefulWidget {
  const ExpenseSearch({super.key});

  @override
  State<ExpenseSearch> createState() => _ExpenseSearchState();
}

class _ExpenseSearchState extends State<ExpenseSearch> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context,listen:false);
    return   TextField(
      onChanged: (value) {
        provider.searchText = value;
      },
      decoration: const InputDecoration(
        labelText: 'Search Expense',
        
      ),
    );
  }
}


















