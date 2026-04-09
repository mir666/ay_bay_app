class SavingsGoal {
  String id;
  String title;
  double targetAmount;
  double savedAmount;
  DateTime createdAt;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.createdAt,
  });

  double get progress {
    if (targetAmount == 0) return 0;
    return savedAmount / targetAmount;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "targetAmount": targetAmount,
      "savedAmount": savedAmount,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json["id"],
      title: json["title"],
      targetAmount: json["targetAmount"],
      savedAmount: json["savedAmount"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}