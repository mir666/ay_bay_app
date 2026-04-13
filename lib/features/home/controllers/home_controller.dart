import 'dart:async';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
import 'package:ay_bay_app/features/auth/ui/screens/log_in_screen.dart';
import 'package:ay_bay_app/features/common/models/transaction_type_model.dart';
import 'package:ay_bay_app/features/common/transaction/ui/screens/add_transaction_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'notification_controller.dart';

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
  RxBool showTotalBudget = false.obs;


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
      final now = DateTime.now();
      final lastDay = DateTime(now.year, now.month + 1, 0);

      if (now.day == lastDay.day && now.hour == 23 && now.minute == 59) {
        _sendMonthlyExpenseNotification();
      }
    });
    checkMonthlyExpenseNotification();
  }

  // 🔍 Search & Suggestions
  final isSearching = false.obs;
  final searchText = ''.obs;
  final suggestions = <TransactionModel>[].obs;
  final recentSearches = <String>[].obs;
  Timer? _debounce;

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
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 300),
          () => _performSearch(query),
    );

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

  void _performSearch(String query) {
    searchText.value = query;
    isSearching.value = query.isNotEmpty;

    if (query.isEmpty) {
      transactions.value = allTransactions;
      suggestions.clear();
      monthSuggestions.clear();
      return;
    }

    final q = query.toLowerCase();

    final trxMatches = globalTransactions.where((trx) {
      final titleMatch =
      trx.title.toLowerCase().contains(q);

      final categoryMatch =
      trx.category.toLowerCase().contains(q);

      final monthMatch =
      trx.monthName.toLowerCase().contains(q);

      final dateStr = DateFormat(
        'dd MMM yyyy',
      ).format(trx.date).toLowerCase();

      final dateMatch =
      dateStr.contains(q);

      return titleMatch ||
          categoryMatch ||
          monthMatch ||
          dateMatch;
    }).toList();

    suggestions.value =
        trxMatches.take(6).toList();

    transactions.value = trxMatches;

    monthSuggestions.value = months
        .where((m) =>
        m['month']
            .toString()
            .toLowerCase()
            .contains(q))
        .take(6)
        .toList();
  }

  void saveSearchHistory(String query) {
    if (query.isEmpty) return;

    recentSearches.remove(query);

    recentSearches.insert(0, query);

    if (recentSearches.length > 5) {
      recentSearches.removeLast();
    }
  }

  void selectSuggestion(TransactionModel trx) async {
    searchText.value = trx.title;
    saveSearchHistory(trx.title);

    selectedMonth.value = trx.monthName;
    selectedMonthId.value = trx.monthId;

    await fetchTransactions(trx.monthId);

    transactions.value = [trx]; // শুধু ঐ লেনদেন দেখাবে
    suggestions.clear();
    monthSuggestions.clear();
    isSearching.value = false;
  }

  void selectMonthFromSearch(Map<String, dynamic> month) async {
    saveSearchHistory(month['month']);
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
    if (searchText.value.isNotEmpty) {
      saveSearchHistory(searchText.value);
    }

    isSearching.value = false;
    searchText.value = '';
    suggestions.clear();
    monthSuggestions.clear();
    transactions.value = allTransactions;
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

  /// 💰 Dashboard Calculation (MODEL BASED
  void _calculateDashboard(List<TransactionModel> data) {
    double inc = 0;
    double exp = 0;

    for (final trx in data) {
      if (trx.type == TransactionType.income) {
        inc += trx.amount;
      } else if (trx.type == TransactionType.expense) {
        exp += trx.amount;
      }
    }

    // শুধু UI stats
    income.value = inc;
    expense.value = exp;

    // 🔥 আসল ব্যালেন্স লজিক
    totalBalance = totalBalance;
    balance.value = inc - exp;
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

  Future<void> addMonth(
      BuildContext context, {
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
          context.localization.alreadyExists,
          context.localization.thisMonthAccountIsAlreadyOpen,
          colorText: Colors.red,
          backgroundColor: Colors.transparent,
          snackPosition: SnackPosition.BOTTOM,
          barBlur: 0,
          titleText: Text(
            context.localization.alreadyExists,
            textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.red,
              fontSize: 16,
            ),
          ),
          messageText: Text(
            context.localization.thisMonthAccountIsAlreadyOpen,
            textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
            style: TextStyle(
              fontWeight: FontWeight.w600, // বোল্ড
              color: Colors.red, // টেক্স কালার
              fontSize: 16,
            ),
          ),
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
      Get.back();
      canAddTransaction.value = true;
      await fetchTransactions(docRef.id);

      Get.snackbar(
        context.localization.success,
        context.localization.addANewMonth,
        colorText: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
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
          context.localization.addANewMonth,
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
        messageText: Text(
          context.localization.error,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: TextStyle(
            fontWeight: FontWeight.w600, // বোল্ড
            color: Colors.red,           // টেক্স কালার
            fontSize: 16,
          ),
        ),
      );
    }
  }

  Future<void> createNewMonth(
      BuildContext context, {
        required DateTime monthDate,
      }) async {
    if (uid == null) return;

    final monthKey = DateFormat('yyyy-MM').format(monthDate);
    final monthName = DateFormat('MMMM yyyy').format(monthDate);

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
        context.localization.error,
        context.localization.thisMonthAccountIsAlreadyOpen,
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        barBlur: 0,
        messageText: Text(
          context.localization.error,
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

    // 🔹 Get previous month balance
    double openingBalance = 0.0;
    final prevMonthSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .orderBy('monthKey', descending: true)
        .limit(1)
        .get();

    if (prevMonthSnap.docs.isNotEmpty) {
      final prev = prevMonthSnap.docs.first;
      openingBalance = (prev['totalBalance'] ?? 0).toDouble();

      // deactivate old month
      await prev.reference.update({'isActive': false});
    }

    // 🔹 Create new month with previous balance
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .add({
      'monthKey': monthKey,
      'month': monthName,
      'opening': openingBalance,
      'totalBalance': openingBalance,
      'income': 0,
      'expense': 0,
      'createdAt': Timestamp.now(),
      'isActive': true,
    });

    // UI update
    selectedMonthId.value = doc.id;
    selectedMonth.value = monthName;
    totalBalance.value = openingBalance;
    income.value = 0;
    expense.value = 0;
    balance.value = openingBalance;

    Get.back();
    await fetchTransactions(doc.id);

    Get.snackbar(
      context.localization.success,
      context.localization.addANewMonth,
      snackPosition: SnackPosition.BOTTOM,
      barBlur: 0,
      titleText: Text(
        context.localization.success,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.green,
          fontSize: 16,
        ),
      ),
      messageText: Text(
        context.localization.addANewMonth,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.green,
          fontSize: 16,
        ),
      ),
    );
  }

  Future<void> updateCurrentMonthBudget(
      BuildContext context,
      double amount,
      ) async {
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
    balance.value = totalBalance.value - expense.value;

    // ✅ ব্যালেন্স = মোট বাজেট - মোট ব্যয়
    balance.value = totalBalance.value - expense.value;
    canAddTransaction.refresh();

    Get.back();
    Get.snackbar(
      context.localization.success,
      context.localization.updateTotalBalance,
      snackPosition: SnackPosition.BOTTOM,
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
        context.localization.updateTotalBalance,
        textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
        style: TextStyle(
          fontWeight: FontWeight.w600, // বোল্ড
          color: Colors.green,           // টেক্স কালার
          fontSize: 16,
        ),
      ),
    );
  }

  /// 🗑️ Delete Month
  Future<void> deleteMonth(
      BuildContext context,
      String monthId,
      String monthName,
      ) async {
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
        context.localization.success,
        '$monthName ${context.localization.monthDeleted}',
        backgroundColor: Colors.transparent,
        snackPosition: SnackPosition.BOTTOM,
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
          context.localization.monthDeleted,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: TextStyle(
            fontWeight: FontWeight.w600, // বোল্ড
            color: Colors.green,           // টেক্স কালার
            fontSize: 16,
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(context.localization.error, e.toString(), snackPosition: SnackPosition.BOTTOM,
        barBlur: 0,
        messageText: Text(
          context.localization.error,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: TextStyle(
            fontWeight: FontWeight.w600, // বোল্ড
            color: Colors.red,           // টেক্স কালার
            fontSize: 16,
          ),
        ),
      );
    }
  }

  /// ⬅️ Previous Month
  void goToPreviousMonth(BuildContext context) {
    if (months.isEmpty || selectedMonthId.value.isEmpty) return;

    final index = months.indexWhere((m) => m['id'] == selectedMonthId.value);

    if (index == -1) return;

    // older month = next index (because list is desc)
    if (index + 1 < months.length) {
      selectMonth(months[index + 1]);
    } else {
      Get.snackbar(
        context.localization.info,
        context.localization.noMonth,
        colorText: Colors.blueGrey,
        backgroundColor: Colors.transparent,
        snackPosition: SnackPosition.BOTTOM,
        barBlur: 0,
        messageText: Text(
          context.localization.noMonth,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: TextStyle(
            fontWeight: FontWeight.w600, // বোল্ড
            color: Colors.blueGrey, // টেক্স কালার
            fontSize: 16,
          ),
        ),
      );
    }
  }

  /// ➡️ Next Month
  void goToNextMonth(BuildContext context) {
    if (months.isEmpty || selectedMonthId.value.isEmpty) return;

    final index = months.indexWhere((m) => m['id'] == selectedMonthId.value);

    if (index == -1) return;

    // newer month = previous index
    if (index - 1 >= 0) {
      selectMonth(months[index - 1]);
    } else {
      Get.snackbar(
        context.localization.info,
        context.localization.thisIsLastMonth,
        colorText: Colors.red,
        backgroundColor: Colors.transparent,
        snackPosition: SnackPosition.BOTTOM,
        barBlur: 0,
        messageText: Text(
          context.localization.thisIsLastMonth,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: TextStyle(
            fontWeight: FontWeight.w600, // বোল্ড
            color: Colors.red,           // টেক্স কালার
            fontSize: 16,
          ),
        ),
      );
    }
  }

  /// ✏️ Edit Transaction
  void editTransaction(TransactionModel trx) {
    Get.to(() => AddTransactionScreen(transaction: trx));
  }

  /// 🗑️ Delete Transaction (100% Working)
  Future<void> deleteTransaction(BuildContext context, String id) async {
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
        context.localization.success,
        context.localization.deleteTheTransaction,
        colorText: Colors.green,
        backgroundColor: Colors.transparent,
        snackPosition: SnackPosition.BOTTOM,
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
          context.localization.deleteTheTransaction,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: TextStyle(
            fontWeight: FontWeight.w600, // বোল্ড
            color: Colors.green,           // টেক্স কালার
            fontSize: 16,
          ),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
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
    double openingBalance = 0.0;

    if (existing.docs.isNotEmpty) {
      // ✅ Month already exists
      monthRef = existing.docs.first.reference;
    } else {
      // 🆕 Create new month automatically

      // 🔻 Get previous month balance
      final prevMonthSnap = await _db
          .collection('users')
          .doc(uid)
          .collection('months')
          .orderBy('monthKey', descending: true)
          .limit(1)
          .get();

      if (prevMonthSnap.docs.isNotEmpty) {
        final prev = prevMonthSnap.docs.first;
        openingBalance = (prev['totalBalance'] ?? 0).toDouble();

        // Deactivate previous month
        await prev.reference.update({'isActive': false});
      }

      // 🔻 Create new month with previous balance
      monthRef = await _db
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
    }

    // 🔥 Load month data
    final snap = await monthRef.get();

    // 🔹 UI State Update
    selectedMonth.value = snap['month'];
    selectedMonthId.value = monthRef.id;

    totalBalance.value = (snap['totalBalance'] ?? 0).toDouble();

    // ✅ RESET dashboard
    income.value = 0;
    expense.value = 0;
    balance.value = totalBalance.value;

    canAddTransaction.value = true;
    canAddTransaction.value = totalBalance.value > 0;

    // 🔄 Load transactions & calculate dashboard
    await fetchTransactions(monthRef.id);

    _saveState();
  }

  double getMonthlyExpense(List<TransactionModel> data, DateTime month) {
    return data
        .where(
          (trx) =>
      trx.type == TransactionType.expense &&
          trx.date.month == month.month &&
          trx.date.year == month.year,
    )
        .fold(0.0, (sum, trx) => sum + trx.amount);
  }

  /// 📝 Decide notification message
  String getMonthlyNotificationMessage(
      double currentMonthExpense,
      double previousMonthExpense,
      ) {
    if (currentMonthExpense > previousMonthExpense) {
      return "আপনার খরচ বেড়ে গেছে, হিসাব করে খরচ করুন";
    } else if (currentMonthExpense < previousMonthExpense) {
      return "খুব ভাল! আপনি সাশ্রয়ী হয়েছেন";
    } else {
      return "এই মাসের খরচ পূর্বের মাসের সমান";
    }
  }

  /// 📝 Send notification locally
  void sendMonthlyNotification(String title, String message) {
    final notificationController = Get.find<NotificationController>();
    notificationController.addNotification(title, message);

    // Optionally: Use FirebaseMessaging or local notification plugin
    // Example: foreground push
    FirebaseMessaging.instance.subscribeToTopic('monthly'); // optional
  }

  Future<void> _sendMonthlyExpenseNotification() async {
    if (months.length < 2) return; // আগে মাসের data না থাকলে skip
    final notificationController = Get.find<NotificationController>();

    final currentMonthId = selectedMonthId.value;
    if (currentMonthId.isEmpty) return;

    // 🔹 Current month expense
    final currentSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .doc(currentMonthId)
        .collection('transactions')
        .get();

    double currentExpense = 0;
    for (var trx in currentSnap.docs) {
      if (trx['type'] == 'expense')
        currentExpense += (trx['amount'] ?? 0).toDouble();
    }

    // 🔹 Previous month expense
    final currentIndex = months.indexWhere((m) => m['id'] == currentMonthId);
    if (currentIndex + 1 >= months.length) return;

    final previousMonthId = months[currentIndex + 1]['id'];
    final previousSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .doc(previousMonthId)
        .collection('transactions')
        .get();

    double previousExpense = 0;
    for (var trx in previousSnap.docs) {
      if (trx['type'] == 'expense')
        previousExpense += (trx['amount'] ?? 0).toDouble();
    }

    // 🔹 Decide message
    String message;
    String title;
    if (currentExpense > previousExpense) {
      title = "";
      message = "আপনার খরচ বেড়ে গেছে, হিসাব করে খরচ করুন";
    } else if (currentExpense < previousExpense) {
      title = "";
      message = "খুব ভাল! আপনি সাশ্রয়ী হয়েছেন";
    } else {
      title = "";
      message = "এই মাসের খরচ পূর্বের মাসের সমান";
    }

    // 🔹 Add to NotificationController
    notificationController.addNotification(title,message);
  }


  double getMonthExpense(DateTime month) {
    return transactions
        .where(
          (t) =>
      t.type == TransactionType.expense &&
          t.date.month == month.month &&
          t.date.year == month.year,
    )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  bool isLastDayOfMonth(DateTime date) {
    final nextDay = date.add(const Duration(days: 1));
    return nextDay.month != date.month;
  }

  void checkMonthlyExpenseNotification() {
    final now = DateTime.now();

    if (!isLastDayOfMonth(now)) return;

    final currentMonthExpense = getMonthExpense(now);

    final previousMonth = DateTime(now.year, now.month - 1, 1);
    final previousMonthExpense = getMonthExpense(previousMonth);

    final notificationController = Get.find<NotificationController>();

    /// 🔹 Month End Summary
    notificationController.addNotification(
      '',
      'এই মাসে আপনার মোট খরচ হয়েছে ৳${currentMonthExpense.toInt()}',
    );

    /// 🔹 Compare
    if (currentMonthExpense > previousMonthExpense) {
      final diff = (currentMonthExpense - previousMonthExpense).toInt();

      notificationController.addNotification(
        '',
        '⚠️ আগের মাসের তুলনায় এই মাসে খরচ বেড়েছে ৳$diff',
      );
    } else if (currentMonthExpense < previousMonthExpense) {
      final diff = (previousMonthExpense - currentMonthExpense).toInt();

      notificationController.addNotification(
        '',
        '✅ আগের মাসের তুলনায় এই মাসে খরচ কমেছে ৳$diff',
      );
    } else {
      notificationController.addNotification(
        '',
        'ℹ️ আগের মাসের মতোই এই মাসে খরচ হয়েছে',
      );
    }
  }

  /// 🚪 Logout
  Future<void> logout(BuildContext context) async {
    try {
      await _auth.signOut();
      Get.offAll(() => LogInScreen());
      Get.snackbar(
        context.localization.success,
        context.localization.logout_success,
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.green,
        barBlur: 0,
        titleText: Text(
          context.localization.success,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red,
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
        barBlur: 0,
        messageText: Text(
          context.localization.error,
          textAlign: TextAlign.center, // হরিজেন্টালি সেন্টার
          style: TextStyle(
            fontWeight: FontWeight.w600, // বোল্ড
            color: Colors.red,           // টেক্স কালার
            fontSize: 16,
          ),
        ),
      );
    }
  }
}