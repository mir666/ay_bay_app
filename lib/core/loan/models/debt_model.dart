class DebtModel {
  String id;
  String name;
  double amount;
  bool isOwe;
  bool isCleared;
  DateTime date;
  DateTime dueDate;

  DebtModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.isOwe,
    this.isCleared = false,
    required this.date,
    required this.dueDate,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? 'Unknown',
      amount: (json['amount'] ?? 0).toDouble(),
      isOwe: json['isOwe'] ?? true,
      isCleared: json['isCleared'] ?? false,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : DateTime.now().add(Duration(days: 1)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'isOwe': isOwe,
      'isCleared': isCleared,
      'date': date.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
    };
  }
}