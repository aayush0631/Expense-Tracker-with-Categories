class ExpenseStat {
  final double amount;
  final DateTime date;
  final String categoryName;
  final String? categoryColor;

  ExpenseStat({
    required this.amount,
    required this.date,
    required this.categoryName,
    this.categoryColor,
  });

  factory ExpenseStat.fromMap(Map<String, dynamic> map) {
    return ExpenseStat(
      amount: (map['expense_amount'] as num).toDouble(),
      date: DateTime.parse(map['expense_date']),
      categoryName: map['category_name'] ?? 'Other',
      categoryColor: map['category_color'],
    );
  }
}