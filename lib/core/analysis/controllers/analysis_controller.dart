// analysis_controller.dart
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AnalysisController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final HomeController home = Get.find<HomeController>();

  RxList<Map<String, dynamic>> monthsList = <Map<String, dynamic>>[].obs;
  RxString selectedMonthId = ''.obs;
  RxString selectedMonthName = ''.obs;

  // Analysis data
  RxDouble income = 0.0.obs;
  RxDouble expense = 0.0.obs;
  RxDouble balance = 0.0.obs;

  // Category-wise data
  RxList<Map<String, dynamic>> categoryData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMonths();

    // 🔹 প্রথমে কারেন্ট মাস সিলেক্ট ও ডাটা লোড
    if (monthsList.isNotEmpty) {
      final currentMonth = monthsList.last; // ধরে নিই monthsList sorted, শেষটা কারেন্ট
      selectMonth(currentMonth['id']);
    }
  }

  void loadMonths() {
    monthsList.value = home.months
        .map((m) => {
      'id': m['id'],
      'month': m['month'],
      'monthKey': m['monthKey'],
      'totalBalance': (m['totalBalance'] ?? 0).toDouble(),
    })
        .toList()
      ..sort((a, b) => a['monthKey'].compareTo(b['monthKey']));
  }

  Future<void> selectMonth(String monthId) async {
    selectedMonthId.value = monthId;
    final month = monthsList.firstWhere((m) => m['id'] == monthId);
    selectedMonthName.value = month['month'];

    await fetchMonthAnalysis(monthId);
  }

  Future<void> fetchMonthAnalysis(String monthId) async {
    final uid = home.uid;
    if (uid == null) return;

    final trxSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('months')
        .doc(monthId)
        .collection('transactions')
        .get();

    double inc = 0;
    double exp = 0;
    Map<String, Map<String, double>> catMap = {}; // category-wise

    for (var doc in trxSnap.docs) {
      final amt = (doc['amount'] ?? 0).toDouble();
      final cat = doc['category'] ?? 'Uncategorized';
      if (!catMap.containsKey(cat)) catMap[cat] = {'income': 0.0, 'expense': 0.0};

      if (doc['type'] == 'income') {
        inc += amt;
        catMap[cat]!['income'] = catMap[cat]!['income']! + amt;
      } else {
        exp += amt;
        catMap[cat]!['expense'] = catMap[cat]!['expense']! + amt;
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
    balance.value = (monthSnap['totalBalance'] ?? 0).toDouble() + inc - exp;

    // Category-wise update
    categoryData.value = catMap.entries
        .map((e) => {
      'name': e.key,
      'income': e.value['income']!,
      'expense': e.value['expense']!,
    })
        .toList();
  }
}