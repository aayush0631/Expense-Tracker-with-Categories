class Expense {
  final int? id;
  final double amount;
  final String description;
  final int categoryId;
  final DateTime date;

  Expense({
    this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.date,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      description: map['description'] ?? '',
      categoryId: map['category_id'],
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category_id': categoryId,
      'date': date.toIso8601String(),
    };
  }
}