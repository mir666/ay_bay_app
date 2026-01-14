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

    // যেই মুহূর্তে মাস select হবে, budget reload হবে
    ever(homeController.selectedMonthId, (monthId) {
      if (homeController.uid != null && monthId.isNotEmpty) {
        selectedMonthId.value = monthId;
        loadBudgets();
      }
    });
  }

  /// 🔹 Load Budgets from Firestore
  void loadBudgets() async {
    if (selectedMonthId.value.isEmpty) return;
    final uid = homeController.uid;
    if (uid == null) return;

    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .where('monthId', isEqualTo: selectedMonthId.value)
          .get();

      budgets.value = snapshot.docs
          .map((doc) => BudgetModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error loading budgets: $e');
      Get.snackbar('Error', 'বাজেট লোড করতে সমস্যা হয়েছে');
    }
  }

  /// 🔹 Add or Update Budget
  void saveBudget(BudgetModel budget) async {
    final uid = homeController.uid;
    if (uid == null || budget.monthId.isEmpty) {
      Get.snackbar('Error', 'মাস বা ইউজার পাওয়া যায়নি');
      return;
    }

    try {
      final monthRef = _db.collection('users').doc(uid).collection('months').doc(budget.monthId);

      // ✅ যদি budget নতুন হয়
      final isNew = !budgets.any((b) => b.id == budget.id);

      await _db
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .doc(budget.id)
          .set(budget.toMap());

      // 🔹 Budget নতুন হলে totalBalance update
      if (isNew) {
        final monthSnap = await monthRef.get();
        double currentTotal = (monthSnap['totalBalance'] ?? 0).toDouble();
        currentTotal += budget.amount; // budget add
        await monthRef.update({'totalBalance': currentTotal});

        // 🔹 UI update
        homeController.totalBalance.value = currentTotal;
        homeController.balance.value = currentTotal - homeController.expense.value;
      } else {
        // Update হলে old amount হিসাব থেকে বাদ দিতে পারো (optional)
        final oldBudget = budgets.firstWhere((b) => b.id == budget.id);
        final diff = budget.amount - oldBudget.amount;

        if (diff != 0) {
          final monthSnap = await monthRef.get();
          double currentTotal = (monthSnap['totalBalance'] ?? 0).toDouble();
          currentTotal += diff;
          await monthRef.update({'totalBalance': currentTotal});

          // 🔹 UI update
          homeController.totalBalance.value = currentTotal;
          homeController.balance.value = currentTotal - homeController.expense.value;
        }
      }

      // Firestore থেকে আবার load করে UI update
      loadBudgets();
    } catch (e) {
      print('Error saving budget: $e');
      Get.snackbar('Error', 'বাজেট সেভ করতে সমস্যা হয়েছে');
    }
  }

  /// 🔹 Update spent for each budget
  void updateSpentForBudgets(String monthId) async {
    final uid = homeController.uid;
    if (uid == null) return;

    for (var budget in budgets) {
      // ঐ মাসের ট্রানজ্যাকশন লোড
      final trxSnap = await _db
          .collection('users')
          .doc(uid)
          .collection('months')
          .doc(monthId)
          .collection('transactions')
          .where('category', isEqualTo: budget.category) // একই ক্যাটাগরি ফিল্টার
          .get();

      double spentAmount = 0;
      for (var trx in trxSnap.docs) {
        if (trx['type'] == 'expense') {
          spentAmount += (trx['amount'] ?? 0).toDouble();
        }
      }

      // budget.update spent
      budget.spent = spentAmount;

      // Optional: Firestore-এ save করতে চাওলে uncomment করো
      // await _db.collection('users').doc(uid).collection('budgets').doc(budget.id).update({
      //   'spent': spentAmount,
      // });
    }

    // UI Refresh
    budgets.refresh();
  }




  /// 🔹 Delete Budget
  void deleteBudget(String id) async {
    final uid = homeController.uid;
    if (uid == null) return;

    try {
      final budget = budgets.firstWhere((b) => b.id == id);
      final monthRef = _db.collection('users').doc(uid).collection('months').doc(budget.monthId);

      await _db
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .doc(id)
          .delete();

      // 🔹 totalBalance থেকে budget.amount বাদ
      final monthSnap = await monthRef.get();
      double currentTotal = (monthSnap['totalBalance'] ?? 0).toDouble();
      currentTotal -= budget.amount;
      await monthRef.update({'totalBalance': currentTotal});

      // 🔹 UI update
      homeController.totalBalance.value = currentTotal;
      homeController.balance.value = currentTotal - homeController.expense.value;

      budgets.removeWhere((b) => b.id == id);
    } catch (e) {
      print('Error deleting budget: $e');
      Get.snackbar('Error', 'বাজেট ডিলিট করতে সমস্যা হয়েছে');
    }
  }

}
