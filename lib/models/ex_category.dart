//expense category class
import 'package:flutter/material.dart';

import '../constants/icons.dart';
//every expense has a category

class ExpenseCategory {
  final String title; //title of the category
  int entries = 0; //number of expenses in this category
  double totalAmount = 0.0; //total amount of expense in this category
  final IconData icon; //will define some constant icons

  //constructor
  ExpenseCategory({
    required this.title,
    required this.entries,
    required this.icon,
    required this.totalAmount,
  });

//method to convert this 'model' to a 'Map'. to be able to insert it into a database

  Map<String, dynamic> toMap() => {
        'title': title,
        'entries': entries,
        'totlaAmount': totalAmount
            .toString(), //database not able to store in double format converted to string
        //icons not going to be stored in the database
      };

//when we retrivw data from the database it will be a Map
// for the app to understand the data we need to convert it into Expense Category

  factory ExpenseCategory.fromString(Map<String, dynamic> value) =>
      ExpenseCategory(
          title: value['title'],
          entries: value['entries'],

          //it will search the 'icons' map and find the valut related to the title
          icon: icons[value['title']]!,
          totalAmount: double.parse(value['totalAmount']));
}
