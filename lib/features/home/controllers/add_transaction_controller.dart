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

  final categoriesIncome = ['Salary', 'Gift', 'Tuition'];
  final categoriesExpense = ['Food', 'Market', 'Transport'];

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

    if (uid == null) return;
    if (home.selectedMonthId.value.isEmpty) return;

    final amount = double.tryParse(amountCtrl.text);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'সঠিক এমাউন্ট দিন');
      return;
    }

    if (category.value.isEmpty) {
      Get.snackbar('Error', 'ক্যাটাগরি নির্বাচন করুন');
      return;
    }

    isLoading.value = true;

    try {
      final data = {
        'title': noteCtrl.text.trim(),
        'amount': amount,
        'type': type.value == TransactionType.income ? 'income' : 'expense',
        'category': category.value,
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

      // 🔹 ADD / EDIT
      if (editingTransactionId == null) {
        await ref.add(data);
      } else {
        await ref.doc(editingTransactionId).update(data);
      }

      // 🔥 একমাত্র কাজ → refresh month data
      await home.fetchTransactions(home.selectedMonthId.value);

      // সব দেখাবে
      home.setFilter('সব');

      clearForm();
      Get.back();

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

