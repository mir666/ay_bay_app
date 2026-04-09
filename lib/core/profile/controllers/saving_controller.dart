import 'package:ay_bay_app/core/profile/models/saving_model.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class SavingsGoalController extends GetxController {
  final goals = <SavingsGoal>[].obs;

  void addGoal({
    required String title,
    required double targetAmount,
  }) {
    final goal = SavingsGoal(
      id: const Uuid().v4(),
      title: title,
      targetAmount: targetAmount,
      savedAmount: 0,
      createdAt: DateTime.now(),
    );

    goals.add(goal);
  }

  void addSavings(
      String goalId,
      double amount,
      ) {
    final index =
    goals.indexWhere((g) => g.id == goalId);

    if (index != -1) {
      goals[index].savedAmount += amount;
      goals.refresh();
    }
  }

  void deleteGoal(String goalId) {
    goals.removeWhere((g) => g.id == goalId);
  }
}