import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/budget_model.dart';

class BudgetController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  RxDouble totalBudget = 0.0.obs;
  RxList<BudgetCategory> categories = <BudgetCategory>[].obs;

  double get totalSpent => categories.fold(0, (sum, c) => sum + c.spent);
  double get remaining => totalBudget.value - totalSpent;

  @override
  void onInit() {
    super.onInit();
    fetchBudget();
  }

  Future<void> fetchBudget() async {
    try {
      final doc = await _db.collection('budgets').doc('current').get();
      if (!doc.exists) {
        totalBudget.value = 0;
        categories.value = [];
        return;
      }

      totalBudget.value = (doc['totalBudget'] ?? 0).toDouble();

      final snap = await _db
          .collection('budgets')
          .doc('current')
          .collection('categories')
          .get();

      if (snap.docs.isEmpty) {
        categories.value = [];
        return;
      }

      categories.value =
          snap.docs.map((e) => BudgetCategory.fromMap(e.data(), e.id)).toList();

      print('Categories fetched: ${categories.length}'); // debug
    } catch (e) {
      print('Error fetching budget: $e');
      totalBudget.value = 0;
      categories.value = [];
    }
  }


  Future<void> updateCategoryBudget(String id, double newBudget) async {
    await _db
        .collection('budgets')
        .doc('current')
        .collection('categories')
        .doc(id)
        .update({'budget': newBudget});

    fetchBudget();
  }
}
