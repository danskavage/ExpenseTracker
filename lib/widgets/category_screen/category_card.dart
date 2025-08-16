import 'package:flutter/material.dart';
import '../../models/ex_category.dart';
import '../../screens/expense_screen.dart';
import 'package:intl/intl.dart';
class Categorycard extends StatelessWidget {
  final ExpenseCategory category;
  const Categorycard(this.category,{super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
            onTap: (){
              Navigator.of(context).pushNamed(
                ExpenseScreen.name,
                arguments: category.title, //for expense screen
              );
            },
            leading: Icon(category.icon),
            title: Text(category.title),
            subtitle: Text('entries: ${category.entries}'),
            trailing: Text(NumberFormat.currency(locale:'en_IN',symbol: 'Ksh').format(category.totalAmount)),
            //trailing: Text(NumberFormat.currency(locale:'en_IN',symbol: 'Ksh').format(exp.amount)),
          );
  }
}