import 'package:ay_bay_app/core/budget/controllers/budget_controller.dart';
import 'package:ay_bay_app/features/common/models/category_model.dart';
import 'package:ay_bay_app/features/common/models/transaction_type_model.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

class AddTransactionController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  String? editingTransactionId;

  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();

  Rx<TransactionType> type = TransactionType.expense.obs;
  RxString category = ''.obs;
  RxBool isMonthly = false.obs;
  RxBool isLoading = false.obs;

  final selectedDate = DateTime.now().obs;

  Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);

  final otherCategoryCtrl = TextEditingController();

  final incomeCategories = [
    CategoryModel(name: 'Salary', iconId: 0),
    CategoryModel(name: 'Gift', iconId: 1),
    CategoryModel(name: 'Tuition', iconId: 2),
    CategoryModel(name: 'Bonuses', iconId: 3),
    CategoryModel(name: 'Business income', iconId: 4),
    CategoryModel(name: 'Other', iconId: 5),
  ];

  final expenseCategories = [
    CategoryModel(name: 'Food', iconId: 10),
    CategoryModel(name: 'Transport', iconId: 11),
    CategoryModel(name: 'Shopping', iconId: 12),
    CategoryModel(name: 'Electric Bill', iconId: 13),
    CategoryModel(name: 'Net Bill', iconId: 14),
    CategoryModel(name: 'Gas Bill', iconId: 15),
    CategoryModel(name: 'Bazaar', iconId: 16),
    CategoryModel(name: 'Hospital', iconId: 17),
    CategoryModel(name: 'School', iconId: 18),
    CategoryModel(name: 'Other', iconId: 5),
  ];


  RxDouble calculatedAmount = 0.0.obs; // ক্যালকুলেটেড মান

  /// =========================
  /// Amount এর Expression Handle
  /// =========================
  void onAmountChanged(String input) {
    try {
      // math expression parse
      final exp = input.replaceAll('×', '*').replaceAll('÷', '/'); // যদি ইউজার × ÷ use করে
      ExpressionParser p = GrammarParser();
      Expression expression = p.parse(exp);
      double eval = expression.evaluate(EvaluationType.REAL, ContextModel());

      calculatedAmount.value = eval;
    } catch (e) {
      calculatedAmount.value = 0; // যদি invalid input হয়
    }
  }

  // =========================
  // 🔹 Helpers
  // =========================

  String get formattedDate =>
      DateFormat('dd MMM yyyy').format(selectedDate.value);

  void pickDate(DateTime date) {
    selectedDate.value = date;
  }

  void clearForm() {
    amountCtrl.clear();
    noteCtrl.clear();
    category.value = '';
    selectedDate.value = DateTime.now();
    type.value = TransactionType.expense;
    isMonthly.value = false;
    editingTransactionId = null;
  }

  // =========================
  // 🔹 Save Transaction
  // =========================

  Future<void> saveTransaction() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final home = Get.find<HomeController>();

    if (uid == null || home.selectedMonthId.value.isEmpty) return;

    final amount = calculatedAmount.value;
    if (amount <= 0) {
      Get.snackbar('Error', 'সঠিক এমাউন্ট দিন');
      return;
    }

    isLoading.value = true;

    final selectedCat = selectedCategory.value;

    if (selectedCat == null) {
      Get.snackbar('Error', 'একটি ক্যাটাগরি নির্বাচন করুন');
      isLoading.value = false;
      return;
    }

    final categoryName = selectedCat.name == 'Other'
        ? otherCategoryCtrl.text.trim()
        : selectedCat.name;

    if (categoryName.isEmpty) {
      Get.snackbar('Error', 'ক্যাটাগরির নাম লিখুন');
      isLoading.value = false;
      return;
    }


    try {
      final data = {
        'amount': amount.toInt(),
        'type': type.value.name,
        'category': categoryName,
        'categoryIcon': selectedCat.iconId,
        'date': Timestamp.fromDate(selectedDate.value),
        'isMonthly': isMonthly.value,
        'createdAt': Timestamp.now(),
      };

      final ref = _db
          .collection('users')
          .doc(uid)
          .collection('months')
          .doc(home.selectedMonthId.value)
          .collection('transactions');

      if (editingTransactionId == null) {
        await ref.add(data);
      } else {
        await ref.doc(editingTransactionId).update(data);
      }

      // 🔥 Income হলে মোট বাজেট বাড়াও
      if (type.value == TransactionType.income &&
          editingTransactionId == null) {
        home.totalBalance.value += amount;

        await _db
            .collection('users')
            .doc(uid)
            .collection('months')
            .doc(home.selectedMonthId.value)
            .update({
          'totalBalance': home.totalBalance.value,
        });
      }


      // 🔥 SAFE RELOAD (NO BUG)
      await home.fetchMonthSummary(home.selectedMonthId.value);
      home.setFilter('সব');
      // 🔹 Update budget spent after adding transaction
      // 🔹 Save transaction শেষে budget update
      final budgetController = Get.find<BudgetController>();
      budgetController.updateSpentForBudgets(home.selectedMonthId.value);


      Get.back();
      clearForm();
      Get.snackbar('Success', 'লেনদেন সফলভাবে যোগ হয়েছে');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }

  }


  @override
  void onClose() {
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }
}
