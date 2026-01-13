// budget_screen.dart
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:ay_bay_app/core/budget/controllers/budget_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class BudgetScreen extends StatelessWidget {
  BudgetScreen({super.key});

  final HomeController homeController = Get.find<HomeController>();
  final BudgetController budgetController = Get.put(BudgetController());

  final List<String> categories = [
    'খাদ্য',
    'পরিবহন',
    'বিল',
    'বিনোদন',
    'অন্যান্য'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('বাজেট প্ল্যানিং')),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔹 Month Selector

            /// 🔹 Budget Summary
            Obx(() {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _summaryCard(
                        'মোট বাজেট', homeController.totalBalance.value, Colors.blue),
                    _summaryCard(
                        'ব্যয়', homeController.expense.value, Colors.red),
                    _summaryCard(
                        'ব্যালান্স', homeController.balance.value, Colors.green),
                  ],
                ),
              );
            }),

            /// 🔹 PieChart
            Obx(() {
              double spent = homeController.expense.value;
              double remaining = homeController.balance.value;
              if (homeController.totalBalance.value == 0) {
                spent = 0;
                remaining = 0;
              }

              return SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: spent,
                        color: Colors.redAccent,
                        title: 'ব্যয়',
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: remaining,
                        color: Colors.greenAccent,
                        title: 'ব্যালান্স',
                        titleStyle: const TextStyle(color: Colors.white),
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              );
            }),

            /// 🔹 Category Budget List
            Expanded(
              child: Obx(() {
                if (homeController.transactions.isEmpty) {
                  return const Center(child: Text('কোনো বাজেট নেই'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final catExpense = homeController.transactions
                        .where((t) => t.category == cat)
                        .fold<double>(
                        0,
                            (prev, t) =>
                        prev + (t.type == 'expense' ? t.amount : 0));

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(cat),
                        subtitle: Text('ব্যয়: $catExpense ৳'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _showBudgetDialog(context, category: cat),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteCategoryTransactions(cat),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            /// 🔹 Add Budget Button
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: () => _showBudgetDialog(context),
                child: const Text('নতুন বাজেট যোগ করুন'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// -----------------------------
  /// 🔹 Summary Card
  /// -----------------------------
  Widget _summaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(height: 4),
              Text('${amount.toStringAsFixed(0)} ৳',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  /// -----------------------------
  /// 🔹 Add/Edit Budget Dialog
  /// -----------------------------
  void _showBudgetDialog(BuildContext context, {String? category}) {
    final catController = TextEditingController(text: category ?? '');
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(category == null ? 'নতুন বাজেট' : 'বাজেট এডিট'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: catController,
              decoration: const InputDecoration(labelText: 'ক্যাটেগরি'),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'বাজেট (৳)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountController.text) ?? 0;
              if (amt <= 0) return;

              final newTotal = homeController.totalBalance.value + amt;
              homeController.updateCurrentMonthBudget(newTotal);

              Navigator.pop(context);
            },
            child: const Text('সেভ'),
          ),
        ],
      ),
    );
  }

  /// -----------------------------
  /// 🔹 Delete Category Transactions
  /// -----------------------------
  void _deleteCategoryTransactions(String category) async {
    final monthId = homeController.selectedMonthId.value;
    if (monthId.isEmpty) return;

    final toDelete = homeController.transactions
        .where((t) => t.category == category)
        .toList();

    for (var trx in toDelete) {
      await homeController.deleteTransaction(trx.id);
    }

    Get.snackbar('Success', '$category-এর বাজেট ডিলিট হয়েছে',
        colorText: Colors.green);
  }
}
