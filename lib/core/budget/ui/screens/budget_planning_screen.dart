import 'package:ay_bay_app/core/budget/controllers/budget_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BudgetPlanningScreen extends StatelessWidget {
  BudgetPlanningScreen({super.key});

  final BudgetController controller = Get.put(BudgetController());

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Planning'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.categories.isEmpty && controller.totalBudget.value == 0) {
          // প্রথমে loader দেখাবে
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.categories.isEmpty) {
          // ডাটা নাই হলে empty state দেখাবে
          return Center(
            child: Text(
              'কোনো বাজেট ডাটা পাওয়া যায়নি',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        // ডাটা থাকলে Card দেখাবে
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _summaryCard(isLandscape),
              const SizedBox(height: 20),
              ...controller.categories
                  .map((c) => _categoryCard(c, isLandscape))
                  .toList(),
            ],
          ),
        );
      })
      ,
    );
  }

  // ================= Summary =================
  Widget _summaryCard(bool isLandscape) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() => Column(
          children: [
            _row('Total Budget', controller.totalBudget.value, Colors.blue),
            _row('Spent', controller.totalSpent, Colors.red),
            const Divider(),
            _row('Remaining', controller.remaining,
                controller.remaining >= 0 ? Colors.green : Colors.red),
          ],
        )),
      ),
    );
  }

  Widget _row(String title, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            '৳ ${value.toInt()}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  // ================= Category Card =================
  Widget _categoryCard(cat, bool isLandscape) {
    final progress = (cat.spent / cat.budget).clamp(0.0, 1.0);

    Color color = progress >= 1
        ? Colors.red
        : progress >= 0.8
        ? Colors.orange
        : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title + spent/budget
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cat.name,
                  style: TextStyle(
                      fontSize: isLandscape ? 14 : 16,
                      fontWeight: FontWeight.bold),
                ),
                Text('৳ ${cat.spent.toInt()} / ${cat.budget.toInt()}'),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: color,
              backgroundColor: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            if (progress >= 1)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Over Budget!',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
