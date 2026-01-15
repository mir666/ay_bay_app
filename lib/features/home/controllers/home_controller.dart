import 'dart:async';
import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/features/auth/ui/screens/log_in_screen.dart';
import 'package:ay_bay_app/features/common/models/transaction_type_model.dart';
import 'package:ay_bay_app/features/home/ui/screens/add_transaction_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _storage = GetStorage();

  /// UI State
  RxList<TransactionModel> allTransactions = <TransactionModel>[].obs;
  RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final monthSuggestions = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> months = <Map<String, dynamic>>[].obs;
  RxList<TransactionModel> globalTransactions = <TransactionModel>[].obs;

  /// Dashboard
  RxDouble income = 0.0.obs;
  RxDouble expense = 0.0.obs;
  RxDouble balance = 0.0.obs;
  RxDouble totalBalance = 0.0.obs;
  RxString filterCategory = 'সব'.obs;
  final RxString selectedMonth = ''.obs;
  RxString selectedMonthId = ''.obs;
  RxBool canAddTransaction = false.obs;
  Rx<DateTime> todayDate = DateTime.now().obs;
  RxBool isMonthDropdownOpen = false.obs;

  String? get uid => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    initCurrentMonth();
    _listenMonths();
    _loadState();
    fetchGlobalTransactions();
    Timer.periodic(const Duration(minutes: 1), (_) {
      todayDate.value = DateTime.now();
    });
  }

  // 🔍 Search & Suggestions
  final isSearching = false.obs;
  final searchText = ''.obs;
  final suggestions = <TransactionModel>[].obs;

  // 🔹 Load last session
  void _loadState() {
    selectedMonthId.value = _storage.read('selectedMonthId') ?? '';
    selectedMonth.value = _storage.read('selectedMonth') ?? '';
    filterCategory.value = _storage.read('filterCategory') ?? 'সব';
  }

  // 🔹 Save current session
  void _saveState() {
    _storage.write('selectedMonthId', selectedMonthId.value);
    _storage.write('selectedMonth', selectedMonth.value);
    _storage.write('filterCategory', filterCategory.value);
  }

  void saveLastScreen(String routeName) {
    _storage.write('lastScreen', routeName);
  }

  void searchTransaction(String query) {
    searchText.value = query;
    isSearching.value = query.isNotEmpty;

    if (query.isEmpty) {
      transactions.value = allTransactions;
      suggestions.clear();
      monthSuggestions.clear();
      return;
    }

    final q = query.toLowerCase();

    // 🔹 Global Transaction Search (Title, Category, Month, Date)
    final trxMatches = globalTransactions.where((trx) {
      final titleMatch = trx.title.toLowerCase().contains(q);
      final categoryMatch = trx.category.toLowerCase().contains(q);
      final monthMatch = trx.monthName.toLowerCase().contains(q);

      // Date match (format: dd MMM yyyy)
      final dateStr = DateFormat('dd MMM yyyy').format(trx.date).toLowerCase();
      final dateMatch = dateStr.contains(q);

      return titleMatch || categoryMatch || monthMatch || dateMatch;
    }).toList();

    suggestions.value = trxMatches.take(5).toList();
    transactions.value = trxMatches;

    // 🔹 Month Suggestions
    monthSuggestions.value = months
        .where((m) => m['month'].toString().toLowerCase().contains(q))
        .take(5)
        .toList();
  }

  void selectSuggestion(TransactionModel trx) async {
    searchText.value = trx.title;

    selectedMonth.value = trx.monthName;
    selectedMonthId.value = trx.monthId;

    await fetchTransactions(trx.monthId);

    transactions.value = [trx]; // শুধু ঐ লেনদেন দেখাবে
    suggestions.clear();
    monthSuggestions.clear();
    isSearching.value = false;
  }

  void selectMonthFromSearch(Map<String, dynamic> month) async {
    selectedMonth.value = month['month'];
    selectedMonthId.value = month['id'];

    await fetchTransactions(month['id']);

    closeSearch();
  }

  Future<void> fetchGlobalTransactions() async {
    if (uid == null) return;

    final monthSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .get();

    List<TransactionModel> temp = [];

    for (final month in monthSnap.docs) {
      final trxSnap = await month.reference.collection('transactions').get();

      for (final trx in trxSnap.docs) {
        temp.add(
          TransactionModel.fromJson(
            trx.id,
            trx.data(),
          ).copyWith(monthId: month.id, monthName: month['month']),
        );
      }
    }

    globalTransactions.value = temp;
  }

  void closeSearch() {
    isSearching.value = false;
    searchText.value = '';
    suggestions.clear();
    monthSuggestions.clear();
    transactions.value = allTransactions; // selected month restore
  }

  /// মাস সিলেক্ট করার মেথড
  void selectMonth(Map<String, dynamic> month) {
    selectedMonth.value = month['month'];
    selectedMonthId.value = month['id'];
    totalBalance.value = (month['totalBalance'] ?? 0).toDouble();

    // সিলেক্ট করা মাসের ট্রানজ্যাকশন লোড
    fetchTransactions(month['id']);
    _saveState();
    filterCategory.value = 'সব';
    // মাসিক লিস্ট থেকে select করলে filter সব থাকবে
    setFilter('সব');
  }

  /// ✅ Filter Logic (MODEL BASED)
  List<TransactionModel> _applyFilter(List<TransactionModel> data) {
    if (filterCategory.value == 'সব') return data;

    if (filterCategory.value == 'আয়') {
      return data.where((e) => e.type == TransactionType.income).toList();
    }

    if (filterCategory.value == 'ব্যয়') {
      return data.where((e) => e.type == TransactionType.expense).toList();
    }

    return data;
  }

  /// 🔄 Change Filter
  void setFilter(String value) {
    filterCategory.value = value;
    transactions.value = _applyFilter(allTransactions);
    _saveState();
  }

  /// 💰 Dashboard Calculation (MODEL BASED)
  void _calculateDashboard(List<TransactionModel> data) {
    double inc = 0;
    double exp = 0;

    for (final trx in data) {
      if (trx.type == TransactionType.income) {
        inc += trx.amount;
      } else {
        exp += trx.amount;
      }
    }

    // শুধু দেখানোর জন্য
    income.value = inc;
    expense.value = exp;

    // 🔥 আসল ব্যালেন্স লজিক
    balance.value = totalBalance.value - exp;
  }

  /// 📅 Month Listener
  void _listenMonths() {
    if (uid == null) return;

    _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .orderBy('monthKey', descending: true)
        .snapshots()
        .listen((snapshot) {
          months.value = snapshot.docs
              .map((e) => {'id': e.id, ...e.data()})
              .toList();
        });
  }

  Future<void> fetchTransactions(String monthId) async {
    if (uid == null) return;

    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .doc(monthId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    final data = snap.docs
        .map((e) => TransactionModel.fromJson(e.id, e.data()))
        .toList();

    allTransactions.value = data;
    transactions.value = _applyFilter(data);
    _calculateDashboard(data);
  }

  Future<void> fetchMonthSummary(String monthId) async {
    final txSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .doc(monthId)
        .collection('transactions')
        .get();

    double inc = 0;
    double exp = 0;

    for (var d in txSnap.docs) {
      final amt = (d['amount'] ?? 0).toDouble();
      if (d['type'] == 'income') {
        inc += amt;
      } else {
        exp += amt;
      }
    }

    final monthSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .doc(monthId)
        .get();

    income.value = inc;
    expense.value = exp;
    totalBalance.value = (monthSnap['totalBalance'] ?? 0).toDouble();
    balance.value = totalBalance.value - expense.value;

    fetchTransactions(monthId);
  }

  Future<void> addMonth({
    required DateTime monthDate,
    required double openingBalance,
  }) async {
    if (uid == null) return;

    final monthKey = DateFormat('yyyy-MM').format(monthDate);
    final monthName = DateFormat('MMMM yyyy').format(monthDate);

    try {
      // 🔴 SAME MONTH CHECK
      final existing = await _db
          .collection('users')
          .doc(uid)
          .collection('months')
          .where('monthKey', isEqualTo: monthKey)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        Get.snackbar(
          'Already Exists',
          'এই মাসের হিসাব ইতিমধ্যে খোলা আছে',
          colorText: Colors.red,
          backgroundColor: Colors.transparent,
        );
        return;
      }
      // 🔹 Deactivate previous month
      final previous = await _db
          .collection('users')
          .doc(uid)
          .collection('months')
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in previous.docs) {
        await doc.reference.update({'isActive': false});
      }

      // 🔹 Add new month
      final docRef = await _db
          .collection('users')
          .doc(uid)
          .collection('months')
          .add({
            'month': monthName,
            'monthKey': monthKey,
            'opening': openingBalance,
            'totalBalance': openingBalance,
            'createdAt': Timestamp.now(),
            'isActive': true,
          });

      // UI Update
      selectedMonth.value = monthName;
      selectedMonthId.value = docRef.id;
      totalBalance.value = openingBalance;
      balance.value = openingBalance;
      canAddTransaction.value = true;
      totalBalance.value = openingBalance;
      balance.value = openingBalance;

      income.value = 0;
      expense.value = 0;

      allTransactions.clear();
      transactions.clear();

      canAddTransaction.value = true;

      Get.offAllNamed(AppRoutes.home);

      Get.snackbar('Success', 'নতুন মাস যোগ হয়েছে', colorText: Colors.green);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> createNewMonth({
    required DateTime monthDate,
    required double openingBalance,
  }) async {
    final monthKey = DateFormat('yyyy-MM').format(monthDate);

    // ❌ same month block
    final exists = await _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .where('monthKey', isEqualTo: monthKey)
        .limit(1)
        .get();

    if (exists.docs.isNotEmpty) {
      Get.snackbar(
        'Error',
        'এই মাসের হিসাব আগেই খোলা আছে',
        colorText: Colors.red,
      );
      return;
    }

    // deactivate old month
    final active = await _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .where('isActive', isEqualTo: true)
        .get();

    for (var doc in active.docs) {
      await doc.reference.update({'isActive': false});
    }

    // create new
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .add({
          'monthKey': monthKey,
          'opening': openingBalance,
          'totalBalance': openingBalance,
          'income': 0,
          'expense': 0,
          'createdAt': Timestamp.now(),
          'isActive': true,
        });

    // UI update
    selectedMonthId.value = doc.id;
    totalBalance.value = openingBalance;
    income.value = 0;
    expense.value = 0;
    balance.value = openingBalance;

    Get.back();
  }

  Future<void> updateCurrentMonthBudget(double amount) async {
    final monthId = selectedMonthId.value;
    if (monthId.isEmpty) return;

    // 🔹 DB update
    await _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .doc(monthId)
        .update({'totalBalance': amount});

    // 🔹 UI update
    totalBalance.value = amount;

    // ✅ ব্যালেন্স = মোট বাজেট - মোট ব্যয়
    balance.value = totalBalance.value - expense.value;

    Get.back();
    Get.snackbar('Success', 'মোট বাজেট আপডেট হয়েছে', colorText: Colors.green);
  }

  /// 🗑️ Delete Month
  Future<void> deleteMonth(String monthId, String monthName) async {
    if (uid == null) return;

    try {
      final monthRef = _db
          .collection('users')
          .doc(uid)
          .collection('months')
          .doc(monthId);

      // 🔹 1️⃣ মাসের সব ট্রানজ্যাকশন ডিলিট
      final trxSnapshot = await monthRef.collection('transactions').get();
      for (var doc in trxSnapshot.docs) {
        await doc.reference.delete();
      }

      // 🔹 2️⃣ মাস নিজেও ডিলিট
      await monthRef.delete();

      // 🔹 3️⃣ যদি ডিলিট করা মাস Active হয়, তাহলে অন্য মাস Active করা
      if (selectedMonthId.value == monthId) {
        final snapshot = await _db
            .collection('users')
            .doc(uid)
            .collection('months')
            .orderBy('monthKey', descending: true)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final m = snapshot.docs.first;
          await m.reference.update({'isActive': true});
          selectedMonth.value = m['month'];
          selectedMonthId.value = m.id;
          totalBalance.value = (m['totalBalance'] ?? 0).toDouble();
          balance.value = (m['opening'] ?? 0).toDouble();
          fetchTransactions(m.id);
        } else {
          // যদি আর কোনো মাস না থাকে
          selectedMonth.value = '';
          selectedMonthId.value = '';
          totalBalance.value = 0;
          transactions.clear();
          allTransactions.clear();
        }
      }

      months.removeWhere((m) => m['month'] == monthName);
      if (selectedMonth.value == monthName) {
        selectedMonth.value = months.isNotEmpty ? months.first['month'] : '';
      }

      Get.snackbar(
        'Success',
        '$monthName মাস মুছে দেওয়া হয়েছে',
        colorText: Colors.green,
        backgroundColor: Colors.transparent,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  /// ⬅️ Previous Month
  void goToPreviousMonth() {
    if (months.isEmpty || selectedMonthId.value.isEmpty) return;

    final index = months.indexWhere((m) => m['id'] == selectedMonthId.value);

    if (index == -1) return;

    // older month = next index (because list is desc)
    if (index + 1 < months.length) {
      selectMonth(months[index + 1]);
    } else {
      Get.snackbar(
        'Info',
        'আর আগের কোনো মাস নেই',
        colorText: Colors.white,
        backgroundColor: Colors.transparent,
      );
    }
  }

  /// ➡️ Next Month
  void goToNextMonth() {
    if (months.isEmpty || selectedMonthId.value.isEmpty) return;

    final index = months.indexWhere((m) => m['id'] == selectedMonthId.value);

    if (index == -1) return;

    // newer month = previous index
    if (index - 1 >= 0) {
      selectMonth(months[index - 1]);
    } else {
      Get.snackbar(
        'Info',
        'এটাই সর্বশেষ মাস',
        colorText: Colors.red,
        backgroundColor: Colors.transparent,
      );
    }
  }

  /// ✏️ Edit Transaction
  void editTransaction(TransactionModel trx) {
    Get.to(() => AddTransactionScreen(transaction: trx));
  }

  /// 🗑️ Delete Transaction (100% Working)
  Future<void> deleteTransaction(String id) async {
    if (uid == null || selectedMonthId.isEmpty) return;

    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('months')
          .doc(selectedMonthId.value)
          .collection('transactions')
          .doc(id)
          .delete();

      // UI refresh
      fetchTransactions(selectedMonthId.value);

      Get.snackbar(
        'Success',
        'লেনদেন ডিলিট হয়েছে',
        colorText: Colors.green,
        backgroundColor: Colors.transparent,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> initCurrentMonth() async {
    if (uid == null) return;

    final now = DateTime.now();
    final monthKey = DateFormat('yyyy-MM').format(now);
    final monthName = DateFormat('MMMM yyyy').format(now);

    // 🔍 Check if current month exists
    final existing = await _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .where('monthKey', isEqualTo: monthKey)
        .limit(1)
        .get();

    DocumentReference monthRef;

    if (existing.docs.isNotEmpty) {
      // ✅ Month already exists
      monthRef = existing.docs.first.reference;
    } else {
      // 🆕 Create new month automatically

      // 🔻 Deactivate previous active months
      final activeMonths = await _db
          .collection('users')
          .doc(uid)
          .collection('months')
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in activeMonths.docs) {
        await doc.reference.update({'isActive': false});
      }

      // 🔻 Create new month
      monthRef = await _db
          .collection('users')
          .doc(uid)
          .collection('months')
          .add({
            'month': monthName,
            'monthKey': monthKey,
            'opening': 0.0,
            'totalBalance': 0.0,
            'createdAt': Timestamp.now(),
            'isActive': true,
          });
    }

    // 🔥 Load month data
    final snap = await monthRef.get();

    // 🔹 UI State Update
    selectedMonth.value = snap['month'];
    selectedMonthId.value = monthRef.id;

    totalBalance.value = (snap['totalBalance'] ?? 0).toDouble();

    // ✅ RESET dashboard (VERY IMPORTANT)
    income.value = 0;
    expense.value = 0;
    balance.value = totalBalance.value;

    canAddTransaction.value = true;
    canAddTransaction.value = totalBalance.value > 0;


    // 🔄 Load transactions & calculate dashboard
    await fetchTransactions(monthRef.id);

    _saveState();
  }

  /// 🚪 Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.offAll(() => LogInScreen());
      Get.snackbar('Success', 'Successfully logged out');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
