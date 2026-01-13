import 'package:ay_bay_app/core/analysis/controllers/analysis_controller.dart';
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

    // 🔹 Responsive breakpoints
    final bool isSmall = width < 360;
    final bool isMedium = width >= 360 && width < 600;
    final bool isLarge = width >= 600;

    final monthHeight = isLarge ? height * 0.08 : height * 0.07;
    final cardHeight = isLarge ? height * 0.13 : height * 0.11;
    final cardWidth = isLarge ? width * 0.25 : width * 0.28;
    final chartHeight = isLarge ? 320.0 : isMedium ? 250.0 : 220.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Analysis'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(
              () => controller.monthsList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Months Selector
                SizedBox(
                  height: height * 0.07,
                  child: Obx(() {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.monthsList.length,
                      itemBuilder: (context, index) {
                        final month = controller.monthsList[index];
                        // ✅ Obx এর মধ্যে reactive value ব্যবহার করছ
                        final isSelected = controller.selectedMonthId.value == month['id'];

                        return GestureDetector(
                          onTap: () {
                            // ✅ Reactive update
                            controller.selectMonth(month['id']);
                          },
                          child: Obx(() { // ✅ এখানে আরেকটা Obx দিতে হবে যাতে color change ঠিকমতো হয়
                            final isSelected = controller.selectedMonthId.value == month['id'];
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              margin: EdgeInsets.symmetric(
                                  horizontal: width * 0.02, vertical: height * 0.01),
                              padding: EdgeInsets.symmetric(
                                  vertical: height * 0.01, horizontal: width * 0.05),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: isSelected
                                    ? [
                                  BoxShadow(
                                    color: Colors.blue.shade200.withOpacity(0.4),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                                    : [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                    color: isSelected ? Colors.blue.shade800 : Colors.grey.shade300,
                                    width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  month['month'],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: width * 0.035,
                                  ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // 🔹 Selected Month & Summary Cards
                Obx(() {
                  if (controller.selectedMonthId.value.isEmpty) {
                    return const Center(
                        child: Text('মাস নির্বাচন করুন', style: TextStyle(fontSize: 18)));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Selected Month Name
                      Text(
                        controller.selectedMonthName.value,
                        style: TextStyle(
                            fontSize: isSmall ? width * 0.05 : isMedium ? width * 0.055 : width * 0.045,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: height * 0.02),

                      // 🔹 Summary Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCard('Income', controller.income.value, Colors.green, cardWidth, cardHeight),
                          _buildCard('Expense', controller.expense.value, Colors.red, cardWidth, cardHeight),
                          _buildCard('Balance', controller.balance.value, Colors.blue.shade700, cardWidth, cardHeight),
                        ],
                      ),
                      SizedBox(height: height * 0.03),

                      // 🔹 Category-wise Bar Chart
                      Text(
                        'Category-wise Analysis',
                        style: TextStyle(
                            fontSize: isSmall ? width * 0.04 : isMedium ? width * 0.045 : width * 0.035,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryBarChart(chartHeight, isSmall, isMedium, isLarge),

                      const SizedBox(height: 24),

                      // 🔹 Pie Chart
                      controller.categoryData.isEmpty
                          ? const Center(child: Text('এই মাসে কোন লেনদেন নেই'))
                          : _buildPieChart(width, height, isSmall, isMedium, isLarge),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= Category Bar Chart =================
  Widget _buildCategoryBarChart(double height, bool isSmall, bool isMedium, bool isLarge) {
    if (controller.categoryData.isEmpty) return const SizedBox();

    final categories = controller.categoryData.map((e) => e['name']).toList();
    final maxAmount = controller.categoryData
        .map((e) => (e['income'] ?? 0) + (e['expense'] ?? 0))
        .fold<double>(0, (prev, next) => next > prev ? next.toDouble() : prev);

    final barWidth = isLarge ? 20.0 : isMedium ? 16.0 : 12.0;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxAmount * 1.2,
          barGroups: List.generate(controller.categoryData.length, (index) {
            final cat = controller.categoryData[index];
            return BarChartGroupData(
              x: index,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                    toY: (cat['income'] ?? 0).toDouble(),
                    color: Colors.green,
                    width: barWidth,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6), topRight: Radius.circular(6))),
                BarChartRodData(
                    toY: (cat['expense'] ?? 0).toDouble(),
                    color: Colors.red,
                    width: barWidth,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6), topRight: Radius.circular(6))),
              ],
            );
          }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < 0 || value.toInt() >= categories.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        categories[value.toInt()],
                        style: TextStyle(
                            fontSize: isSmall ? 10 : isMedium ? 11 : 12,
                            fontWeight: FontWeight.w600),
                      ),
                    );
                  }),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: maxAmount / 5,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()}', style: TextStyle(fontSize: 11));
                  }),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: maxAmount / 5,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  // ================= Pie Chart =================
  Widget _buildPieChart(double width, double height, bool isSmall, bool isMedium, bool isLarge) {
    if (controller.categoryData.isEmpty) return const SizedBox();

    List<PieChartSectionData> sections = [];
    for (var cat in controller.categoryData) {
      if ((cat['income'] ?? 0) > 0) {
        sections.add(PieChartSectionData(
          value: cat['income'].toDouble(),
          title: cat['name'],
          color: Colors.green,
          radius: isLarge ? width * 0.12 : width * 0.15,
          titleStyle: TextStyle(
              fontSize: isSmall ? 10 : isMedium ? 12 : 14,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ));
      }
      if ((cat['expense'] ?? 0) > 0) {
        sections.add(PieChartSectionData(
          value: cat['expense'].toDouble(),
          title: cat['name'],
          color: Colors.red,
          radius: isLarge ? width * 0.12 : width * 0.15,
          titleStyle: TextStyle(
              fontSize: isSmall
                  ? 10 : isMedium ? 12 : 14,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ));
      }
    }

    return SizedBox(
      height: isLarge ? height * 0.35 : height * 0.33,
      child: PieChart(PieChartData(sections: sections, centerSpaceRadius: width * 0.08, sectionsSpace: 2)),
    );
  }

  // ================= Summary Card =================
  Widget _buildCard(String title, double amount, Color color, double w, double h) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: w * 0.9,
        height: h * 0.6,
        padding: EdgeInsets.all(w * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: w * 0.10)),
            SizedBox(height: h * 0.010),
            Text('${amount.toInt()}', style: TextStyle(fontSize: w * 0.12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
