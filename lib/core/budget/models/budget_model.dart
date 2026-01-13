class BudgetCategory {
  final String id;
  final String name;
  final double budget;
  final double spent;

  BudgetCategory({
    required this.id,
    required this.name,
    required this.budget,
    required this.spent,
  });

  factory BudgetCategory.fromMap(Map<String, dynamic> map, String id) {
    return BudgetCategory(
      id: id,
      name: map['name'] ?? '',
      budget: (map['budget'] ?? 0).toDouble(),
      spent: (map['spent'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'budget': budget,
      'spent': spent,
    };
  }
}
