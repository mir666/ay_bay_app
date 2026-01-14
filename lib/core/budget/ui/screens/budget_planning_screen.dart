import 'package:ay_bay_app/core/budget/models/budget_model.dart';
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
    'অন্যান্য',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('বাজেট প্ল্যানিং'), centerTitle: true),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 🔹 Summary
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 30),
                child: _buildSummary(),
              ),
            ),

            // 🔹 Pie Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 30, bottom: 30),
                child: _buildPieChart(),
              ),
            ),

            // 🔹 Budget List
            Obx(() {
              if (budgetController.budgets.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(child: Text('কোনো বাজেট নেই')),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final budget = budgetController.budgets[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(budget.category),
                      subtitle: Text(
                        'বাজেট যোগ করা হয়েছে : ${budget.amount.toStringAsFixed(0)} ৳',
                      ),

                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            budgetController.deleteBudget(budget.id),
                      ),
                      onTap: () => _showBudgetDialog(context, budget: budget),
                    ),
                  );
                }, childCount: budgetController.budgets.length),
              );
            }),

            // 🔹 Add Button
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 40),
                child: ElevatedButton(
                  onPressed: () => _showBudgetDialog(context),
                  child: Text(
                    'নতুন বাজেট যোগ করুন',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// -----------------------------
  /// 🔹 Summary Card Row
  /// -----------------------------
  Widget _buildSummary() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _summaryCard(
              'মোট বাজেট',
              homeController.totalBalance.value,
              Colors.blue,
            ),
            _summaryCard('ব্যয়', homeController.expense.value, Colors.red),
            _summaryCard(
              'ব্যালান্স',
              homeController.balance.value,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${amount.toStringAsFixed(0)} ৳',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// -----------------------------
  /// 🔹 Pie Chart
  /// -----------------------------
  Widget _buildPieChart() {
    return Obx(() {
      double spent = homeController.expense.value;
      double remaining = homeController.balance.value;

      return SizedBox(
        height: 220,
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: spent,
                color: Colors.redAccent,
                title: 'ব্যয়',
              ),
              PieChartSectionData(
                value: remaining,
                color: Colors.greenAccent,
                title: 'ব্যালান্স',
              ),
            ],
          ),
        ),
      );
    });
  }

  /// -----------------------------
  /// 🔹 Add/Edit Budget Dialog
  /// -----------------------------
  void _showBudgetDialog(BuildContext context, {BudgetModel? budget}) {
    final catController = TextEditingController(text: budget?.category ?? '');
    final amountController = TextEditingController(
      text: budget?.amount.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(budget == null ? 'নতুন বাজেট' : 'বাজেট এডিট'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: catController,
              decoration: const InputDecoration(labelText: 'ক্যাটেগরি'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'বাজেট (৳)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'বাতিল',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (budgetController.selectedMonthId.value.isEmpty) {
                Get.snackbar('Error', 'আগে মাস সিলেক্ট করুন');
                return;
              }

              final categoryName = catController.text.trim();
              final amt = double.tryParse(amountController.text) ?? 0;

              if (categoryName.isEmpty || amt <= 0) return;

              final newBudget = BudgetModel(
                id:
                    budget?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                category: categoryName,
                amount: amt,
                spent: budget?.spent ?? 0.0,
                monthId: budgetController.selectedMonthId.value,
              );

              budgetController.saveBudget(newBudget);
              Navigator.pop(context);
            },
            child: Text(
              'সেভ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
