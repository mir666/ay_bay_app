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

    final bool isSmall = width < 360;
    final bool isMedium = width >= 360 && width < 600;
    final bool isLarge = width >= 600;


    final chartHeight = isLarge ? 320.0 : isMedium ? 250.0 : 220.0;
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Analysis'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.monthsList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Months Selector
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
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 18,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.shade700
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? Colors.blue.withValues(alpha: 0.35)
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
                                  fontSize: isLandscape ? 14 : 15,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),

                SizedBox(height: isLarge ? height * 0.15 : height * 0.03,),

                // 🔹 Selected Month & Summary
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isLarge ? height * 0.10 : height * 0.03,),

                      // 🔹 Summary Cards
                      _buildResponsiveCardRow(width, height),
                      SizedBox(height: isLarge ? height * 0.10 : height * 0.05,),

                      // 🔹 Category-wise Bar Chart
                      Text(
                        'Category-wise Analysis',
                        style: TextStyle(
                          fontSize: isSmall ? width * 0.04 : isMedium ? width * 0.045 : width * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isLarge ? height * 0.30 : height * 0.05,),
                      SizedBox(
                        height: chartHeight,
                        width: double.infinity,
                        child: _buildCategoryBarChart(chartHeight, isSmall, isMedium, isLarge),
                      ),
                      SizedBox(height: isLarge ? height * 0.40 : height * 0.01,),

                      // 🔹 Pie Chart
                      if (controller.categoryData.isEmpty)
                        Center(child: Text('এই মাসে কোন লেনদেন নেই'),)
                      else
                        SizedBox(
                          height: isLarge ? height * 0.35 : height * 0.33,
                          width: double.infinity,
                          child: _buildPieChart(width, height, isSmall, isMedium, isLarge),
                        ),
                      SizedBox(height: 24),
                    ],
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ================= Responsive Cards Row =================
  Widget _buildResponsiveCardRow(double width, double height) {
    final isLandscape =
        MediaQuery.of(Get.context!).orientation == Orientation.landscape;

    final cards = [
      {'title': 'Income', 'amount': controller.income.value, 'color': Colors.green},
      {'title': 'Expense', 'amount': controller.expense.value, 'color': Colors.red},
      {'title': 'Balance', 'amount': controller.balance.value, 'color': Colors.blue},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: cards.map((card) {
            double cardWidth;
            double cardHeight;

            /// -------- WIDTH --------
            if (availableWidth < 360) {
              cardWidth = availableWidth * 0.9;
            } else if (availableWidth < 600) {
              cardWidth = availableWidth * 0.28;
            } else {
              cardWidth = availableWidth * 0.25;
            }

            /// -------- HEIGHT (SAFE) --------
            cardHeight = isLandscape
                ? height * 0.16
                : height * 0.13;

            /// clamp (VERY IMPORTANT)
            cardHeight = cardHeight.clamp(90.0, 140.0);

            return _buildCard(
              card['title'] as String,
              card['amount'] as double,
              card['color'] as Color,
            );
          }).toList(),
        );
      },
    );
  }


  // ================= Single Card =================
  Widget _buildCard(String title, double amount, Color color) {
    return Card(
      color: color,
      child: SizedBox(
        width: 100,
        height: 80,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(amount.toStringAsFixed(0),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // ================= Category Bar Chart =================
  Widget _buildCategoryBarChart(double height, bool isSmall, bool isMedium, bool isLarge) {
    if (controller.categoryData.isEmpty) return SizedBox();

    final categories = controller.categoryData.map((e) => e['name']).toList();
    final maxAmount = controller.categoryData
        .map((e) => (e['income'] ?? 0) + (e['expense'] ?? 0))
        .fold<double>(0, (prev, next) => next > prev ? next.toDouble() : prev);

    final barWidth = isLarge ? 20.0 : isMedium ? 16.0 : 12.0;

    return BarChart(
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
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6), topRight: Radius.circular(6))),
              BarChartRodData(
                  toY: (cat['expense'] ?? 0).toDouble(),
                  color: Colors.red,
                  width: barWidth,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6), topRight: Radius.circular(6))),
            ],
          );
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= categories.length) {
                    return SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 6),
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
                  return Text('${value.toInt()}', style: const TextStyle(fontSize: 11));
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
              FlLine(color: Colors.grey.withValues(alpha: 0.2), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
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
              fontSize: isSmall ? 10 : isMedium ? 12 : 14,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ));
      }
    }

    return PieChart(
      PieChartData(sections: sections, centerSpaceRadius: width * 0.08, sectionsSpace: 2),
    );
  }
}
