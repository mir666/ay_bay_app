import 'dart:convert';

import 'package:ay_bay_app/core/profile/models/saving_model.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavingsGoalController extends GetxController {
  final goals = <SavingsGoal>[].obs;

  static const String storageKey = "savings_goals";

  @override
  void onInit() {
    super.onInit();
    loadGoals(); // ⭐ app start হলে auto load
  }

  /// LOAD GOALS
  Future<void> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(storageKey);

    if (data != null) {
      final List decoded = jsonDecode(data);

      goals.value =
          decoded.map((e) => SavingsGoal.fromJson(e)).toList();
    }
  }

  /// SAVE GOALS
  Future<void> saveGoals() async {
    final prefs = await SharedPreferences.getInstance();

    final data =
    jsonEncode(goals.map((e) => e.toJson()).toList());

    await prefs.setString(storageKey, data);
  }

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

    saveGoals(); // ⭐ IMPORTANT
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

      saveGoals(); // ⭐ IMPORTANT
    }
  }

  void deleteGoal(String goalId) {
    goals.removeWhere((g) => g.id == goalId);

    saveGoals(); // ⭐ IMPORTANT
  }
}