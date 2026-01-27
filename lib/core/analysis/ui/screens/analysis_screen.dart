import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/core/analysis/controllers/analysis_controller.dart';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnalysisScreen extends StatelessWidget {
  AnalysisScreen({super.key});

  final AnalysisController controller = Get.put(AnalysisController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(context.localization.monthlyAnalysis, style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.loginTextButtonColor,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.monthsList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Months Selector
              SizedBox(
                height: isLandscape ? 56 : 64,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.monthsList.length,
                  itemBuilder: (context, index) {
                    final month = controller.monthsList[index];
                    return GestureDetector(
                      onTap: () => controller.selectMonth(month['id']),
                      child: Obx(() {
                        final isSelected =
                            controller.selectedMonthId.value == month['id'];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                colors: [Colors.blueAccent, Colors.lightBlue])
                                : LinearGradient(
                                colors: [Colors.grey.shade200, Colors.grey.shade300]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? Colors.blueAccent.withValues(alpha: 0.35)
                                    : Colors.black12,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              month['month'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: isLandscape ? 16 : 14,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
              SizedBox(height: isLandscape ? height * 0.12 : height * 0.04),

              /// 🔹 Selected Month & Summary
              Obx(() {
                if (controller.selectedMonthId.value.isEmpty) {
                  return Center(
                    child: Text('মাস নির্বাচন করুন', style: TextStyle(fontSize: isLandscape ? 16 : 15)),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      controller.selectedMonthName.value,
                      style: TextStyle(
                        fontSize: width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isLandscape ? height * 0.12 : height * 0.04),

                    /// 🔹 Premium Summary Cards
                    _buildPremiumCardRow(width, height, isLandscape),
                    SizedBox(height: isLandscape ? height * 0.12 : height * 0.04),

                    /// 🔹 Category Bar Chart
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Category-wise Analysis',
                        style: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: isLandscape ? height * 0.18 : height * 0.06),
                    SizedBox(
                      height: isLandscape ? 250 : 220, // height limited
                      child: _buildCategoryBarChart(),
                    ),
                    SizedBox(height: isLandscape ? height * 0.16 : height * 0.04),

                    /// 🔹 Pie Chart
                    if (controller.categoryData.isEmpty)
                      const Center(child: Text('এই মাসে কোন লেনদেন নেই'))
                    else
                      SizedBox(
                        height: 220, // height limited
                        child: _buildPieChart(),
                      ),
                    SizedBox(height: 24),
                  ],
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  /// ================= Premium Cards Row =================
  Widget _buildPremiumCardRow(double width, double height, bool isLandscape) {
    final cards = [
      {'title': 'Income', 'amount': controller.income.value, 'color': Colors.green},
      {'title': 'Expense', 'amount': controller.expense.value, 'color': Colors.red},
      {'title': 'Balance', 'amount': controller.balance.value, 'color': Colors.blue},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: cards.map((card) {
        return _premiumSummaryCard(
          title: card['title'] as String,
          value: card['amount'] as double,
          color: card['color'] as Color,
          width: width * 0.28,
          height: isLandscape ? height * 0.2 : height * 0.13,
        );
      }).toList(),
    );
  }

  Widget _premiumSummaryCard({
    required String title,
    required double value,
    required Color color,
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height * 0.9,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.7), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('${value.toStringAsFixed(0)} ৳',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCategoryBarChart() {
    if (controller.categoryData.isEmpty) return const SizedBox();
    final categories = controller.categoryData.map((e) => e['name']).toList();
    final maxAmount = controller.categoryData
        .map((e) => (e['income'] ?? 0) + (e['expense'] ?? 0))
        .fold<double>(0, (prev, next) => next > prev ? next.toDouble() : prev);

    return BarChart(
      BarChartData(
        maxY: maxAmount * 1.1,
        barGroups: List.generate(controller.categoryData.length, (index) {
          final cat = controller.categoryData[index];
          return BarChartGroupData(
            x: index,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                  toY: (cat['income'] ?? 0).toDouble(),
                  color: Colors.green,
                  width: 16,
                  borderRadius:
                  const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
              BarChartRodData(
                  toY: (cat['expense'] ?? 0).toDouble(),
                  color: Colors.red,
                  width: 16,
                  borderRadius:
                  const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))),
            ],
          );
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= categories.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(categories[value.toInt()],
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: maxAmount / 5),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: maxAmount / 5,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withValues(alpha: 0.2), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildPieChart() {
    if (controller.categoryData.isEmpty) return const SizedBox();
    List<PieChartSectionData> sections = [];
    for (var cat in controller.categoryData) {
      if ((cat['income'] ?? 0) > 0) {
        sections.add(PieChartSectionData(
          value: cat['income'].toDouble(),
          title: cat['name'],
          color: Colors.green,
          radius: 50,
          titleStyle: const TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
        ));
      }
      if ((cat['expense'] ?? 0) > 0) {
        sections.add(PieChartSectionData(
          value: cat['expense'].toDouble(),
          title: cat['name'],
          color: Colors.red,
          radius: 50,
          titleStyle: const TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
        ));
      }
    }

    return PieChart(
      PieChartData(
          sections: sections,
          centerSpaceRadius: 50,
          sectionsSpace: 1,
          borderData: FlBorderData(show: false)),
    );
  }
}
