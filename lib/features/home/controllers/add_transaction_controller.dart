import 'package:ay_bay_app/features/common/models/category_model.dart';
import 'package:ay_bay_app/features/common/models/transaction_type_model.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

  final incomeCategories = const [
    CategoryModel(name: 'Salary', icon: Icons.account_balance_wallet),
    CategoryModel(name: 'Gift', icon: Icons.card_giftcard),
    CategoryModel(name: 'Tuition', icon: Icons.school),
    CategoryModel(name: 'Bonuses', icon: Icons.attach_money),
    CategoryModel(name: 'Other', icon: Icons.more_horiz),
  ];

  final expenseCategories = const [
    CategoryModel(name: 'Food', icon: Icons.restaurant),
    CategoryModel(name: 'Transport', icon: Icons.directions_bus),
    CategoryModel(name: 'Shopping', icon: Icons.shopping_bag),
    CategoryModel(name: 'Electric Bill', icon: Icons.receipt_long),
    CategoryModel(name: 'Net Bill', icon: Icons.wifi),
    CategoryModel(name: 'Gas Bill', icon: Icons.gas_meter_outlined),
    CategoryModel(name: 'Bazaar', icon: Icons.shopping_cart_outlined),
    CategoryModel(name: 'Other', icon: Icons.more_horiz),
  ];

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

    final amount = double.tryParse(amountCtrl.text) ?? 0;
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
        'title': noteCtrl.text.trim(),
        'amount': amount,
        'type': type.value.name,
        'category': categoryName,
        'categoryIcon': selectedCat.icon.codePoint,
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

      // 🔥 SAFE RELOAD (NO BUG)
      await home.fetchMonthSummary(home.selectedMonthId.value);
      home.setFilter('সব');

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
