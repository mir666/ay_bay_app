class BudgetModel {
  String id;
  String category;
  double amount;
  double spent;
  String monthId;

  BudgetModel({
    required this.id,
    required this.category,
    required this.amount,
    this.spent = 0.0,
    required this.monthId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'spent': spent,
      'monthId': monthId,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      category: map['category'],
      amount: map['amount'],
      spent: map['spent'] ?? 0.0,
      monthId: map['monthId'],
    );
  }
}
