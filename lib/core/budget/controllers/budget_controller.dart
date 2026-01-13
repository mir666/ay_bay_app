// budget_controller.dart
import 'package:ay_bay_app/core/budget/models/budget_model.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BudgetController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final HomeController homeController = Get.find<HomeController>();

  RxList<BudgetModel> budgets = <BudgetModel>[].obs;
  RxString selectedMonthId = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // ডিফল্ট মাস load
    if (homeController.months.isNotEmpty) {
      selectedMonthId.value = homeController.selectedMonthId.value.isEmpty
          ? homeController.months.first['id']
          : homeController.selectedMonthId.value;
      loadBudgets();
    }

    // মাস change হলে budget reload
    ever(selectedMonthId, (_) => loadBudgets());
  }

  void loadBudgets() async {
    if (selectedMonthId.value.isEmpty) return;
    final uid = homeController.uid;
    if (uid == null) return;

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .where('monthId', isEqualTo: selectedMonthId.value)
        .get();

    budgets.value =
        snapshot.docs.map((doc) => BudgetModel.fromMap(doc.data())).toList();
  }

  void addBudget(BudgetModel budget) async {
    final uid = homeController.uid;
    if (uid == null) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .doc(budget.id)
        .set(budget.toMap());

    budgets.add(budget);
  }

  void updateBudget(BudgetModel budget) async {
    final uid = homeController.uid;
    if (uid == null) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .doc(budget.id)
        .update(budget.toMap());

    final index = budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) budgets[index] = budget;
  }

  void deleteBudget(String id) async {
    final uid = homeController.uid;
    if (uid == null) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .doc(id)
        .delete();

    budgets.removeWhere((b) => b.id == id);
  }
}
