import 'package:ay_bay_app/app/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('বাজেট প্ল্যানিং'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 🔹 Summary
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: _buildSummary(),
              ),
            ),

            // 🔹 Pie Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: _buildPieChart(width),
              ),
            ),

            // 🔹 Budget List
            Obx(() {
              if (budgetController.budgets.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Text(
                        'কোনো বাজেট নেই',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final budget = budgetController.budgets[index];
                    return _budgetCard(budget);
                  },
                  childCount: budgetController.budgets.length,
                ),
              );
            }),

            // 🔹 Add Budget Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: AppColors.loginTextButtonColor,
                    elevation: 6,
                  ),
                  onPressed: () => _showBudgetDialog(Get.context!),
                  child: const Text(
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

  /// ================= Summary Row =================
  Widget _buildSummary() {
    return Obx(
          () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _summaryCard('মোট বাজেট', homeController.totalBalance.value, Colors.blueAccent),
          const SizedBox(width: 12),
          _summaryCard('ব্যয়', homeController.expense.value, Colors.redAccent),
          const SizedBox(width: 12),
          _summaryCard('ব্যালান্স', homeController.balance.value, Colors.green),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '${amount.toStringAsFixed(0)} ৳',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= Pie Chart =================
  Widget _buildPieChart(double width) {
    return Obx(() {
      double spent = homeController.expense.value;
      double remaining = homeController.balance.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(4, 6),
            ),
          ],
        ),
        child: SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: spent,
                  color: Colors.redAccent,
                  title: 'ব্যয়',
                  titleStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  radius: 60,
                ),
                PieChartSectionData(
                  value: remaining,
                  color: Colors.greenAccent,
                  title: 'ব্যালান্স',
                  titleStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  radius: 60,
                ),
              ],
              centerSpaceRadius: 40,
              sectionsSpace: 4,
            ),
          ),
        ),
      );
    });
  }

  /// ================= Single Budget Card =================
  Widget _budgetCard(BudgetModel budget) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: ListTile(
          title: Text(budget.category, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('বাজেট যোগ করা হয়েছে : ${budget.amount.toStringAsFixed(0)} ৳'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => budgetController.deleteBudget(budget.id),
          ),
          onTap: () => _showBudgetDialog(Get.context!, budget: budget),
        ),
      ),
    );
  }

  /// ================= Add/Edit Budget Dialog =================
  void _showBudgetDialog(BuildContext context, {BudgetModel? budget}) {
    final catController = TextEditingController(text: budget?.category ?? '');
    final amountController = TextEditingController(text: budget?.amount.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(budget == null ? 'নতুন বাজেট' : 'বাজেট এডিট'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: catController,
              decoration: const InputDecoration(labelText: 'ক্যাটেগরি'),
            ),
            const SizedBox(height: 12),
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
            child: Text('বাতিল', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.loginTextButtonColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (budgetController.selectedMonthId.value.isEmpty) {
                Get.snackbar('Error', 'আগে মাস সিলেক্ট করুন');
                return;
              }

              final categoryName = catController.text.trim();
              final amt = double.tryParse(amountController.text) ?? 0;

              if (categoryName.isEmpty || amt <= 0) return;

              final newBudget = BudgetModel(
                id: budget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                category: categoryName,
                amount: amt,
                spent: budget?.spent ?? 0.0,
                monthId: budgetController.selectedMonthId.value,
              );

              budgetController.saveBudget(newBudget);
              Navigator.pop(context);
            },
            child: const Text('সেভ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
