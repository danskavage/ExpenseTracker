class Expense{
  final int id; //unique if for every expense
  final String title; //what we are spending on
  final double amount; //how much we have spent
  final DateTime date; //date spent

  final String category; //category of the thing we spendng on


  //constractor
  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,

  });

  //Expense to 'map
  Map<String,dynamic> toMap() => {
    //id will generate automatically
    'title' : title,
    'amount': amount.toString(),
    'date': date.toString(),
    'category': category,
  };

  // 'Map' to 'Expense'
  factory Expense.fromString(Map<String,dynamic>value) => Expense(id:value['id'],title: value['title'],
  amount: double.parse(value['amount']),date: DateTime.parse(value['date']),category: value['category']);
}