//import 'package:expense_tracker/models/ex_category.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/icons.dart';
import './ex_category.dart';
import './expense.dart';

class DatabaseProvider with ChangeNotifier {
  String _searchText = '';
  String get searchText => _searchText;
  set searchText(String value) {
    _searchText = value;
    notifyListeners();
    //when the value of the search text changes it will notify the widget
  }

  //in-app memory for holding the expense categories temporary
  List<ExpenseCategory> _categories = [];
  List<ExpenseCategory> get categories => _categories;

  List<Expense> _expense = [];
  //when the search text is empty return the whole list else return the value
  List<Expense> get expenses {
    return _searchText != ''
        ? _expense
            .where((e) =>
                e.title.toLowerCase().contains(_searchText.toLowerCase()))
            .toList()
        : _expense;
  }

  Database? _database;

  Future<Database> get database async {
    //database directory
    final dbDirectory = await getDatabasesPath();
    //database name

    const dbName = 'expense_tc.db';

    //full path
    final path = join(dbDirectory, dbName);

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb, //will create this separately
    );

    return _database!;
  }

  //_createDb function
  static const cTable = 'categoryTable';
  static const eTable = 'expenseTable';
  Future<void> _createDb(Database db, int version) async {
    //this method runs only once. when the database is being created
    // so create the table here and if you want to insert some initial values
    //insert in this function

    await db.transaction((txn) async {
      //category table
      await txn.execute('''CREATE TABLE $cTable(
        title TEXT,
        entries INTEGER,
        totalAmount TEXT
      )''');

      //expense table

      await txn.execute('''CREATE TABLE $eTable(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      amount TEXT,
      date TEXT,
      category TEXT
      
      )''');

      //insert the initial categories
      // this will add the categories to category table and initialize the 'entries' with 0 and totalAmount to 0.0
      for (int i = 0; i < icons.length; i++) {
        await txn.insert(cTable, {
          'title': icons.keys.toList()[i],
          'entries': 0,
          'totalAmount': (0.0).toString(),
        });
      }
    });
  }

  //method to fetch categories

  Future<List<ExpenseCategory>> fetchCategories() async {
    //get the database

    final db = await database;
    return db.transaction((txn) {
      return txn.query(cTable).then((data) {
        //data is our fetched value
        //conver it from 'map<String,object> to 'Map<String,dynamic>
        final converted = List<Map<String, dynamic>>.from(data);
        //create a 'Expensecategory' from every 'map' in this 'converted'
        List<ExpenseCategory> nList = List.generate(converted.length,
            (index) => ExpenseCategory.fromString(converted[index]));

        _categories = nList;
        //return the categories
        return _categories;
      });
    });
  }

  Future<void> updateCategory(
    String category,
    int nEntries,
    double nTotalAmount,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .update(
        cTable, //category table
        {
          'entries': nEntries, //new value of 'entries
          'totalAmount': nTotalAmount.toString(), //new value of 'totalAmount'
        },
        where: 'title ==?',
        whereArgs: [category],
      )
          .then((_) {
        //ISSUE
        //after updating in database update it in the in-app memory
        var file =
            _categories.firstWhere((element) => element.title == category);
        file.entries = nEntries;
        file.totalAmount = nTotalAmount;
        notifyListeners();
      });
    });
  }
  //method to add expense to database

  Future<void> addExpense(Expense exp) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .insert(
        eTable,
        exp.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      )
          .then((generatedId) {
        // after inserting in the database we store it in in-app memory with new expense with generated id
        final file = Expense(
            id: generatedId,
            title: exp.title,
            amount: exp.amount,
            date: exp.date,
            category: exp.category);

        //add it to '_expenses
        _expense.add(file);
        //notify the listener about the change in '_expenses
        notifyListeners();

        //after inserted the expense, we need to update the entries and 'totalAmount' of the related 'category'
        var ex = findCategory(exp.category);
        //var data = calculateEntriesAndAmount(exp.category);
        updateCategory(
            exp.category, ex.entries + 1, ex.totalAmount + exp.amount);
      });
    });
  }

  Future<void> deleteExpense(int expId, String category, double amount) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(eTable, where: 'id ==?', whereArgs: [expId]).then((_) {
        //remove from the in-app memoery too
        _expense.removeWhere((element) => element.id == expId);
        notifyListeners();
        //we have to update the entries and totalAmount
        var ex = findCategory(category);
        updateCategory(category, ex.entries - 1, ex.totalAmount - amount);
      });
    });
  }

  Future<List<Expense>> fetchExpenses(String category) async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(eTable,
          where: 'category == ?', whereArgs: [category]).then((data) {
        final converted = List<Map<String, dynamic>>.from(data);

        List<Expense> nList = List.generate(
            converted.length, (index) => Expense.fromString(converted[index]));
        _expense = nList;
        return _expense;
      });
    });
  }

  Future<List<Expense>> fetchAllExpenses() async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(eTable).then((data) {
        final converted = List<Map<String, dynamic>>.from(data);
        List<Expense> nList = List.generate(
            converted.length, (index) => Expense.fromString(converted[index]));
        _expense = nList;
        return _expense;
      });
    });
  }

  ExpenseCategory findCategory(String title) {
    return _categories.firstWhere((element) => element.title == title);
  }

  Map<String, dynamic> calculateEntriesAndAmount(String category) {
    double total = 0.0;
    var list = _expense.where((element) => element.category == category);
    for (final i in list) {
      total += i.amount;
    }

    return {'entries': list.length, 'totalAmount': total};
  }

  double calculateTotalExpenses() {
    return _categories.fold(
        0.0, (previousValue, element) => previousValue + element.totalAmount);
  }

  List<Map<String, dynamic>> calculateWeekExpense() {
    List<Map<String, dynamic>> data = [];
    // need 7 entries
    for (int i = 0; i < 7; i++) {
      //1 total of eache entry
      double total = 0.0;

      //substract i from today to get previuos dates
      final weekDay = DateTime.now().subtract(Duration(days: i));

      //check how many transactions happened that day

      for (int j = 0; j < _expense.length; j++) {
        if (_expense[j].date.year == weekDay.year &&
            _expense[j].date.month == weekDay.month &&
            _expense[j].date.day == weekDay.day) {
          //if found then add the amount to total
          total += _expense[j].amount;
        }
      }

      //add to list
      data.add({'day': weekDay, 'amount': total});
    }
    return data;
  }
}
