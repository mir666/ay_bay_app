import 'package:ay_bay_app/core/extension/localization_extension.dart';
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
    CategoryModel(name: 'salary', iconId: 0, color: Colors.green),
    CategoryModel(name: 'gift', iconId: 1, color: Colors.blue),
    CategoryModel(name: 'tuition', iconId: 2, color: Colors.purple),
    CategoryModel(name: 'bonus', iconId: 3, color: Colors.orange),
    CategoryModel(name: 'business', iconId: 4, color: Colors.teal),
    CategoryModel(name: 'other', iconId: 5, color: Colors.grey),
  ];

  final expenseCategories = [
    CategoryModel(name: 'food', iconId: 10, color: Colors.red),
    CategoryModel(name: 'transport', iconId: 11, color: Colors.brown),
    CategoryModel(name: 'shopping', iconId: 12, color: Colors.pink),
    CategoryModel(name: 'electric_bill', iconId: 13, color: Colors.yellow),
    CategoryModel(name: 'net_bill', iconId: 14, color: Colors.indigo),
    CategoryModel(name: 'gas_bill', iconId: 15, color: Colors.cyan),
    CategoryModel(name: 'bazaar', iconId: 16, color: Colors.lime),
    CategoryModel(name: 'hospital', iconId: 17, color: Colors.deepOrange),
    CategoryModel(name: 'school', iconId: 18, color: Colors.lightBlue),
    CategoryModel(name: 'other', iconId: 5, color: Colors.grey),
  ];


  RxDouble calculatedAmount = 0.0.obs; // ক্যালকুলেটেড মান

  /// =========================
  /// Amount এর Expression Handle
  /// =========================
  void onAmountChanged(String input) {
    try {
      // math expression parse
      final exp = input
          .replaceAll('×', '*')
          .replaceAll('÷', '/'); // যদি ইউজার × ÷ use করে
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

  Future<void> saveTransaction(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final home = Get.find<HomeController>();

    if (uid == null || home.selectedMonthId.value.isEmpty) return;

    final amount = calculatedAmount.value;
    if (amount <= 0) {
      Get.snackbar(
        context.localization.error,
        context.localization.enterTheCorrectAmount,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.transparent,
        colorText: Colors.red,
        barBlur: 0,
        titleText: Text(
          context.localization.error,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red,
            fontSize: 16,
          ),
        ),
        messageText: Text(
          context.localization.enterTheCorrectAmount,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: TextStyle(
            fontWeight: FontWeight.w600, // বোল্ড
            color: Colors.red,           // টেক্স কালার
            fontSize: 16,
          ),
        ),
      );
      return;
    }

    isLoading.value = true;

    final selectedCat = selectedCategory.value;

    if (selectedCat == null) {
      Get.snackbar(
        context.localization.error,
        context.localization.selectACategory,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.transparent,
        colorText: Colors.red,
        barBlur: 0,
        titleText: Text(
          context.localization.error,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red,
            fontSize: 16,
          ),
        ),
        messageText: Text(
          context.localization.selectACategory,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: TextStyle(
            fontWeight: FontWeight.w600, // বোল্ড
            color: Colors.red,           // টেক্স কালার
            fontSize: 16,
          ),
        ),
      );
      isLoading.value = false;
      return;
    }

    final categoryName = selectedCat.name == 'Other'
        ? otherCategoryCtrl.text.trim()
        : selectedCat.name;

    if (categoryName.isEmpty) {
      Get.snackbar(
        context.localization.error,
        context.localization.writeACategoryName,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.transparent,
        colorText: Colors.red,
        barBlur: 0,
        titleText: Text(
          context.localization.error,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red,
            fontSize: 16,
          ),
        ),
        messageText: Text(
          context.localization.writeACategoryName,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: TextStyle(
            fontWeight: FontWeight.w600, // বোল্ড
            color: Colors.red,           // টেক্স কালার
            fontSize: 16,
          ),
        ),
      );
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
            .update({'totalBalance': home.totalBalance.value});
      }

      // 🔥 SAFE RELOAD (NO BUG)
      await home.fetchMonthSummary(home.selectedMonthId.value);
      home.setFilter('সব');

      Get.back();
      clearForm();
      Get.snackbar(
        context.localization.success,
        context.localization.successfullyAddYourTransaction,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.transparent,
        colorText: Colors.green,
        barBlur: 0,
        titleText: Text(
          context.localization.success,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.green,
            fontSize: 16,
          ),
        ),
        messageText: Text(
          context.localization.successfullyAddYourTransaction,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: TextStyle(
            fontWeight: FontWeight.w600, // বোল্ড
            color: Colors.green,           // টেক্স কালার
            fontSize: 16,
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(
        context.localization.error,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.red,
        backgroundColor: Colors.transparent,
        barBlur: 0,
        titleText: Text(
          context.localization.error,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red,
            fontSize: 16,
          ),
        ),
      );
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